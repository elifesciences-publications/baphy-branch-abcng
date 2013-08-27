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

% PBY  4/01/2012
% 

global StopExperiment;
if size(LickData,2)>1,
    LickData = double(LickData(:,1)>0);
end
fs = HW.params.fsAI;
Trial_len=exptparams.LogDuration*fs;
if length(LickData)>Trial_len;
    LickData(Trial_len+1:end)=[];   %make all trials have same length lick data
else  % padded woth zero (unlikly)
    LickData(Trial_len)=0;
end

[t,trial,Note,toff,StimIndex] = evtimes(StimEvents,'Stim*');
%stidur = StimEvents(StimIndex).StopTime-StimEvents(StimIndex).StartTime;
[Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(StimIndex));
stimOnset=StimEvents(StimIndex).StartTime;
ResponseWin = [0 get(o,'ShockWindow')] + stimOnset + get(o,'EarlyWindow');
EarlyWin=[0 get(o,'EarlyWindow')]+stimOnset;
exptparams.ResponseWin  = ResponseWin;

% first, extract the relavant lick data:
ResponseLicks = LickData(max(1,fs*ResponseWin(1)):min(length(LickData),fs*ResponseWin(2)));  %lick during response win
EarlyLicks = LickData(max(1,fs*EarlyWin(1)):min(length(LickData),fs*EarlyWin(2)));           %lick during early win
preLicks=LickData(max(1,1:min(length(LickData),fs*stimOnset)));                              %lick pre stim onset

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

% now calculate the performance:
if isfield(exptparams, 'Performance') 
    perf = exptparams.Performance(1:end-1);
    cnt2 = length(perf) + 1;
else
    cnt2 = 1;
end
perf(cnt2).ThisTrial='??';
perf(cnt2).SnoozyTrial=0;
perf(cnt2).Miss=0;
perf(cnt2).Hit=0;
perf(cnt2).FalseAlarm=0;
perf(cnt2).respMat=[0 stimnum];

if isempty(find(EarlyLicks,1)) && isempty(find(preLicks,1))   %define a early stop trial (ineffective trial)
    perf(cnt2).SnoozyTrial=1;
end
if strcmpi(StimRefOrTar,'Reference')
    perf(cnt2).FalseAlarm   = double(isempty(find(ResponseLicks,1))); %
    perf(cnt2).Hit=NaN;
    perf(cnt2).Miss=NaN;
    if ~perf(cnt2).SnoozyTrial
        if perf(cnt2).FalseAlarm
            perf(cnt2).ThisTrial = 'FalseAlarm';
            perf(cnt2).respMat(1)=1;                %stop lick resp
        else
            perf(cnt2).ThisTrial = 'CorrectReject';
            perf(cnt2).respMat(1)=2;                % lick ....
        end
    else
        if perf(cnt2).FalseAlarm
            perf(cnt2).ThisTrial = 'SN FalseAlarm';
            perf(cnt2).respMat(1)=3;                %stop lick resp
        else
            perf(cnt2).ThisTrial = 'SN CorrectReject';
            perf(cnt2).respMat(1)=4;                % lick ....
        end        
    end
else
    perf(cnt2).FalseAlarm = NaN;
    perf(cnt2).Hit=double(isempty(find(ResponseLicks,1))); %
    perf(cnt2).Miss=double(~perf(cnt2).Hit);
    if ~perf(cnt2).SnoozyTrial
        if perf(cnt2).Hit
            perf(cnt2).ThisTrial = 'Hit';
            perf(cnt2).respMat(1)=1;                %stop lick resp
        else
            perf(cnt2).ThisTrial = 'Miss';
            perf(cnt2).respMat(1)=2;                %lick ...
        end
    else
        if perf(cnt2).Hit
            perf(cnt2).ThisTrial = 'SN Hit';
            perf(cnt2).respMat(1)=3;                %stop lick resp
        else
            perf(cnt2).ThisTrial = 'SN Miss';
            perf(cnt2).respMat(1)=4;                %lick ...
        end
    end
end

