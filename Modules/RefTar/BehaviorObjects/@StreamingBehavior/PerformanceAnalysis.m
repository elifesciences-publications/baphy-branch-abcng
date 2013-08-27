function exptparams = PerformanceAnalysis (o, HW, StimEvents, globalparams, exptparams, TrialIndex, LickData);
% Using PreTargetLickWindow (which might include licks during the target based on the value of the IncludeLickDuringTarget flag), the performance measures are defined as follows. A trial is called Sham if there is no target, and Target if there is.
% 
%     * Hit: In a target trial, animal licks in Pre but not in Pos
%     * Miss: In a target trial, animal licks in Pre and also in Pos
%     * Snooze Hit: In a target trial, animal does not lick in Pre, nor licks during the Pos
%     * Snooze Miss: In a target trial, animal does not lick in Pre, but does lick in Pos
%     * Snooze : In a target trial, animal does not lick in Pre
%     * ShamHit : In a sham trial, animal licks in Pre but not in Pos
%     * ShamMiss : In a sham trial, animal licks in Pre and also in Pos
%     * ShamSnoozeHit : In a sham trial, animal does not lick in Pre, but licks in Pos
%     * ShamSnoozeMiss : In a sham trial, animal does not lick in Pre, nor licks during the Pos
%     * HitRate : = (number of hits)/(number of hits + misses)
%     * Snooze hit rate : = (number of snooze hits)/ (number of snooze hits + snooze misses).
%     * ShamHitRate : = (number of sham hits)/(number of sham hits + sham misses)
%     * ShamSnooze hit rate : = (number of ShamSnooze hits)/ (number of Shamsnooze hits + sham snooze misses).
%     * LickRate: percentage of lick time to total time 
% 

% if there is paw signal, take it out:
if size(LickData,2)>1,
    LickData = LickData(:,1);
end
fs = HW.params.fsAI;
%
PreWin = [];
PostWin = [];
for cnt1 = 1:length(StimEvents);
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(StimRefOrTar,'Target') | strcmpi(StimRefOrTar,'Sham')
        PreWin  = [StimEvents(cnt1).StartTime - get(exptparams.BehaveObject,'PreTargetWindow') ...
            StimEvents(cnt1).StartTime];
        break;
    end
end
PostWin = [StimEvents(end).StartTime ... % assuming the last StimEvents is always the poststim silence
    StimEvents(end).StartTime + get(exptparams.BehaveObject,'PostTargetWindow')];
exptparams.PreWin  = PreWin;
exptparams.PostWin = PostWin;
% obtain the average lick for different B'
if ~isfield(exptparams,'Lick')
    ToneF = [];
    Lick = [];
else
    ToneF = cat(1,exptparams.Lick.Freq);
    Lick  = exptparams.Lick;
end
[Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1+1));
ThisToneF = str2num(StimName(6:end));
% see if its a new frequency
[index]=find(ThisToneF==ToneF);
if isempty(index)
    Lick(end+1).Ave = LickData([max(1,round(fs*(PreWin(1)-1))):min(length(LickData),round(fs*PostWin(2)))]);    
    Lick(end).Num = 1;
    Lick(end).Freq = ThisToneF;
else
    temp = LickData([max(1,round(fs*(PreWin(1)-1))):min(length(LickData),round(fs*PostWin(2)))]);    
    temp(end+1:length(Lick(index).Ave)) = 0;
    Lick(index).Ave(end+1:length(temp))=0;
    Lick(index).Ave = Lick(index).Ave + temp;
    Lick(index).Num = Lick(index).Num + 1;
end
exptparams.Lick = Lick;
%
[Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(end));
IsSham = strcmpi(StimRefOrTar,'sham');
% Now analyze the lick signal
PreLick  = ~isempty(find(LickData(ceil(max(1,fs*PreWin(1)) :max(1,fs*PreWin(2))))==1));
PostLick = ~isempty(find(LickData(ceil(max(1,fs*PostWin(1)):min(length(LickData),fs*PostWin(2))))==1));
% extract the lick signam and determine which B' it belongs to, then add it
% to the previous value and keep the number of samples for the averaging
% purpose. 




% now calculate the performance:
if isfield(exptparams, 'Performance')
    perf = exptparams.Performance(1:end-1);
    cnt2 = length(perf) + 1;
else
    cnt2 = 1;
