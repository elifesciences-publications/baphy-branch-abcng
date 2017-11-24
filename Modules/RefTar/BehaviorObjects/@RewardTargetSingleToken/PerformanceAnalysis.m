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
StopTargetFA = get(o,'StopTargetFA');
EarlyWindow = exptparams.EarlyWindow;
%
RH = get(exptparams.TrialObject,'ReferenceHandle'); TH = get(exptparams.TrialObject,'TargetHandle');
RefResponseWin = [];
RefEarlyWin = [];
TarResponseWin = [];
TarEarlyWin    = [];
NumRef = 0;
% first, we find all the relevant time windows, which are ResponseWindow
% after reference and target, and EarlyWindow after target. Each sequence
% starts with $ sign.
for cnt1 = 1:length(StimEvents);
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim') %&& ~isempty(strfind(StimName,'$'))  % 15/06: YB (condition never filled in for TORC/Tone at least)
        if ~isempty(RefResponseWin)  % the response window should not go to the next sound!
            RefResponseWin(end) = min(RefResponseWin(end), StimEvents(cnt1).StartTime);
        end
        if strcmpi(StimRefOrTar,'Reference')          
          if ~strcmpi(class(RH),'TorcToneDiscrim') || ( strcmpi(class(RH),'TorcToneDiscrim') && isempty(strfind(upper(StimName),'TORC')) )
            RefEarlyWin = [RefEarlyWin StimEvents(cnt1).StartTime ...
              StimEvents(cnt1).StartTime + EarlyWindow];
            RefResponseWin = [RefResponseWin StimEvents(cnt1).StartTime + EarlyWindow ...
              StimEvents(cnt1).StartTime + get(o,'ResponseWindow') + EarlyWindow];
            NumRef = NumRef + 1;
          end
        else
          if ~strcmpi(class(TH),'TorcToneDiscrim') || ( strcmpi(class(TH),'TorcToneDiscrim') && isempty(strfind(upper(StimName),'TORC')) )
            TarResponseWin = [TarResponseWin StimEvents(cnt1).StartTime + EarlyWindow ...
              StimEvents(cnt1).StartTime + get(o,'ResponseWindow') + EarlyWindow];
            TarEarlyWin = [TarEarlyWin StimEvents(cnt1).StartTime ...
              StimEvents(cnt1).StartTime + EarlyWindow];
          end
        end
    end
end
% now, RefResponseWin is a vector that has the start and stop point of each
% reference response window, ex.: [1.2 1.4 3.2 3.4 5.2 5.4]
exptparams.RefResponseWin  = RefResponseWin;
% and TarResponseWin has specifies the begining and end of the target
% Response window, ex.: [6.2 6.4]
exptparams.TarResponseWin = TarResponseWin;
% and early window specifies the begining and end of the target early
% window:
exptparams.TarEarlyWin = TarEarlyWin;
% change the lick to positive edge only:
LickData = max(0,diff(LickData));
MotorLapse = get(o,'MotorLapse');
if MotorLapse>0
    if ~isempty(RefResponseWin); LickData(round(RefResponseWin(1)*fs)+(0:round(MotorLapse*fs))) = 0; end
    if ~isempty(TarResponseWin); LickData(round(TarResponseWin(1)*fs)+(0:round(MotorLapse*fs))) = 0; end
end
% what we need to procude here are:
%  1) histogram of first lick for each reference and target
%  2) false alarm for each reference, and hit for target at different positions
% first, extract the relevant lick data:
RefFalseAlarm = 0;RefFirstLick = NaN; FaTrial = 0;
for cnt2 = 1:NumRef
    cnt1 = (cnt2-1)*2+1;
    RefResponseLicks{cnt2} = LickData(max(1,round(fs*RefResponseWin(cnt1))):min(length(LickData),round(fs*RefResponseWin(cnt1+1))));
    RefEarlyLicks{cnt2} = LickData(max(1,round(fs*RefEarlyWin(cnt1))):min(length(LickData),round(fs*RefEarlyWin(cnt1+1))));
    temp = find([RefEarlyLicks{cnt2}; RefResponseLicks{cnt2}],1)/fs;
    if ~isempty(temp), RefFirstLick(cnt2) = temp; else RefFirstLick(cnt2) = nan;end
    RefFalseAlarm(cnt2) = double(~isempty(find(RefResponseLicks{cnt2},1)));
    if RefFalseAlarm(cnt2)
        FaTrial = 1;
    end
end

if isempty(TarResponseWin)   %for no target (sham trial)  by py&9/6/2012
    TarResponseLick=[];
else
    TarResponseLick = LickData(max(1,round(fs*TarResponseWin(1))):min(length(LickData),round(fs*TarResponseWin(2))));