perf(cnt2).LickRate = length(find(LickData)) / length(LickData);
% Now calculate hit and miss rates:
TotalWarnTar                  = sum(~isnan(cat(1,perf.Hit)) & ~cat(1,perf.SnoozyTrial));
TotalWarnRef                  = sum(isnan(cat(1,perf.Hit)) & ~cat(1,perf.SnoozyTrial));
TotalSnoozyRef                = sum(isnan(cat(1,perf.Hit)) & cat(1,perf.SnoozyTrial));
TotalSnoozyTar                = sum(~isnan(cat(1,perf.Hit)) & cat(1,perf.SnoozyTrial));
perf(cnt2).HitRate            = sum(cat(1,perf.Hit)==1 & ~cat(1,perf.SnoozyTrial)) /(TotalWarnTar);
perf(cnt2).MissRate           = sum(cat(1,perf.Hit)==0 & ~cat(1,perf.SnoozyTrial)) /(TotalWarnTar);

perf(cnt2).FalseAlarmRate     = sum(cat(1,perf.FalseAlarm)==1 & ~cat(1,perf.SnoozyTrial)) /(TotalWarnRef);
perf(cnt2).CorrectRejectRate  = sum(cat(1,perf.FalseAlarm)==0 & ~cat(1,perf.SnoozyTrial)) /(TotalWarnRef);

perf(cnt2).SNHitRate          = sum(cat(1,perf.Hit)==1 & cat(1,perf.SnoozyTrial)) /(TotalSnoozyTar);
perf(cnt2).SNFalseAlarmRate   = sum(cat(1,perf.FalseAlarm)==1 & cat(1,perf.SnoozyTrial)) /(TotalSnoozyRef);
perf(cnt2).DiscriminationRate = perf(cnt2).HitRate * (1-perf(cnt2).FalseAlarmRate);

%also, calculate the stuff for this trial block:
RecentIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
tt = [cat(1,perf(RecentIndex).FalseAlarm) cat(1,perf(RecentIndex).SnoozyTrial)];
tt(isnan(tt(:,1)) | tt(:,2)==1,:)=[];  %remove target    &  SN
if ~isempty(tt)
    perf(cnt2).RecentFalseAlarmRate   = sum(tt(:,1))/length(tt(:,1));
else
    perf(cnt2).RecentFalseAlarmRate   =0;
end

tt = [cat(1,perf(RecentIndex).Hit) cat(1,perf(RecentIndex).SnoozyTrial)];
tt(isnan(tt(:,1)) | tt(:,2)==1,:)=[];  %remove target    &  SN
if ~isempty(tt)
    perf(cnt2).RecentHitRate         = sum(tt(:,1))/length(tt(:,1));
else
    perf(cnt2).RecentHitRate   =0;
end

perf(cnt2).RecentDiscriminationRate = perf(cnt2).RecentHitRate * (1-perf(cnt2).RecentFalseAlarmRate);
if isfield(exptparams,'Water')
    perf(cnt2).Water = exptparams.Water;
else
    perf(cnt2).Water =0; 
end
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
        if strcmpi(PerfFields{cnt1},'respMat')
            temp=cat(1,perf.(PerfFields{cnt1}));
            perfPer.(PerfFields{cnt1})=[sum(mod(temp(:,1),2)==1) size(temp,1)];
        elseif isnumeric(perf(cnt2).(PerfFields{cnt1}))
            temp=cat(1,perf.(PerfFields{cnt1}));
            temp(find(isnan(temp)))=[];
            perfPer.(PerfFields{cnt1}) = sum(temp);
        else
            perfPer.(PerfFields{cnt1}) = perf(cnt2).(PerfFields{cnt1});
        end
    end
end
%
% perf(cnt2)
exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;
totalRef=TotalWarnRef+TotalSnoozyRef;
totalTar=TotalWarnTar+TotalSnoozyTar;
if ~isfield(exptparams,'RefLick');
    exptparams.RefLick=0; end
if ~isfield(exptparams,'TarLick');
    exptparams.TarLick=0; end
if strcmpi(StimRefOrTar,'Reference')
    if totalRef==1
        exptparams.RefLick=LickData;  %average lick rate for reference
    else
        exptparams.RefLick=(exptparams.RefLick*(totalRef-1)+LickData)/totalRef; %average lick rate for reference
    end
else
    if totalTar==1
        exptparams.TarLick=LickData;
    else
        exptparams.TarLick=(exptparams.TarLick*(totalTar-1)+LickData)/totalTar;  %average lick rate for target
    end
end
%%%%%
% if the animal did not lick at all in the last three consecutive trials, stop
% the experiment
if isfield(exptparams,'Performance') && (cnt2>3) && isempty(strfind(globalparams.Physiology,'Passive'))
    DidSheLick = cat(1,exptparams.Performance(end-2:end).LickRate);
    if sum(DidSheLick) == 0, StopExperiment = 1;end
end
