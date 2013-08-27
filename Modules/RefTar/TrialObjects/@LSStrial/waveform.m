function [TrialSound, events , o] = waveform (o,idx);

o=ObjUpdate(o);
fs = get(o, 'SamplingRate');
RefObject = get(o,'ReferenceHandle');        % get reference object
TarObject = get(o,'TargetHandle');
% RefObject = set(RefObject,'TarFreq',get(TarObject,'TarFreq'));
pretrial=get(o,'PreTrialSilence');
posttrial=get(o,'PostTrialSilence');
isigap=get(o,'InterStimInterval');
TrialIndex = get(o,'TrialIndices');  
refidx = get(o,'ReferenceIdx');
% tarfreq = get(TarObject,'TarFreq');

LastEvent=pretrial;  %in sec. silence before the sound start
presilence=zeros(fs*pretrial,1);
postsilence=zeros(fs*posttrial,1);
TrialSound = [];
refw=presilence; refeve=[]; 
refstr=[' Reference'];
isiw=zeros(fs*isigap,1);%silence period
kk = 1;
for i = sum(TrialIndex(1:idx-1,1))+1:sum(TrialIndex(1:idx,1)) % each trial length
     [refw1,refeve1]=waveform(RefObject,refidx(i,:));          %ref masker Sequence
     eve2 = refeve1(2).Note;
     comapos = strfind(eve2,',');
%      if length(comapos)==1
%         refeve1(2).Note=[eve2,'$']; %'$' mark the begin of the ref sequence
%      else
        refeve1(2).Note=[eve2(1:comapos(2)-1),'$',eve2(comapos(2):end)]; %'$' mark the begin of the ref/masker sequence
%      end
      
     refw1=[refw1;isiw];
     if kk == 1
        refeve1(1).StartTime=refeve1(1).StartTime-pretrial; 
     end
     refeve1(end).StopTime=refeve1(end).StopTime+isigap;
     [refeve1,LastEvent]=updateEvtime(refeve1,refstr,LastEvent,idx);
     refw=[refw;refw1(:)];
     refeve=[refeve refeve1];
     kk = kk+1;
end
[tarw,tareve]=waveform(TarObject,TrialIndex(idx,3));% target is silence;
tarw = [tarw;isiw];
% kk=1;
% if kk == 1
%     tareve(1).StartTime=tareve(1).StartTime-pretrial;
% end
eve2 = tareve(2).Note;
% comapos = strfind(eve2,',');
tareve(2).Note=[eve2,'$']; %'$' mark the end of light off and begin of the light flashing
tarstr=[' Target'];
[tareve]=updateTarEvtime(tareve,tarstr,pretrial,idx);
tareve(end).StopTime=tareve(end).StopTime+isigap+posttrial;
TrialSound=[refw;postsilence];
events=[refeve tareve];

%=============================================================
function [ev,LastEvent]=updateEvtime(ev,tagSTR,LastEvent,idx);
for i=1:length(ev)
    tmp = ev(i).Note;
    comapos = strfind(tmp,',');
    ev(i).Note = [tmp(1:comapos(2)),tagSTR,',',tmp(comapos(2)+1:end)];
    ev(i).Trial = idx;
    ev(i).StartTime=ev(i).StartTime+LastEvent;
    ev(i).StopTime=ev(i).StopTime+LastEvent;    
end
LastEvent = ev(end).StopTime;

function [ev]=updateTarEvtime(ev,tagSTR,pretrial,idx);
for i=1:length(ev)
    tmp = ev(i).Note;
%     comapos = strfind(tmp,',');
    ev(i).Note = [tmp,',',tagSTR];
    ev(i).Trial = idx;
    ev(i).StartTime=ev(i).StartTime+pretrial;
    ev(i).StopTime=ev(i).StopTime+pretrial;    
end
% LastEvent = ev(end).StopTime;