end
% in an ineffective trial, discard the lick during target because target was never played:
FalseAlarm = sum(RefFalseAlarm)/NumRef;
if isempty(TarResponseWin)   %for no target (sham trial)  by py&9/6/2012
    TarEarlyLick=[];
    TarTrial = 0;
else
    TarTrial = 1;
%     TarEarlyLick = LickData(fs*max(1,TarEarlyWin(1)):min(length(LickData),fs*TarEarlyWin(2)));
    TarEarlyLick = LickData(max(1,round(fs*TarEarlyWin(1))):min(length(LickData),round(fs*TarEarlyWin(2))));   % 15/07: YB
end
if (FalseAlarm>=StopTargetFA)  % in ineffective
    TarResponseLick = zeros(size(TarResponseLick));
    TarEarlyLick    = zeros(size(TarEarlyLick));
end 
if ~isempty(find(TarEarlyLick,1)) % in early 
    TarResponseLick = zeros(size(TarResponseLick));
end    
TarFirstLick = find([TarEarlyLick ;TarResponseLick],1)/fs;
if isempty(TarFirstLick), TarFirstLick = nan;end
% a special performance is calculated here for the graph that shows the hit
% and false alarm based on the position of the target/reference:
% record the first lick time for ref and tar
if isfield(exptparams,'FirstLick') 
    exptparams.FirstLick.Tar(end+1) = TarFirstLick;
    exptparams.FirstLick.Ref(end+1:end+length(RefFirstLick)) = RefFirstLick;
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
    prevNumRefTot = perf(cnt2-1).NumRefTot; prevNumLickedRefTot = perf(cnt2-1).NumLickedRefTot;
else
    cnt2 = 1;
    prevNumRefTot = 0; prevNumLickedRefTot = 0;
end
perf(cnt2).ThisTrial    = '??';
perf(cnt2).TarTrial    = TarTrial; perf(cnt2).FaTrial    = FaTrial;
if NumRef
    perf(cnt2).FalseAlarm   = sum(RefFalseAlarm)/NumRef; % sum of false alarms divided by num of ref
    perf(cnt2).NumRefTot   = prevNumRefTot+NumRef; % sum of false alarms divided by num of ref
    perf(cnt2).NumLickedRefTot   = prevNumLickedRefTot+sum(RefFalseAlarm); 
else
    perf(cnt2).FalseAlarm = NaN;
    perf(cnt2).NumRefTot   = prevNumRefTot+0; % sum of false alarms divided by num of ref
    perf(cnt2).NumLickedRefTot   = prevNumLickedRefTot+sum(RefFalseAlarm); 
end
if perf(cnt2).NumRefTot==0
  perf(cnt2).FaRate = 0;
else
  perf(cnt2).FaRate = perf(cnt2).NumLickedRefTot/perf(cnt2).NumRefTot;
end
perf(cnt2).Ineffective  = double(~isempty(find(TarEarlyLick,1)));
perf(cnt2).WarningTrial = double(~perf(cnt2).Ineffective);
% perf(cnt2).EarlyTrial   = double(perf(cnt2).WarningTrial && ~isempty(find(TarEarlyLick,1)));
perf(cnt2).EarlyTrial   = double(~isempty(find(TarEarlyLick,1)));
%
perf(cnt2).Hit          = double(perf(cnt2).WarningTrial && ~perf(cnt2).EarlyTrial && ~isempty(find(TarResponseLick,1))); % if there is a lick in target response window, its a hit
perf(cnt2).Miss         = double(perf(cnt2).WarningTrial && ~perf(cnt2).EarlyTrial && ~perf(cnt2).Hit && perf(cnt2).TarTrial);
perf(cnt2).CR         = double(perf(cnt2).WarningTrial && ~perf(cnt2).FaTrial && ~perf(cnt2).TarTrial);
MaxRef = get(exptparams.TrialObject,'MaxRef');
if MaxRef == 1   % specific case where lick post REF and lick during TAR are counted as ineffective
    perf(cnt2).Catch         = double((get(exptparams.TrialObject,'MaxRef'))==NumRef);
else
    perf(cnt2).Catch         = double((get(exptparams.TrialObject,'MaxRef')+1)==NumRef);
end
perf(cnt2).ReferenceLickTrial = double((perf(cnt2).FalseAlarm>0));
%
perf(cnt2).LickRate = length(find(LickData)) / length(LickData);
% Now calculate hit and miss rates:
TotalWarn                   = sum(cat(1,perf.WarningTrial));
TotalWarnTarAndNoCatch         = sum([perf.WarningTrial] & [perf.TarTrial]);
perf(cnt2).HitRate          = sum(cat(1,perf.Hit)) / TotalWarnTarAndNoCatch;
perf(cnt2).MissRate         = sum(cat(1,perf.Miss)) / TotalWarnTarAndNoCatch;
perf(cnt2).EarlyRate        = sum(cat(1,perf.EarlyTrial))/TotalWarn;
perf(cnt2).WarningRate      = sum(cat(1,perf.WarningTrial))/TrialIndex;
perf(cnt2).IneffectiveRate  = sum(cat(1,perf.Ineffective))/sum([perf.TarTrial]);
% this is for trials without Reference. We dont count them in FalseAlarm
% calculation:
tt = cat(1,perf.FalseAlarm);
tt(find(isnan(tt)))=[];
perf(cnt2).FalseAlarmRate   = sum(tt)/length(tt);
% perf(cnt2).DiscriminationRate = perf(cnt2).HitRate * (1-perf(cnt2).FalseAlarmRate);
if perf(cnt2).HitRate==0
  perf(cnt2).DiscriminationRate = 0;
