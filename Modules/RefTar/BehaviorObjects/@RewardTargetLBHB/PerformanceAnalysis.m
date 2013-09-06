function exptparams = PerformanceAnalysis (o, HW, StimEvents, globalparams, exptparams, TrialIndex, LickData)
% EarlyResponse: lick during the Early window after target. Early response causes the trial to stop immediately and a timeout.
% Hit: lick during Response window after the target. This is a correct response to the target and the water reward will be given.
% Miss: no lick during Response window after the target. A timeout will be given.
% FalseAlarm: lick during corresponding Response window for a reference.
% IneffectiveTrial: a trial the animal licks to all the references. In other word, a trial has a False alarm rate of 1. The trial will be stopped right before a target appears.
% InstructionTrial: a trial which instruct the animal stopping lick to a reference sound. It repeats play a reference sequence with an interval (Early window + Response window) until the animal stop lick to 2 successive references. Instruction trail is triggered when a Ineffective trial detected.
% WarningTrial: a trial with target, e.g. it is equal to (Total trials - Ineffective Trials).
% ReferenceLickTrial: a trial the animal lick during reference period (before the target appears).
% HitRate: total number of False Alarm divides by total number of warning trials.
% EarlyRate: total number of Early response divides by total number of warning trials.
% MissRate: total number of missed trials divides by total number of warning trials.
% FalseAlarmRate: total number of False Alarm divides by total number of references across all warning trials.

% Nima, April 2006

% if there is paw signal, take it out:
if size(LickData,2)>1,
    LickData = LickData(:,1);
end
% change the lick to positive edge only:
LickData(LickData<0.5)=0;
LickData(LickData>=0.5)=1;

global StopExperiment;
fs = HW.params.fsAI;
StopTargetFA = get(o,'StopTargetFA');

% Recalculate response windows to permit offline analysis
NumRef = 0;
parms=get(o);
ThisTargetNote=[];
FirstRefTime=nan;
FirstTarTime=nan;
for cnt1 = 1:length(StimEvents);
    [Type, Note, StimRefOrTar] = ParseStimEvent(StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmpi(StimRefOrTar,'Reference') && ~NumRef,
            FirstRefTime= StimEvents(cnt1).StartTime;
            NumRef=NumRef+1;
            if NumRef==1,
              RefEarlyWin=[0 StimEvents(cnt1).StartTime + parms.EarlyWindow];
            else
              RefEarlyWin=[StimEvents(cnt1).StartTime ...
                StimEvents(cnt1).StartTime + parms.EarlyWindow];
            end
            RefResponseWin = StimEvents(cnt1).StartTime + parms.EarlyWindow;
        elseif strcmpi(StimRefOrTar,'Target'),
            FirstTarTime= StimEvents(cnt1).StartTime;
            TarResponseWin = [StimEvents(cnt1).StartTime + parms.EarlyWindow ...
                StimEvents(cnt1).StartTime + parms.ResponseWindow + ...
                              parms.EarlyWindow];
            TarResponseWin=round(TarResponseWin*100)./100;
            TarEarlyWin = [StimEvents(cnt1).StartTime ...
                StimEvents(cnt1).StartTime + parms.EarlyWindow];
            % force end of reference window to match begining of early
            % window.  no FAs allowed at all.
            RefResponseWin(2)=TarEarlyWin(1);
            TarOffTime=StimEvents(cnt1).StopTime;
            ThisTargetNote=Note;
            
            if StimEvents(1).Trial==1,
                if strcmpi(get(exptparams.TrialObject, 'Descriptor'),'MultiRefTar'),
                    tar=get(exptparams.TrialObject,'TargetHandle');
                    exptparams.UniqueTargets=get(tar,'Names');
                end
                exptparams.UniqueTarResponseWinStart=[];
            end
            if ~isfield(exptparams,'UniqueTargets') || isempty(exptparams.UniqueTargets),
                exptparams.UniqueTargets={ThisTargetNote};
                exptparams.UniqueTarResponseWinStart=[];
            elseif ~iscell(exptparams.UniqueTargets),
                td=exptparams.UniqueTargets;
                exptparams.UniqueTargets={};
                for taridx=1:length(td),
                    exptparams.UniqueTargets{taridx}=num2str(td(taridx));
                end
                exptparams.UniqueTargets=union(exptparams.UniqueTargets,{ThisTargetNote});
            elseif ~any(strcmpi(ThisTargetNote,exptparams.UniqueTargets)),
                exptparams.UniqueTargets=union(exptparams.UniqueTargets,{ThisTargetNote});
            end
            exptparams.UniqueTarResponseWinStart=...
                union(exptparams.UniqueTarResponseWinStart,TarResponseWin(1));
        end
    end
end
% Doesn't work offline: Load saved parameters about response windows, generated in
% BehaviorControl.m
% RefResponseWin = exptparams.RefResponseWin;
% RefEarlyWin = exptparams.RefEarlyWin;
% TarResponseWin = exptparams.TarResponseWin;
% TarEarlyWin=exptparams.TarEarlyWin;
% NumRef=exptparams.NumRef;
% 
LickData = max(0,diff(LickData));
% what we need to procude here are:
%  1) histogram of first lick for each reference and target
%  2) false alarm for each reference, and hit for target at different
%       positions
%
% first, extract the lick data surrounding the onset of each stimulus
% (reference or target)
RefFalseAlarm = 0;RefFirstLick = NaN;
for cnt2 = 1:NumRef
    cnt1 = (cnt2-1)*2+1;
    RefResponseLicks{cnt2} = LickData(max(1,fs*RefResponseWin(cnt1)):min(length(LickData),round(fs*RefResponseWin(cnt1+1))));
    RefEarlyLicks{cnt2} = LickData(max(1,fs*RefEarlyWin(cnt1)):min(length(LickData),fs*RefEarlyWin(cnt1+1)));
    temp = find([RefEarlyLicks{cnt2}; RefResponseLicks{cnt2}],1)/fs;
    if ~isempty(temp), RefFirstLick(cnt2) = temp; else RefFirstLick(cnt2) = nan;end
    RefFalseAlarm(cnt2) = double(~isempty([find(RefEarlyLicks{cnt2});find(RefResponseLicks{cnt2})]));
