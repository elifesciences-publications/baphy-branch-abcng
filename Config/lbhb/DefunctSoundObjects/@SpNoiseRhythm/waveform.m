function [w,event]=waveform (o,index,IsRef);
% function w=waveform(o, index,IsRef);
%
% generate waveform for SpNoise object
%

PreStimSilence=get(o,'PreStimSilence');
PostStimSilence=get(o,'PostStimSilence');
Duration=get(o,'Duration');
spnoiseobj=get(o,'spnoiseobj');
rhythmobj=get(o,'rhythmobj');
SpAtten=get(o,'SpAtten');
Names=get(o,'Names');

wsp=waveform(spnoiseobj,index);
wrh=waveform(rhythmobj,1);
w = [wsp(:).*10.^(-SpAtten./20); wrh(:)];

% generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

