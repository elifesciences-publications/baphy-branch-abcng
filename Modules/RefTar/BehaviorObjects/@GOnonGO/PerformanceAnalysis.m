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
global StopExperiment;
fs = HW.params.fsAI;

[t,trial,Note,toff,StimIndex] = evtimes(StimEvents,'Stim*');
%stidur = StimEvents(StimIndex).StopTime-StimEvents(StimIndex).StartTime;
[Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(StimIndex));
ResponseWin = [StimEvents(StimIndex).StartTime + get(o,'EarlyWindow') ...
    StimEvents(StimIndex).StartTime + get(o,'ResponseWindow') + get(o,'EarlyWindow')];
EarlyWin=StimEvents(StimIndex).StartTime+ [0 get(o,'EarlyWindow')];

% now, ResponseWin that has the start and stop point of each trial
exptparams.ResponseWin  = ResponseWin;
LickData = max(0,diff(LickData));

% first, extract the relavant lick data:
ResponseLicks = LickData(max(1,fs*ResponseWin(1)):min(length(LickData),fs*ResponseWin(2)));
EarlyLicks = LickData(max(1,fs*EarlyWin(1)):min(length(LickData),fs*EarlyWin(2)));
temp = find([EarlyLicks; ResponseLicks],1)/fs;
stim=get(get(exptparams.TrialObject,'ReferenceHandle'),'names');
runclass=get(exptparams.TrialObject,'runclass');
if strcmpi(runclass,'MRD')
  stim=get(exptparams.TrialObject,'RefIndices');
  TrialStim=get(exptparams.TrialObject,'TrialIndices');
  blockIndex = rem(TrialIndex-1,size(TrialStim,1))+1;
  stimnum=find(sum(stim==repmat(TrialStim(blockIndex,:),size(stim,1),1),2)==size(stim,2));
else
    disp('unknown runclass');
    return;
end
if ~isempty(temp), FirstLick = temp; else FirstLick = nan;end
if isfield(exptparams,'FirstLick') 
    exptparams.FirstLick(end+1,1:4) = [FirstLick 0 stimnum ~isempty(find(ResponseLicks,1))];
else     % its the first time:
    exptparams.FirstLick(1,1:4) = [FirstLick 0 stimnum ~isempty(find(ResponseLicks,1))];
end


% now calculate the performance:
if isfield(exptparams, 'Performance') 
    perf = exptparams.Performance(1:end-1);
    cnt2 = length(perf) + 1;
else
    cnt2 = 1;
end
perf(cnt2).ThisTrial='??';
perf(cnt2).EarlyTrial   = double(~isempty(find(EarlyLicks,1))); %early on ref (0 1)
perf(cnt2).Miss=0;
perf(cnt2).Hit=0;
perf(cnt2).FalseAlarm=0;
if perf(cnt2).EarlyTrial, perf(cnt2).ThisTrial = 'Early';end
if strcmpi(StimRefOrTar,'Reference')
    perf(cnt2).FalseAlarm   = double(~perf(cnt2).EarlyTrial && ~isempty(find(ResponseLicks,1))); %
    perf(cnt2).Hit=NaN;
    if perf(cnt2).FalseAlarm
        perf(cnt2).ThisTrial = 'FalseAlarm';
    elseif ~perf(cnt2).EarlyTrial
        perf(cnt2).ThisTrial = 'CorrectReject';
    end
    perf(cnt2).Miss = double(~perf(cnt2).EarlyTrial && ~perf(cnt2).FalseAlarm);
else
    perf(cnt2).FalseAlarm = NaN;
    perf(cnt2).Hit=double(~perf(cnt2).EarlyTrial && ~isempty(find(ResponseLicks,1))); %    
    exptparams.FirstLick(cnt2,2)=1;   %mark target trial
    if perf(cnt2).Hit
        perf(cnt2).ThisTrial = 'Hit';
    elseif ~perf(cnt2).EarlyTrial
        perf(cnt2).ThisTrial = 'Miss';
    end
    perf(cnt2).Miss = double(~perf(cnt2).EarlyTrial && ~perf(cnt2).Hit);
    perf(cnt2).EarlyTrial=perf(cnt2).EarlyTrial+2;  %early on target trial (2 3)
