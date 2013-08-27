function [w,event]=waveform (o,index,IsRef)
% function w=waveform(o, index);
% This is a generic waveform generator function for objects inherit from
% SoundObject class. It simply reads the Names field and load the one
% indicated by index. It assumes the files are in 'Sounds' subfolder in the
% object's folder.

% svd ripped off of SoundObject waveform
par=get(o);
maxIndex = par.MaxIndex;
if index > maxIndex
    error (sprintf('Maximum possible index is %d',maxIndex));
end
%
event=[];
SamplingRate = ifstr2num(par.SamplingRate);
PreStimSilence = ifstr2num(par.PreStimSilence);
PostStimSilence = ifstr2num(par.PostStimSilence);
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
soundpath = [object_spec.path filesep 'Sounds'];
files = get(o,'Names');

[w,fs] = wavread([soundpath filesep files{index}]);

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
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' files{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' files{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' files{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

if max(abs(w))>0,
    w = 5*w/max(abs(w));
end