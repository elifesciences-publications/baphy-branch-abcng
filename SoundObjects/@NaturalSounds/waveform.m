function [w,event,O] = waveform(O,Index,IsRef,Mode,Global_TrialNb)%(o,Index,IsRef)
% function w=waveform(o, Index);
% This is a generic waveform generator function for objects inherit from
% SoundObject class. It simply reads the Names field and load the one
% indicated by Index. It assumes the files are in 'Sounds' subfolder in the
% object's folder.

% Nima, nov 2005
% Edited by Thomas Schatz November 2012

maxIndex = get(O,'MaxIndex');
if Index > maxIndex
    error (sprintf('Maximum possible Index is %d',maxIndex));
end

event=[];
SamplingRate = ifstr2num(get(O,'SamplingRate'));
PreStimSilence = ifstr2num(get(O,'PreStimSilence'));
PostStimSilence = ifstr2num(get(O,'PostStimSilence'));
% If more than two values are specified, choose a random number between the
% two:
if length(PreStimSilence)>1
    PreStimSilence = PreStimSilence(1) + diff(PreStimSilence) * rand(1);
end
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end

[p, ~, ~] = fileparts(mfilename('fullpath'));
switch O.StimulusType
    case 'PilotScrambling'
%         soundpath = 'M:\Lab\AudioFiles\pilot-stimuli-scrambling-MAT';
%         load([p filesep 'stim-orders-ferret.mat']);
        soundpath = 'M:\Lab\AudioFiles\Scrambling';
        stim_order = {};
        colC = 0;
        for ii = get(O,'InitialOrder'):...
                min([length(dir([p filesep 'ScramblingOrder' filesep '*.mat'])) , ...
                get(O,'InitialOrder')+10])
            temp = load([p filesep 'ScramblingOrder' filesep 'r' num2str(ii) '.mat']);
            for SesN = 1:size(temp.stim_order,2)
                colC = colC + 1;
                for rC = 1:size(temp.stim_order,1)
                    stim_order{rC,colC} = temp.stim_order{rC,SesN};
                end
            end
        end
end
SessionNum = 1+floor((Global_TrialNb-1)/(get(O,'MaxIndex')));
Index = Global_TrialNb-((SessionNum-1)*get(O,'MaxIndex'));
% ff = ;
% fInd = find(ff=='-'); fInd = fInd(2);
FN = stim_order{Index,SessionNum};
SoundMatFile = load([soundpath filesep FN '.mat']);
fs = SoundMatFile.P.audio_sr;
w = SoundMatFile.quilt;
% [w,fs] = wavread([soundpath filesep ff(1:(fInd-1)) 'ms' ff(fInd:end) '.wav']);
% Check the sampling rate:
if fs~=SamplingRate; w = resample(w, SamplingRate, fs); end

Duration = length(w) / SamplingRate;
O = set(O,'Duration',PreStimSilence+Duration+PostStimSilence);
% Now, put it in the silence:
w = [zeros(ceil(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(ceil(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' FN],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' FN],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' FN],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