end
TarResponseLick = LickData(max(1,round(fs*TarResponseWin(1))):min(length(LickData),round(fs*TarResponseWin(2))));
% in an ineffective trial, discard the lick during target because target
% was never played:
FalseAlarm = sum(RefFalseAlarm)/NumRef;
TarEarlyLick = LickData(round(fs*max(1,TarEarlyWin(1))):round(min(length(LickData),fs*TarEarlyWin(2))));
if (FalseAlarm>=StopTargetFA)  % in ineffective
    TarResponseLick = zeros(size(TarResponseLick));
    TarEarlyLick    = zeros(size(TarEarlyLick));
end
if ~isempty(find(TarEarlyLick,1)) % in early 
    TarResponseLick = zeros(size(TarResponseLick));
end
TarFirstLick = find([zeros(size(TarEarlyLick)) ;TarResponseLick],1)/fs;
if isempty(TarFirstLick), TarFirstLick = nan;end
% a special performance is calculated here for the graph that shows the hit
% and false alram based on the position of the target/reference:
% record the first lick time for ref and tar
if isfield(exptparams,'FirstLick') 
    exptparams.FirstLick.Tar(TrialIndex) = TarFirstLick;
    exptparams.FirstLick.Ref(TrialIndex) = RefFirstLick;
else
    % its the first time:
    exptparams.FirstLick.Tar = TarFirstLick;
    exptparams.FirstLick.Ref = RefFirstLick;
end
%
% now calculate the performance:
if isfield(exptparams, 'Performance') 
    perf = exptparams.Performance(1:end-1);
    cnt2 = length(perf) + 1;
else
    cnt2 = 1;
end
perf(cnt2).ThisTrial    = '??';
if NumRef
    perf(cnt2).FalseAlarm   = double(RefFalseAlarm | ~isempty(find(TarEarlyLick,1))); % sum of false alarams divided by num of ref
else
    perf(cnt2).FalseAlarm = NaN;
end
perf(cnt2).Ineffective  = double(perf(cnt2).FalseAlarm >= StopTargetFA);
perf(cnt2).WarningTrial = double(~perf(cnt2).Ineffective);
perf(cnt2).EarlyTrial   = double(perf(cnt2).WarningTrial && ~isempty(find(TarEarlyLick,1)));
%
perf(cnt2).Hit          = double(perf(cnt2).WarningTrial && ~perf(cnt2).EarlyTrial && ~isempty(find(TarResponseLick,1))); % if there is a lick in target response window, its a hit
perf(cnt2).Miss         = double(perf(cnt2).WarningTrial && ~perf(cnt2).EarlyTrial && ~perf(cnt2).Hit);
perf(cnt2).ReferenceLickTrial = double((perf(cnt2).FalseAlarm>0));
%
perf(cnt2).LickRate = length(find(LickData)) / length(LickData);

