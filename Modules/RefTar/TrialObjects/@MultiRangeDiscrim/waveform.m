function [TrialSound, events , o] = waveform (o,idx);
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. 
% Idx stimulus index or Serial Trial Number
% Pingbo, last modified at 2/01/2006

o=ObjUpdate(o);
TrialIndex = get(o,'TrialIndices');     % 
pretrial=get(o,'PreTrialSilence');
posttrial=get(o,'PostTrialSilence');
FlowRate=get(o,'FlowRate_mlPmin');
sf=get(o,'SamplingRate');
RefObject = get(o,'ReferenceHandle');        % get reference object
RefObject=set(RefObject,'PreStimSilence',pretrial);
RefObject=set(RefObject,'PostStimSilence',posttrial);
RefObject=set(RefObject,'SamplingRate',sf);
[TrialSound,events]=waveform(RefObject,TrialIndex(idx,1));
TrialSound=5*TrialSound/max(TrialSound);  %re-normalizing the scale

refAttenDB=get(o,'RefAttenDB');
if TrialIndex(idx,2)==0   %reference
    tagSTR='Reference';
else
    tagSTR='Target'; end
   
if length(refAttenDB)==1   %single intensity level
    if TrialIndex(idx,2)==0   %reference 
        refAttenDB=10^(-refAttenDB/20);     %convert DB into amplitude ratio     
        TrialSound=TrialSound*refAttenDB;
    end
else                       %multi-intensity levels
   TrialSound=TrialSound*10^(-TrialIndex(idx,3)/20);  %attenation
   tagSTR=sprintf('%s,%d',tagSTR,TrialIndex(idx,3));
end
events=updateEvtime(events,tagSTR);
if FlowRate==0
    return; end
TrialSound=[TrialSound(:) ones(length(TrialSound),1)*FlowRate*10/6];  %add 2nd AO to control pump flow: 10 V= 6.0 ml/min
TrialSound(1:round(0.01*sf),2)=0;         %delay 10 ms turn the pump on
TrialSound(end-round(0.01*sf):end,2)=0;   %turn pump off 10 ms early

%=============================================================
function ev=updateEvtime(ev,tagSTR);
for i=1:length(ev)
    ev(i).Note = deblank([ev(i).Note ' ,' tagSTR]);   
end
