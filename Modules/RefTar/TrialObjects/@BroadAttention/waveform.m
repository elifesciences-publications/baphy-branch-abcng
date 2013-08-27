function [TrialSound, events , o] = waveform (o,idx)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o.
% Idx stimulus index or Serial Trial Number
% By Ling Ma, 3/2008

o=ObjUpdate(o);
%get information from trialobject
fs = get(o, 'SamplingRate');
pretrial=get(o,'PreTrialSilence');
posttrial=get(o,'PostTrialSilence');
TrialIndex = get(o,'TrialIndices');
current_repetition = get(o, 'repetition');
lightShift = get(o,'LightShift');
current_index = size(TrialIndex,1)*(current_repetition - 1)+ idx;

RefObject = get(o,'ReferenceHandle');        % get reference object
TarObject = get(o,'TargetHandle');

% burstcnt = get(TarObject,'BurstCnt');

LastEvent=pretrial;  %in sec. silence before the sound start
presilence=zeros(fs*pretrial,1);
postsilence=zeros(fs*posttrial,1);
TrialSound=[];
events=[];

% to get ref wave;
refw = presilence;
refeve1 = [];
% if size(TrialIndex,2)>2
%   [refw1,refeve1]=waveform(RefObject,TrialIndex(idx,[1,3]));
%
%
%   RelRef2Tar = TrialIndex(idx,3);
% else
[refw1,refeve1]=waveform(RefObject, [TrialIndex(idx,1), current_index]);
RelRef2Tar = get(o,'dBAttRef2Tar');
if ~isempty(TarObject)
    trainphase = get(RefObject, 'TrainPhase');
    if trainphase >= 4
        refname=get(RefObject,'Names');
        refname=str2num(refname{TrialIndex(idx,1)});
        ShiftTime=refname(3);
    else
        ShiftTime = get(RefObject, 'ShiftTime');
    end
else
    ShiftTime = 0;
end
refw=[refw;refw1(:)];

if size(TrialIndex,2)>2
    if length(RelRef2Tar) > 1
        RelRef2Tarindex = TrialIndex(idx,3);
        RelRef2Tar = RelRef2Tar(RelRef2Tarindex);
    end
    if length(lightShift) > 1
        lightShiftindex = TrialIndex(idx,end);
        lightShift = lightShift(lightShiftindex);
        lightType = get(o, 'lightType');
        lightType(current_index) = lightShift;
        o = set(o, 'lightType', lightType);
    end
end

refw = (10^(-RelRef2Tar/20))*refw;

% to get tar wave;
tarw = [];
tareve1 = [];
if ~isempty(TarObject)
    burstcnt = get(TarObject,'BurstCnt');
    if ShiftTime>0  %for alternation
        burstcnt=burstcnt*2;
    end
    [tarw,tareve1]=waveform(TarObject, [TrialIndex(idx,2) current_index]);
end

TrialSound=[refw;tarw;postsilence];

%add light signal (disabled now)
if ~isempty(TarObject)
    lightAmp = 5;
    TrialSoundTmp(:,1) = TrialSound;
    TrialSoundTmp(:,2) = [zeros(length(TrialSound),1)];
    
    if lightShift > 0
        preTar = get(TarObject,'PreStimSilence');
        postTar = get(TarObject,'PostStimSilence');
        preRef = get(RefObject,'PreStimSilence');
        postRef = get(RefObject,'PostStimSilence');
        toneLen = get(RefObject,'ToneDur');
        gapLen = get(RefObject,'GapDur');
        lightshiftTime = 0;
        if lightShift == 2
            lightshiftTime = ShiftTime;
        end
        earlycut = 0.05;
        partNum = ceil((length([refw;tarw]) - ceil((pretrial + preRef + lightshiftTime)*fs)) / ceil((toneLen + gapLen)*fs));
        lightConVecPart = [ones(ceil((toneLen+earlycut)*fs),1)*lightAmp;zeros(ceil((gapLen-earlycut)*fs),1)];
        lightConVec = repmat(lightConVecPart,partNum,1);
        preLight = round((pretrial + preRef + lightshiftTime)*fs);
        TrialSoundTmp(preLight+1:preLight+length(lightConVec),2) = lightConVec;
    end
    TrialSound = TrialSoundTmp;
end

%normalized the amplitude to 5
TrialSound(:,1) = TrialSound(:,1)/max(abs(TrialSound(:,1)))*5;

%testing the dynamic or static feature/ ON MY OWN MACHINE ONLY
testing = 0;
if testing
    if exist('e:\BFGreconstr\maktest\wavedata.mat')
        load('e:\BFGreconstr\maktest\wavedata.mat');
        saveTrialSound{end+1} = TrialSound;
        save('e:\BFGreconstr\maktest\wavedata.mat', 'saveTrialSound')
        clear saveTrialSound
    else
        saveTrialSound{1} = TrialSound;
        save('e:\BFGreconstr\maktest\wavedata.mat', 'saveTrialSound')
        clear saveTrialSound
    end
end


%-----to mark '$' sign for behavior performance;
%'$' mark the begin of the masker sequence
if ~isempty(TarObject)  %BFG trial
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
    events = [refeve tareve];
    events(end).StopTime=events(end).StopTime+posttrial;
else   % MSK trial ONLY referency
    refeve1(1).StartTime=refeve1(1).StartTime-pretrial;
    refstr=[' Reference'];
    [refeve,LastEvent]=updateEvtime(refeve1,refstr,LastEvent,idx);
    events = refeve;
    events(end).StopTime=events(end).StopTime+posttrial;
end


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