perf(cnt2).FirstLickTime = min([find(LickData,1)./fs Inf]);
perf(cnt2).FirstRefTime = FirstRefTime;
perf(cnt2).FirstTarTime = FirstTarTime;
% Now calculate hit and miss rates:
TotalWarn                   = sum(cat(1,perf.WarningTrial));
perf(cnt2).HitRate          = sum(cat(1,perf.Hit)) / TotalWarn;
perf(cnt2).MissRate         = sum(cat(1,perf.Miss)) / TotalWarn;
perf(cnt2).EarlyRate        = sum(cat(1,perf.EarlyTrial))/TotalWarn;
perf(cnt2).WarningRate      = sum(cat(1,perf.WarningTrial))/TrialIndex;
perf(cnt2).IneffectiveRate  = sum(cat(1,perf.Ineffective))/TrialIndex;
% this is for trials without Reference. We dont count them in FalseAlarm
% calculation:
tt = cat(1,perf.FalseAlarm);
tt(find(isnan(tt)))=[];
perf(cnt2).FalseAlarmRate   = sum(tt)/length(tt);
perf(cnt2).DiscriminationRate = perf(cnt2).HitRate * (1-perf(cnt2).FalseAlarmRate);
%also, calculate the stuff for this trial block:
RecentIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
tt = cat(1,perf(RecentIndex).FalseAlarm);
tt(find(isnan(tt)))=[];
perf(cnt2).RecentFalseAlarmRate   = sum(tt)/length(tt);
perf(cnt2).RecentHitRate         = sum(cat(1,perf(RecentIndex).Hit))/sum(cat(1,perf(RecentIndex).WarningTrial));
perf(cnt2).RecentDiscriminationRate = perf(cnt2).RecentHitRate * (1-perf(cnt2).RecentFalseAlarmRate);
%
perf(cnt2).TarResponseWinStart=TarResponseWin(1);

% target-specific HR / RT
perf(cnt2).ThisTargetNote=ThisTargetNote;

trialtargetid=ones(cnt2,1);
if isfield(exptparams,'UniqueTargets') && length(exptparams.UniqueTargets)>1 &&...
        ~strcmpi(get(exptparams.TrialObject,'descriptor'),'RepDetect'),
    UniqueCount=length(exptparams.UniqueTargets);
    for tt=1:cnt2,
        trialtargetid(tt)=find(strcmp(perf(tt).ThisTargetNote,...
                                      exptparams.UniqueTargets),1);
    end
else
    UniqueCount=1;
end

perf(cnt2).uWarningTrial=zeros(1,UniqueCount);
perf(cnt2).uHit=zeros(1,UniqueCount).*nan;
if perf(cnt2).WarningTrial,
    perf(cnt2).uWarningTrial(trialtargetid(cnt2))=perf(cnt2).WarningTrial;
    perf(cnt2).uHit(trialtargetid(cnt2))=perf(cnt2).Hit;
end
perf(cnt2).uHitRate = nanmean(cat(1,perf.uHit),1);
perf(cnt2).ReactionTime=exptparams.FirstLick.Tar(cnt2);
perf(cnt2).uReactionTime=zeros(1,UniqueCount).*nan;
perf(cnt2).uReactionTime(trialtargetid(cnt2))=perf(cnt2).ReactionTime;


% now determine what this trial outcome is:
if perf(cnt2).Hit, perf(cnt2).ThisTrial = 'Hit';end
if perf(cnt2).Miss, perf(cnt2).ThisTrial = 'Miss';end
if perf(cnt2).EarlyTrial, perf(cnt2).ThisTrial = 'Early';end
if perf(cnt2).Ineffective, perf(cnt2).ThisTrial = 'Ineffective';end

