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

% figure out if noise to be added
if isfield(get(o),'SNR')
    if isfield(get(o),'NoiseType'),
        NoiseType = get(o,'NoiseType');
    else
        NoiseType = 'white';
    end
    SNR=get(o,'SNR');
    SNR=SNR(index);
    NoiseType = strrep(NoiseType,' ','');
else
    SNR=100;
    NoiseType='none';
end

%object_spec = what(class(o));
if SNR>100,
   object_spec=what('FerretVocal');
   soundpath=[object_spec.path filesep 'Sounds_set4'];
   dd=dir([soundpath filesep '*wav']);
   dd=dd(1:30);
   files={dd.name};
else
   object_spec = what('Speech');
   soundpath = [object_spec.path filesep 'Sounds'];
   Names=get(o,'Names');
   Name=Names{index};
   files=strsep(Name,'+',1);
   files={files{2:end}};
end

Duration=get(o,'Duration');
fdur=Duration./length(files);
fsamp=fdur.*SamplingRate;

% generate the event structure:
event = struct('Note',['PreStimSilence , ' files{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(length(files)+2) = struct('Note',['PostStimSilence , ' files{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

w=zeros(get(o,'Duration').*SamplingRate,1);

for fidx=1:length(files);
    if isnan(SNR),
        fs=16000;
        s=zeros(ceil(fs.*fdur+1),1);
    elseif SNR<=-100,
        [s,fs] = wavread([soundpath filesep files{1}]);
    else
        [s,fs] = wavread([soundpath filesep files{fidx}]);
    end
    
    % 10ms ramp at onset/offset:
    ramp = hanning(.01 * fs*2);
    ramp = ramp(1:floor(length(ramp)/2));
    s(1:length(ramp)) = s(1:length(ramp)) .* ramp;
    s(end-length(ramp)+1:end) = s(end-length(ramp)+1:end) .* flipud(ramp);

    % add noise if necessary
    if ~isnan(SNR) && SNR<100 && ~strcmpi(NoiseType,'none')
        if strcmpi(NoiseType,'white')
            % no ramp for white noise
            randn('seed',fidx);
            s = awgn(s, SNR, 'measured');
        else
            [n,fsn] = wavread([soundpath filesep NoiseType '.wav']);
            % to add randomness to different samples, shift the noise by
            % the index. So for the same index, the noise is always the
            % same. but for different indices, its different. This assumes
            % that the noise length is x times of the duration and index.
            n(1:floor(index*fsn/5.5))=[]; % for each sample, shift the noise by 250ms
            if fs ~= fsn
                n = resample(n,fs,fsn);
            end
            n=n(1:length(s));
            n(1:length(ramp)) = n(1:length(ramp)) .* ramp;
            n(end-length(ramp)+1:end) = n(end-length(ramp)+1:end) .* flipud(ramp);
            
            sigPower = sum(abs(s(:)).^2)/length(s(:));
            sigPower = 10*log10(sigPower);
            noisePower = sum(abs(n(:)).^2)/length(n(:));
            noisePower = 10*log10(noisePower);
            curSNR = sigPower-noisePower;
            reqSNR = get(o,'SNR');
            noiseGain = sqrt(10^((reqSNR-curSNR)/10));
            s = s + n/noiseGain;
        end
    end
    
    % Adjust the sampling rate if necessary
    if fs~=SamplingRate
        s = resample(s, SamplingRate, fs);
    end
    ss=round((fidx-1).*fsamp)+1;
    es=round(fidx.*fsamp);
    
    w(ss:es)=s(1:(es-ss+1));
    event(fidx+1) = struct('Note',['Stim , ' NoiseType ':' num2str(SNR) '+' files{fidx}],'StartTime',...
        PreStimSilence+fdur.*(fidx-1), 'StopTime', PreStimSilence+fdur.*fidx, 'Trial',[]);
end

% Now, put it in the silence:
w = [zeros(ceil(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(ceil(PostStimSilence*SamplingRate),1)];
%

if isfield(get(o),'ReverbTime')
    len = length(w);
    randn('seed',index);
    w = addreverb (w, SamplingRate, get(o,'ReverbTime'));
    w = w(1:len);
end

if max(abs(w))>0,
    w = 5*w/max(abs(w));
end