end
perf(cnt2).ThisTrial = 'Sham';
perf(cnt2).Hit = 0;
perf(cnt2).Miss = 0;
perf(cnt2).SnoozeHit = 0;
perf(cnt2).SnoozeMiss = 0;
perf(cnt2).Snooze = 0;
perf(cnt2).ShamHit = 0;
perf(cnt2).ShamMiss = 0;
perf(cnt2).ShamSnoozeHit = 0;
perf(cnt2).ShamSnoozeMiss = 0;
% perf(cnt2).WarningTrial = PreLick;
% perf(cnt2).SnoozeTrial  = ~PreLick;
perf(cnt2).Sham = double(IsSham);
switch [num2str(IsSham) ' ' num2str(PreLick) ' ' num2str(PostLick)]
    case '0 0 0', % Snooze Hit
        perf(cnt2).SnoozeHit = 1;
        perf(cnt2).Snooze = 1;
        perf(cnt2).ThisTrial = 'SnoozeHit';
    case '0 0 1', % SnoozeMiss
        perf(cnt2).SnoozeMiss = 1;
        perf(cnt2).Snooze = 1;
        perf(cnt2).ThisTrial = 'SnoozeMiss';
    case '0 1 0', % Hit
        perf(cnt2).Hit = 1;
        perf(cnt2).ThisTrial = 'Hit';
    case '0 1 1', % Miss
        perf(cnt2).Miss = 1;
        perf(cnt2).ThisTrial = 'Miss';
    case '1 0 0', % Sham Snooze Hit
        perf(cnt2).ShamSnoozeHit = 1;
        perf(cnt2).ThisTrial = 'ShamSnoozeHit';        
    case '1 0 1', % Sham SnoozeMiss
        perf(cnt2).ShamSnoozeMiss = 1;
        perf(cnt2).ThisTrial = 'ShamSnoozeMiss';
    case '1 1 0', % Sham Hit
        perf(cnt2).ShamHit = 1;
        perf(cnt2).ThisTrial = 'ShamHit';
    case '1 1 1', % ShamMiss
        perf(cnt2).ShamMiss = 1;
        perf(cnt2).ThisTrial = 'ShamMiss';
end
perf(cnt2).LickRate = length(find(LickData)) / length(LickData);
% Now calculate hit and miss rates:
perf(cnt2).HitRate = sum(cat(1,perf.Hit)) / (sum(cat(1,perf.Hit))+sum(cat(1,perf.Miss)));
if isnan(perf(cnt2).HitRate) perf(cnt2).HitRate = 0;end
% and SnoozeHit and Snooze miss rates:
perf(cnt2).SnoozeHitRate = sum(cat(1,perf.SnoozeHit)) / ...
    (sum(cat(1,perf.SnoozeHit))+sum(cat(1,perf.SnoozeMiss)));
if isnan(perf(cnt2).SnoozeHitRate) perf(cnt2).SnoozeHitRate = 0;end
%
% Now calculate sham hit and miss rates:
perf(cnt2).ShamHitRate = sum(cat(1,perf.ShamHit)) / ...
    (sum(cat(1,perf.ShamHit))+sum(cat(1,perf.ShamMiss)));
if isnan(perf(cnt2).ShamHitRate) perf(cnt2).ShamHitRate = 0;end
% and SnoozeHit and Snooze miss rates:
perf(cnt2).ShamSnoozeHitRate = sum(cat(1,perf.ShamSnoozeHit)) / ...
    (sum(cat(1,perf.ShamSnoozeHit))+sum(cat(1,perf.ShamSnoozeMiss)));
if isnan(perf(cnt2).ShamSnoozeHitRate) perf(cnt2).ShamSnoozeHitRate = 0;end
%
% Now prepare one for display purpose and put it in last array of
% performance:
% change all rates to percentage. If its not rate, put the sum and
% 'out of'
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if ~isempty(strfind(PerfFields{cnt1},'Rate')) % if its a rate, do
        %not divide by number of trials, just make it percentage:
        perfPer.(PerfFields{cnt1}) = perf(cnt2).(PerfFields{cnt1})*100;
    else
        if isnumeric(perf(cnt2).(PerfFields{cnt1}))
            perfPer.(PerfFields{cnt1})(1) = sum(cat(1,perf.(PerfFields{cnt1})));
            perfPer.(PerfFields{cnt1})(2) = TrialIndex; % by default
        else
            perfPer.(PerfFields{cnt1}) = perf(cnt2).(PerfFields{cnt1});
        end
    end
end
% Now put 'out of' field. If its hit, miss, its out of
% TrialIndex-Shams-Snoozes:
perfPer.Hit(2)          = perfPer.Hit(1)+perfPer.Miss(1);
perfPer.Miss(2)         = perfPer.Hit(1)+perfPer.Miss(1);
perfPer.Snooze(2)       = TrialIndex - sum(cat(1,perf.Sham));
perfPer.SnoozeHit(2)    = perfPer.SnoozeHit(1)+perfPer.SnoozeMiss(1);
perfPer.SnoozeMiss(2)   = perfPer.SnoozeHit(1)+perfPer.SnoozeMiss(1);
%
perfPer.ShamHit(2)          = perfPer.ShamHit(1)+perfPer.ShamMiss(1);
perfPer.ShamMiss(2)         = perfPer.ShamHit(1)+perfPer.ShamMiss(1);
perfPer.ShamSnoozeHit(2)    = perfPer.ShamSnoozeHit(1)+perfPer.ShamSnoozeMiss(1);
perfPer.ShamSnoozeMiss(2)   = perfPer.ShamSnoozeHit(1)+perfPer.ShamSnoozeMiss(1);
%
exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;
%%%%%
