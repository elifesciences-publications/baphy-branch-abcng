function [w,event]=waveform (o,index,IsRef)
% function w=waveform(o, index);
% This is a generic waveform generator function for objects inherit from
% SoundObject class. It simply reads the Names field and load the one
% indicated by index. It assumes the files are in 'Sounds' subfolder in the
% object's folder.

% Nima, nov 2005
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

% if object has a field specifying sound path, use this. Otherwise,
% default is <objectpath>/Sounds/
allfields=get(o);
if isfield(allfields,'SoundPath'),
   soundpath=get(o,'SoundPath');
else
   soundpath = [object_spec.path filesep 'Sounds'];
end
files = get(o,'Names');
sampindex = strfind(files{index},'sample#');
if ~isempty(sampindex)
    files{index}(sampindex+7) = num2str(ceil(rand(1)*5));
end
if isfield(get(o),'NoiseType'),
    NoiseType = get(o,'NoiseType');
else
    NoiseType = 'white';
end
if strcmp(NoiseType,'SpectSmooth'),
    [w,fs] = wavread([soundpath filesep 'ds1_' files{index}]);
else
    [w,fs] = wavread([soundpath filesep files{index}]);
end

% Check the sampling rate:
if fs~=SamplingRate
    w = resample(w, SamplingRate, fs);
end
% 10ms ramp at onset:
w = w(:);
ramp = hanning(.01 * SamplingRate*2);
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
% If the object has Duration parameter, cut the sound to match it, if
% possible:
if isfield(get(o),'Duration')
    Duration = ifstr2num(get(o,'Duration'));
    totalSamples = floor(Duration * SamplingRate);
    w = w(1:min(length(w),totalSamples));
else
    Duration = length(w) / SamplingRate;
end
% Now, put it in the silence:
w = [zeros(ceil(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(ceil(PostStimSilence*SamplingRate),1)];
%
if isfield(get(o),'SNR')
    NoiseType = strrep(NoiseType,' ','');
    if get(o,'SNR') <100 && ~strcmpi(NoiseType,'none') && ~strcmpi(NoiseType,'SpectSmooth')
        if strcmpi(NoiseType,'white')
            % even for white, always load if from file. (Jan-9-2008, Nima)
            randn('seed',index);
            % for speech, we should add white noise to the 16K waveform, to
            % make it the same as others:
            if strcmpi(get(o,'descriptor'),'speech') && get(o,'SamplingRate')~=16000
                w = resample(w,16000,get(o,'SamplingRate'));
            end
            w = awgn(w, get(o,'SNR'), 'measured');
            if strcmpi(get(o,'descriptor'),'speech') && get(o,'SamplingRate')~=16000
                w = resample(w,get(o,'SamplingRate'),16000);
            end
        else
            [n,fs] = wavread([soundpath filesep lower(NoiseType) '.wav']);
            % to add randomness to different samples, shift the noise by
            % the index. So for the same index, the noise is always the
            % same. but for different indices, its different. This assumes
            % that the noise length is x times of the duration and index.
            n(1:floor(index*fs/5.5))=[]; % for each sample, shift the noise by 250ms
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
if isfield(get(o),'ReverbTime')
    len = length(w);
    randn('seed',index);
    w = addreverb (w, SamplingRate, get(o,'ReverbTime'));
    w = w(1:len);
end
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' files{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' files{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' files{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

if max(abs(w))>0,
%     w = 5*w/max(abs(w));
    w = 5 .* w ./ std(w(w~=0));
end