% compute DI based on FAR, HR and RT
trialparms=get(exptparams.TrialObject);
if strcmpi(trialparms.descriptor,'MultiRefTar'),
    % "strict" - FA is response to any possible target slot preceeding the target
    if trialparms.SingleRefSegmentLen>0,
        TarPreStimSilence=get(trialparms.TargetHandle,'PreStimSilence');
        PossibleRefTimes=(find(trialparms.ReferenceCountFreq(:))-1).*...
            trialparms.SingleRefSegmentLen+perf(1).FirstRefTime+TarPreStimSilence;
        resptime=[];
        stimtype=[];
        stimtime=[];
        tcounter=[];
        for tt=1:cnt2,
            RefCount=sum(PossibleRefTimes<perf(tt).FirstTarTime);
            stimtime=cat(1,stimtime,PossibleRefTimes(1:RefCount),...
                         perf(tt).FirstTarTime);
            resptime=cat(1,resptime,ones(RefCount+1,1).*perf(tt).FirstLickTime);
            stimtype=cat(1,stimtype,zeros(RefCount,1),1);
            tcounter=cat(1,tcounter,ones(RefCount+1,1).*trialtargetid(tt));
        end
    end
elseif strcmpi(trialparms.descriptor,'RepDetect'),
    % "strict" - FA is response to any possible target start slot
    % preceeding the target
    RefDuration=get(trialparms.ReferenceHandle,'Duration');
    PossibleRefTimes=(find(trialparms.ReferenceCountFreq(:))-1).*...
            RefDuration+perf(1).FirstRefTime;
    resptime=[];
    stimtype=[];
    stimtime=[];
    tcounter=[];
    for tt=1:cnt2,
        RefCount=sum(PossibleRefTimes<perf(tt).FirstTarTime);
        stimtime=cat(1,stimtime,PossibleRefTimes(1:RefCount),...
                     perf(tt).FirstTarTime);
        resptime=cat(1,resptime,ones(RefCount+1,1).*perf(tt).FirstLickTime);
        stimtype=cat(1,stimtype,zeros(RefCount,1),1);
        tcounter=cat(1,tcounter,ones(RefCount+1,1).*trialtargetid(tt));
    end
