function [TrialSound, events , o] = waveform (o,idx);
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. 
% Idx stimulus index or Serial Trial Number
% By Ling Ma, 3/2008

o=ObjUpdate(o);
fs = get(o, 'SamplingRate');
RefObject = get(o,'ReferenceHandle');        % get reference object
TarObject = get(o,'TargetHandle');
tarfreq = get(TarObject,'TarFreq');
RefObject = set(RefObject,'TarFreq',tarfreq);%force ref and tar objects have the same tar freq;
pretrial=get(o,'PreTrialSilence');
posttrial=get(o,'PostTrialSilence');
TrialIndex = get(o,'TrialIndices');  
burstcnt = get(TarObject,'BurstCnt');

LastEvent=pretrial;  %in sec. silence before the sound start
presilence=zeros(fs*pretrial,1);
postsilence=zeros(fs*posttrial,1);
TrialSound=[]; events=[];

% to get ref wave;
refw=presilence; refeve=[]; 
if size(TrialIndex,2)>2
    [refw1,refeve1]=waveform(RefObject,TrialIndex(idx,[1,3]));
    RelRef2Tar = TrialIndex(idx,3);
else
    [refw1,refeve1]=waveform(RefObject,TrialIndex(idx,1));
    RelRef2Tar = get(o,'dBAttRef2Tar');
end
refw=[refw;refw1(:)];
refw = (10^(-RelRef2Tar/20))*refw;
% to get tar wave;
[tarw,tareve1]=waveform(TarObject,TrialIndex(idx,2)); 

type = deblank(get(RefObject,'type'));
if strcmp(type,'reftar')
    % add ref and tar waves together;
    TrialSound=[refw;tarw;postsilence];
    %-----to mark '$' sign for behavior performance;
    %'$' mark the begin of the masker sequence
    n=[];
    for i=1:length(refeve1)
        if strfind(refeve1(i).Note,'STIM')
            n=[n;i];
        end
    end
    for i=1:burstcnt:length(n)
        eve2 = refeve1(n(i)).Note;
        comapos = strfind(eve2,',');
        refeve1(n(i)).Note=[eve2(1:comapos(2)-1),'$',eve2(comapos(2):end)]; 
    end
    %'$' mark the begin of the target
    eve2 = tareve1(2).Note;
    comapos = strfind(eve2,',');
    tareve1(2).Note=[eve2(1:comapos(2)-1),'$',eve2(comapos(2):end)]; 
    % update ref and tar events;
    refeve1(1).StartTime=refeve1(1).StartTime-pretrial; 
    refstr=[' Reference'];
    [refeve,LastEvent]=updateEvtime(refeve1,refstr,LastEvent,idx);
    tarstr=[' Target'];
    [tareve,LastEvent]=updateEvtime(tareve1,tarstr,LastEvent,idx);
else
    % add ref and tar waves together;
    tarw = [zeros(length(refw)-length(tarw),1);tarw];
    TrialSound=[refw+tarw;postsilence];
    %-----to mark '$' sign for behavior performance;
    %'$' mark the begin of the masker sequence
    tareve_leng = length(tareve1)-1;
    n=[];
    for i=1:length(refeve1)-tareve_leng
        if strfind(refeve1(i).Note,'STIM')
            n=[n;i];
        end
    end
    for i=1:burstcnt:length(n)
        eve2 = refeve1(n(i)).Note;
        comapos = strfind(eve2,',');
        refeve1(n(i)).Note=[eve2(1:comapos(2)-1),'$',eve2(comapos(2):end)]; 
    end
    %'$' mark the begin of the target
    eve2 = tareve1(2).Note;
    comapos = strfind(eve2,',');
    tareve1(2).Note=[eve2(1:comapos(2)-1),'$',eve2(comapos(2):end)]; 
    % update ref and tar events;
    refeve1(1).StartTime=refeve1(1).StartTime-pretrial; 
    refstr=[' Reference'];
    [refeve,LastEvent]=updateEvtime(refeve1(1:end-tareve_leng),refstr,LastEvent,idx);
    tarstr=[' Target'];
    [tareve,LastEvent]=updateEvtime(tareve1,tarstr,LastEvent,idx);
end

% add ref and tar events together;
events = [refeve tareve];
events(end).StopTime=events(end).StopTime+posttrial;

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
