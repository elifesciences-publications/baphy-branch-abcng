function [w,event]=waveform (o,index,IsRef)
% function w=waveform(o, index);
% This is a generic waveform generator function for objects inherit from
% SoundObject class. It simply reads the Names field and load the one
% indicated by index. It assumes the files are in 'Sounds' subfolder in the
% object's folder.

% Nima, nov 2005
% Edited by Thomas Schatz November 2012

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

object_spec = what(class(o));
soundpath = [object_spec.path filesep 'Sounds'];
files = get(o,'Names');
[w,fs] = wavread([soundpath filesep files{index}]);
% Check the sampling rate:
if fs~=SamplingRate    w = resample(w, SamplingRate, fs);  end

Duration = length(w) / SamplingRate;
% Now, put it in the silence:
w = [zeros(ceil(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(ceil(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' files{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' files{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' files{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
