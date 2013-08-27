function [w,event]=waveform (o,index,IsRef);
% function w=waveform(o, index);
% This is a generic waveform generator function for objects inherit from
% SoundObject class. It simply reads the Names field and load the one
% indicated by index. It assumes the files are in 'Sounds' subfolder in the
% object's folder.

% PBY modified from standard one, Aug 2007
maxIndex = get(o,'MaxIndex');
if index > maxIndex
    error (sprintf('Maximum possible index is %d',maxIndex));
end
%
event=[];
SamplingRate = ifstr2num(get(o,'SamplingRate'));
PreStimSilence = ifstr2num(get(o,'PreStimSilence'));
PostStimSilence = ifstr2num(get(o,'PostStimSilence'));
% If more than two values are specified, choose a random number between the
% two:
if length(PreStimSilence)>1
    PreStimSilence = PreStimSilence(1) + diff(PreStimSilence) * rand(1);
end
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end

%
object_spec = what(class(o));
soundset=get(o,'Subsets');
if soundset==1  %default 50 stimuli set
    soundpath = [object_spec.path filesep 'Sounds'];
elseif soundset==2  %adult ferrets VC set (from 5 ferrets
    soundpath = [object_spec.path filesep 'Sounds_set2'];
elseif soundset==3  %infant ferrets VC set (65)
    soundpath = [object_spec.path filesep 'Sounds_set3'];
else
    disp('Wrong subset!!'); return; end

files = get(o,'Names');
sampindex = strfind(files{index},'sample#');
if ~isempty(sampindex)
    files{index}(sampindex+7) = num2str(ceil(rand(1)*5));
end 
[w,fs] = wavread([soundpath filesep files{index}]);
% Check the sampling rate:
if fs~=SamplingRate
    w = resample(w, SamplingRate, fs);
end
% If the object has Duration parameter, cut the sound to match it, if
% possible:
if isfield(get(o),'Duration') && soundset==1
    Duration = ifstr2num(get(o,'Duration'));
    totalSamples = floor(Duration * SamplingRate);
    w = w(1:min(length(w),totalSamples));
else
    Duration = length(w) / SamplingRate;
end

% 10ms ramp at onset:
w = w(:);
ramp = hanning(.01 * SamplingRate*2);
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);

% Now, put it in the silence:
w = [zeros(ceil(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(ceil(PostStimSilence*SamplingRate),1)];
%
if isfield(get(o),'SNR')
    if isfield(get(o),'NoiseType'),
        NoiseType = get(o,'NoiseType');
    else
        NoiseType = 'white';
    end
    if get(o,'SNR') <100
        if strcmp(NoiseType,'white')
            w = awgn(w, get(o,'SNR'), 'measured');
        else
            [n,fs] = wavread([soundpath filesep NoiseType '.wav']);
            if fs ~= SamplingRate
                n = resample(n,SamplingRate,fs);
            end
            n(length(w)+1:end)=[]; % assume the noise is always longer than the signal!
            sigPower = sum(abs(w(:)).^2)/length(w(:));
            sigPower = 10*log10(sigPower);
            noisePower = sum(abs(n(:)).^2)/length(n(:));
            noisePower = 10*log10(noisePower);
            curSNR = sigPower-noisePower; 
            reqSNR = get(o,'SNR'); 
            noiseGain = sqrt(10^((reqSNR-curSNR)/10));
            w = w + n/noiseGain;
        end
    end
end


% and generate the event structure:
event = struct('Note',['PreStimSilence , ' files{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' files{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' files{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

w = 5*w/max(abs(w));