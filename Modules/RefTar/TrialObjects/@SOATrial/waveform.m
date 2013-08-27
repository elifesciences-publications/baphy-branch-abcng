function [TrialSound, events , o] = waveform (o,idx);
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. 
% idx stimulus index or Serial Trial Number
% Pingbo, last modified at 2/01/2006
% modified by Ling Ma, Jun. 2006

fs = get(o, 'SamplingRate');
RefObject = get(o,'ReferenceHandle');        % get reference object
TarObject=get(o,'TargetHandle');             % get target object
Refnames = get(RefObject,'Names');
TrialIndex = get(o,'TrialRandom');     % block of random trial sequence
CurrentReps=get(o,'CurrentReps');      %
TrialPerReps=get(o,'NumberOfTrials');  % How many trials for each repetition?
reinforcer=get(o,'Reinforcement');
complexnum=get(TarObject,'ComplexNum');
tarType=get(TarObject,'Type');

[refw,refeve]=waveform(RefObject,TrialIndex(idx,1));
if strcmp(reinforcer,'Positive')
    refeve=RefOnset(refeve,tarType,complexnum); 
end
for i=1:length(refeve)
    refeve(i).Note = [refeve(i).Note ' , Reference'];
    refeve(i).Trial = (CurrentReps-1)*TrialPerReps+idx;
    LastEvent = refeve(i).StopTime;
end
para=str2num(Refnames{TrialIndex(idx,1)})

if TrialIndex(idx,2)==0         %for sham trial    
    TarObject=set(TarObject,'ToneA',para(1));
    TarObject=set(TarObject,'ToneB',para(2));
    TrialIndex(idx,2)=1;
    tar_str='Sham';
else
    if strcmp(get(TarObject,'Type'),'targetAA') %'passive mode, set tone A/B in target = tone A/B in reference.
        TarObject=set(TarObject,'ToneB',para(2));  %set the B tone constent across target
        TarObject=set(TarObject,'ToneA',para(1)); %set the A tone constent across target
%     elseif strcmp(get(TarObject,'Type'),'targetBB')
%         TarObject=set(TarObject,'ToneA',para(1));  %set the A tone constent across target
    end
    TarObject = set(TarObject,'SOA',para(4));
    tar_str='Target';
end

[tarw,tareve]=waveform(TarObject,TrialIndex(idx,2));
if strcmp(reinforcer,'Positive')
    tareve=RefOnset(tareve,tarType,complexnum); end
for i=1:length(tareve)
    tareve(i).Note = [tareve(i).Note ' , ' tar_str];
    tareve(i).StartTime=tareve(i).StartTime+LastEvent;
    tareve(i).StopTime=tareve(i).StopTime+LastEvent;
    tareve(i).Trial = (CurrentReps-1)*TrialPerReps+idx;
end
if strcmp(tar_str,'Sham')
    TrialSound=[refw;tarw];
else
    Ref2TarDB=get(o,'RelativeRefTardB');
    TrialSound=[refw*10^(Ref2TarDB/20);tarw];
%     TrialSound=5*TrialSound/max(TrialSound);  %re-normalizing the scale
end
events=[refeve tareve];

%========================================================
function refeve=RefOnset(refeve,typestr,complexnum);
if strcmp(typestr,'targetBB')
    ref='ToneB ';
else
    ref='ToneA ';
end
n=[];
for i=1:length(refeve)
    if strfind(refeve(i).Note,'STIM') & (strfind(refeve(i).Note,ref))
        n=[n;i];
    end
end
for i=1:complexnum:length(n)
    refeve(n(i)).Note=[refeve(n(i)).Note '$'];
end