end

perf(cnt2).LickRate = length(find(LickData)) / length(LickData);
% Now calculate hit and miss rates:
TotalTar                    = sum(~isnan(cat(1,perf.Hit)));
TotalRef                    = sum(~isnan(cat(1,perf.FalseAlarm)));
TotalEarlyRef               = sum(cat(1,perf.EarlyTrial)==1);
TotalEarlyTar               = sum(cat(1,perf.EarlyTrial)==3);
perf(cnt2).EarlyRate        = (TotalEarlyTar+TotalEarlyRef)/(TotalTar+TotalRef);
perf(cnt2).HitRate          = sum(cat(1,perf.Hit)==1) /(TotalTar-TotalEarlyTar);
perf(cnt2).MissRate         = (TotalTar-sum(cat(1,perf.Hit)==1)-TotalEarlyTar) /(TotalTar-TotalEarlyTar);
perf(cnt2).FalseAlarmRate   = sum(cat(1,perf.FalseAlarm)==1) /(TotalRef-TotalEarlyRef);
perf(cnt2).CorrectRejectRate= (TotalRef-sum(cat(1,perf.FalseAlarm)==1)-TotalEarlyRef) /(TotalRef-TotalEarlyRef);
perf(cnt2).DiscriminationRate = perf(cnt2).HitRate * (1-perf(cnt2).FalseAlarmRate);

%also, calculate the stuff for this trial block:
RecentIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
tt = cat(1,perf(RecentIndex).FalseAlarm);
tt(find(isnan(tt)))=[];
perf(cnt2).RecentFalseAlarmRate   = sum(tt)/length(tt);
tt = cat(1,perf(RecentIndex).Hit);
tt(find(isnan(tt)))=[];
perf(cnt2).RecentHitRate         = sum(tt)/length(tt);
perf(cnt2).RecentDiscriminationRate = perf(cnt2).RecentHitRate * (1-perf(cnt2).RecentFalseAlarmRate);
%
% change all rates to percentage. If its not rate, put the sum and
% 'out of' at the end
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if isinf(perf(cnt2).(PerfFields{cnt1})) , perf(cnt2).(PerfFields{cnt1}) = 0;end   
    if ~isempty(strfind(PerfFields{cnt1},'Rate')) % if its a rate, do
        %not divide by number of trials, just make it percentage:
        if isnan(perf(cnt2).(PerfFields{cnt1})) , perf(cnt2).(PerfFields{cnt1}) = 0;end
        perfPer.(PerfFields{cnt1}) = round(perf(cnt2).(PerfFields{cnt1})*100);
    else
        if strcmpi(PerfFields{cnt1},'miss') || strcmpi(PerfFields{cnt1},'earlyTrial')
            perfPer.(PerfFields{cnt1})(1) = sum(mod(cat(1,perf.(PerfFields{cnt1})),2));
        elseif isnumeric(perf(cnt2).(PerfFields{cnt1}))
            temp=cat(1,perf.(PerfFields{cnt1}));
            temp(find(isnan(temp)))=[];
            perfPer.(PerfFields{cnt1})(1) = sum(temp);
        else
            perfPer.(PerfFields{cnt1}) = perf(cnt2).(PerfFields{cnt1});
        end
    end
end
%
% perf(cnt2)
exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;
%%%%%
% if the animal did not lick at all in the last three traget trials, stop
% the experiment
target_tr=find(~isnan(cat(1,perf.Hit)));
if isfield(exptparams,'Performance') && (length(target_tr)>3) && isempty(strfind(globalparams.Physiology,'Passive'))
    DidSheLick = cat(1,exptparams.Performance(target_tr(end-2:end)).LickRate);
    if sum(DidSheLick) == 0, StopExperiment = 1;end
end
if isfield(exptparams,'Water')
    exptparams.Performance(end).Water = exptparams.Water .* globalparams.PumpMlPerSec.Pump;
end