elseif perf(cnt2).FaRate==0
  perf(cnt2).DiscriminationRate = 0;
elseif perf(cnt2).HitRate==1
  HitRate = (sum(cat(1,perf.Hit))-1) / TotalWarnTarAndNoCatch;
  perf(cnt2).DiscriminationRate =  norminv(HitRate)-norminv(perf(cnt2).FaRate);
else
  perf(cnt2).DiscriminationRate =  norminv(perf(cnt2).HitRate)-norminv(perf(cnt2).FaRate);
end
%also, calculate the stuff for this trial block:
RecentIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
tt = cat(1,perf(RecentIndex).FalseAlarm);
tt(find(isnan(tt)))=[];
perf(cnt2).RecentFalseAlarmRate   = sum(tt)/length(tt);
perf(cnt2).RecentHitRate         = sum(cat(1,perf(RecentIndex).Hit))/sum(cat(1,perf(RecentIndex).WarningTrial));
perf(cnt2).RecentDiscriminationRate = perf(cnt2).RecentHitRate * (1-perf(cnt2).RecentFalseAlarmRate);
%

% now determine what this trial is:
if perf(cnt2).Hit, perf(cnt2).ThisTrial = 'Hit';end
if perf(cnt2).Miss, perf(cnt2).ThisTrial = 'Miss';end
if perf(cnt2).CR, perf(cnt2).ThisTrial = 'Correct Rejection';end
if perf(cnt2).FaTrial, perf(cnt2).ThisTrial = 'False Alarm';end
if perf(cnt2).Ineffective, perf(cnt2).ThisTrial = 'Ineffective';end
if perf(cnt2).EarlyTrial, perf(cnt2).ThisTrial = 'Early';end
fprintf(['d''=' num2str(perf(cnt2).DiscriminationRate) '  /  ' upper( perf(cnt2).ThisTrial ) '  '])
% change all rates to percentage. If its not rate, put the sum and
% 'out of' at the end
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if isinf(perf(cnt2).(PerfFields{cnt1})) , perf(cnt2).(PerfFields{cnt1}) = 0;end
    if isnan(perf(cnt2).(PerfFields{cnt1})) , perf(cnt2).(PerfFields{cnt1}) = 0;end
    if ~isempty(strfind(PerfFields{cnt1},'Rate')) % if its a rate, do
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
if ~isfield(exptparams,'PositionHit')  || (size(exptparams.PositionHit,1)<NumRef+1) 
    exptparams.PositionHit(NumRef+1,1:2) = 0;
end
if (NumRef>0) && ((~isfield(exptparams,'PositionFalseAlarm')) ...
    || (size(exptparams.PositionFalseAlarm,1)<NumRef))        
    exptparams.PositionFalseAlarm(NumRef,1:2) = 0;
end
if perf(cnt2).WarningTrial && ~isempty(TarResponseWin)  %py modified @9-6/2012
    exptparams.PositionHit(NumRef+1,1) = exptparams.PositionHit(NumRef+1,1) + perf(cnt2).Hit;
    exptparams.PositionHit(NumRef+1,2) = exptparams.PositionHit(NumRef+1,2) + 1;
end
for cnt1 = 1:NumRef
    exptparams.PositionFalseAlarm (cnt1,1) = exptparams.PositionFalseAlarm(cnt1,1) + RefFalseAlarm(cnt1);
    exptparams.PositionFalseAlarm (cnt1,2) = exptparams.PositionFalseAlarm(cnt1,2) + 1;
end
% perf(cnt2)
exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;
%%%%%
% if the animal did not lick at all in the last two experiment, stop the
% trial:
target_tr=find(~isnan(cat(1,perf.Hit)));
if isfield(exptparams,'Performance') && (length(target_tr)>2) && isempty(strfind(globalparams.Physiology,'Passive'))
    DidSheLick = cat(1,exptparams.Performance(target_tr(end-2:end)).LickRate);
%     if sum(DidSheLick) == 0, StopExperiment = 1;end  % 15/08-YB
end
if isfield(exptparams,'Water')
    exptparams.Performance(end).Water = exptparams.Water .* globalparams.PumpMlPerSec.Pump;
end