else
    % "easy" -- either respond to sound onset or target
    resptime=cat(1,perf.FirstLickTime);
    stimtype=cat(1,zeros(size(resptime)),ones(size(resptime)));
    resptime=cat(1,resptime,resptime);
    stimtime=cat(1,perf.FirstRefTime,perf.FirstTarTime);
    tcounter=trialtargetid([1:cnt2 1:cnt2]');
end

keepidx=find(stimtype==0 | stimtime<resptime);
stimtime=stimtime(keepidx);
stimtype=stimtype(keepidx);
resptime=resptime(keepidx);
tcounter=tcounter(keepidx);
stop_respwin=get(exptparams.BehaveObject,'EarlyWindow')+...
    get(exptparams.BehaveObject,'ResponseWindow');

[di,hits,fas,tsteps]=compute_di(stimtime,resptime,stimtype,stop_respwin);
%[perf(cnt2).FirstLickTime di max(hits) max(fas)]
perf(cnt2).DiscriminationIndex=di;
perf(cnt2).uDiscriminationIndex=zeros(1,UniqueCount).*nan;

for uu=unique(tcounter'),
    ff=find(tcounter==uu | stimtype==0);
    perf(cnt2).uDiscriminationIndex(uu)=...
        compute_di(stimtime(ff),resptime(ff),stimtype(ff),stop_respwin);
end

% change all rates to percentage. If its not rate, put the sum and
% 'out of' at the end
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if isinf(perf(cnt2).(PerfFields{cnt1})) , perf(cnt2).(PerfFields{cnt1}) = 0;end
    if ~isempty(strfind(PerfFields{cnt1},'ReactionTime')) && ...
             ~isempty(strfind(PerfFields{cnt1},'uHit'))&& ...
            isnan(perf(cnt2).(PerfFields{cnt1})) , perf(cnt2).(PerfFields{cnt1}) = 0;end
    if strcmpi(PerfFields{cnt1},'uHit') || strcmpi(PerfFields{cnt1},'uWarningTrial')
        perfPer.(PerfFields{cnt1}) = nansum(cat(1,perf.(PerfFields{cnt1})),1);
    elseif ~isempty(strfind(PerfFields{cnt1},'ReactionTime')) % RT, just average:
        perfPer.(PerfFields{cnt1}) = nanmean(cat(1,perf.(PerfFields{cnt1})));
    elseif ~isempty(strfind(PerfFields{cnt1},'Rate')) % if its a rate, do
        %not divide by number of trials, just make it percentage:
        perfPer.(PerfFields{cnt1}) = round(perf(cnt2).(PerfFields{cnt1})*100);
    elseif ~isempty(strfind(PerfFields{cnt1},'Index')) % if its an index
        %not divide by number of trials, just make it percentage:
        perfPer.(PerfFields{cnt1}) = round(perf(cnt2).(PerfFields{cnt1})*100);
    else
        if isnumeric(perf(cnt2).(PerfFields{cnt1}))
            perfPer.(PerfFields{cnt1})(1) = sum(cat(1,perf.(PerfFields{cnt1})));
            perfPer.(PerfFields{cnt1})(2) = TotalWarn; % by default
        else
            perfPer.(PerfFields{cnt1}) = perf(cnt2).(PerfFields{cnt1});
        end
    end
end

perfPer.Ineffective(2)  = TrialIndex;
perfPer.WarningTrial(2) = TrialIndex;
perfPer.ReferenceLickTrial = TrialIndex;
perfPer.FalseAlarm(2) = TrialIndex;


%
% now position hit and false alarm:
if TrialIndex==1 && isfield(exptparams,'PositionHit'),
  exptparams.PositionHit(:)=0;
  exptparams.PositionFalseAlarm(:)=0;
end
if isfield(exptparams,'UniqueTarResponseWinStart'),
  
  PositionThisTrial=find(exptparams.UniqueTarResponseWinStart==TarResponseWin(1));
  
  if ~isfield(exptparams,'PositionHit')  || (size(exptparams.PositionHit,1)<PositionThisTrial)
    exptparams.PositionHit(PositionThisTrial,1:2) = 0;
  end
  if (PositionThisTrial>0) && ((~isfield(exptparams,'PositionFalseAlarm')) ...
      || (size(exptparams.PositionFalseAlarm,1)<PositionThisTrial))
    exptparams.PositionFalseAlarm(PositionThisTrial,1:2) = 0;
  end
  if perf(cnt2).WarningTrial
    exptparams.PositionHit(PositionThisTrial,1) = exptparams.PositionHit(PositionThisTrial,1) + perf(cnt2).Hit;
    exptparams.PositionHit(PositionThisTrial,2) = exptparams.PositionHit(PositionThisTrial,2) + 1;
  end
  for cnt1 = 1:PositionThisTrial
    exptparams.PositionFalseAlarm (cnt1,1) = exptparams.PositionFalseAlarm(cnt1,1) + RefFalseAlarm(1);
    exptparams.PositionFalseAlarm (cnt1,2) = exptparams.PositionFalseAlarm(cnt1,2) + 1;
  end
  
else
  if ~isfield(exptparams,'PositionHit')  || (size(exptparams.PositionHit,1)<NumRef+1)
    exptparams.PositionHit(NumRef+1,1:2) = 0;
  end
  if (NumRef>0) && ((~isfield(exptparams,'PositionFalseAlarm')) ...
      || (size(exptparams.PositionFalseAlarm,1)<NumRef))
    exptparams.PositionFalseAlarm(NumRef,1:2) = 0;
  end
  if perf(cnt2).WarningTrial
    exptparams.PositionHit(NumRef+1,1) = exptparams.PositionHit(NumRef+1,1) + perf(cnt2).Hit;
    exptparams.PositionHit(NumRef+1,2) = exptparams.PositionHit(NumRef+1,2) + 1;
  end
  for cnt1 = 1:NumRef
    exptparams.PositionFalseAlarm (cnt1,1) = exptparams.PositionFalseAlarm(cnt1,1) + RefFalseAlarm(cnt1);
    exptparams.PositionFalseAlarm (cnt1,2) = exptparams.PositionFalseAlarm(cnt1,2) + 1;
  end
end
% perf(cnt2)
exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;
%%%%%
% if the animal did not lick at all in the last two experiment, stop the
% trial:
% leftover from original RewardTarget, removed by SVD
%if isfield(exptparams,'Performance') && (length(exptparams.Performance)>2)
%    DidSheLick = cat(1,exptparams.Performance(end-2:end-1).LickRate);
%    if sum(DidSheLick) == 0, StopExperiment = 1;end
%end
if isfield(exptparams,'Water')
    exptparams.Performance(end).Water = exptparams.Water .* globalparams.PumpMlPerSec.Pump;
end



