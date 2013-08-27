function exptparams = PerformanceAnalysis (o, HW, StimEvents, globalparams, exptparams, TrialIndex, LickData)
% Target Lick Analysis ? : Using PreTargetLickWindow (which might
% include licks during the target based on the value of the
% IncludeLickDuringTarget flag), the performance measures are
% defined as follows:
%   Hit: Animal licks in Pre but not in Pos
%   Miss: Animal licks  in Pre and also in Pos
%   Snooze: Animal does not lick in Pre
%   Snooze Hit: Animal does not lick in Pre, nor licks during
%       the Pos
%   Snooze Miss: Animal does not lick in Pre, but does
%       lick in Pos
%
% Based on these measures, a hit rate is calculated as:
%    HitRate =
%   (number of hits)/(number of hits + misses)
% Note miss rate = (1- hit rate)
%
% Also a snooze hit rate is calculated as =
%         (number of snooze hits)/ (number of snooze hits +
% snooze misses). Note snooze miss rate = (1 ? snooze hit rate)
%
% Reference Lick Analysis ? Stimuli: Using PreTargetLickWindow
% (which might include licks during reference based on the value of
% the IncludeLickDuringTarget flag), the performance measures are
% defined as follows:
%   Safe: Animal licks in Pre and in Pos
%   False Positive: Animal licks in Pre but not in Pos
%   Snooze: Animal does not lick in Pre
%   Snooze Safe: Animal does not lick in Pre, but does lick
%       during the Pos
%   Snooze False Positive: Animal does not lick
%       in Pre, AND does not lick in Pos
%
% Based on these measures, a safe rate is calculated = (number of
% safe events)/(number of safe events + false positive events). The
% false positive rate is just =(1 ? (safe rate). The discrimination
% rate = (hit rate) * (safe rate). Also a snooze safe rate is
% calculated = (number of snooze safe events)/ (number of snooze
% safe events + snooze false positive events).
%
% The lick rate is calculated as the number of licks (or lick
% duration) divided by the duration of the time window being
% measured. For more discussion, see section on lick rate analysis.

% First find all the pre(Ref/Tar) and pos(Ref/Tar) lick windows.
% Then determine whether the ferret licked during any of these
% windows. Finally, calculate the performance:


% This method is adjusted from the performanceAnalysis method of PunishTarget. 
% 
% One is that one repetition is one run through the adaptive stair step procedure. 
% A trial is equivalent to a trial in the PunishTarget Object
% Recent block here unlike the PunishTarget performanceAnalysis is not
% equivalent to the last 10 trials. It is equivalent to the recent block of
% trials that has the same attenuation level for the masker. once a
% reversal takes place. the recent block performance variables are reset.
%
% There is no overall perfomance meausres that span the length of the all
% the repetition or run through. 
% if there is paw signal, take it out:
if size(LickData,2)>1,
    LickData = LickData(:,1);
end


SalientWin = [];
fs = HW.params.fsAI;
NumOfRef = 0;
AllRefLickHist = {};
%
NumOfEvPerStim = get(exptparams.TrialObject,'NumOfEvPerStim'); % how many sounds we have in each stim? ex: torc=3, discrim=6, etc..
if isfield(get(exptparams.TrialObject),'NumOfEvPerRef'),
    NumOfEvPerRef = get(exptparams.TrialObject,'NumOfEvPerRef');
    NumOfEvPerTar = get(exptparams.TrialObject,'NumOfEvPerTar');
else
    NumOfEvPerRef = NumOfEvPerStim;
    NumOfEvPerTar = NumOfEvPerStim;
end
IsSham = 1;
cnt1 = 1;
while cnt1<length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim');
        if strcmpi(StimRefOrTar,'Reference')
            cnt2 = cnt1 + NumOfEvPerRef-3;
        else
            cnt2 = cnt1 + NumOfEvPerTar-3;
        end
        NumOfRef = NumOfRef + strcmpi(StimRefOrTar,'Reference');
        % check the IncludeLickDuring flag:
        if get(o,'IncludeLickDuring')
            SalientWin(end+1).PreWin = [StimEvents(cnt1).StartTime - get(o,'PreLickWindow') ...
                StimEvents(cnt1).StopTime];
        else
            SalientWin(end+1).PreWin = [StimEvents(cnt1).StartTime - get(o,'PreLickWindow')  ...
                StimEvents(cnt1).StartTime];
        end
        SalientWin(end).PosWin = [(StimEvents(cnt2).StopTime + get(o,'ResponseTime'))  ...
            (StimEvents(cnt2).StopTime + get(o,'ResponseTime') + get(o,'PostLickWindow'))];
        SalientWin(end).RefOrTar = StimRefOrTar;
        % max in the following line prohibit the negaive or
        % zero indexing:
        SalientWin(end).PreLick = ...
            ~isempty(find(LickData(ceil(max(1,fs*SalientWin(end).PreWin(1)):...
            max(1,fs*SalientWin(end).PreWin(2)))),1));
        SalientWin(end).PosLick = ...
            ~isempty(find(LickData(ceil(fs*SalientWin(end).PosWin(1):min(length(LickData),fs*SalientWin(end).PosWin(2)))),1));
        % In the following block, we obtain the lick histogram for
        % reference and target and put them in exptparams to be
        % displayed:
        if strcmpi(StimRefOrTar,'Reference')
            AllRefLickHist{end+1} = LickData(ceil(max(1,fs*SalientWin(end).PreWin(1)))...
                :ceil(min(length(LickData),fs*SalientWin(end).PosWin(2))));
            % For displaying the Lick histogram of reference, find
            % the boundaries:
            RefBound = 0;
            RefBound = [RefBound get(o,'PreLickWindow')]; % PreStimSilence
            RefBound = [RefBound RefBound(end)+StimEvents(cnt2).StopTime-StimEvents(cnt1).StartTime]; % Ref
            RefBound = [RefBound RefBound(end)+get(o,'ResponseTime')]; % response window
            RefBound = [RefBound RefBound(end)+get(o,'PostLickWindow')];
        else
            IsSham = 0;
            TarBound= 0;
            TarBound= [TarBound get(o,'PreLickWindow')]; % PreStimSilence
            TarBound= [TarBound TarBound(end)+StimEvents(cnt2).StopTime-StimEvents(cnt1).StartTime]; % Ref
            TarBound= [TarBound TarBound(end)+get(o,'ResponseTime')]; % response window
            TarBound= [TarBound TarBound(end)+get(o,'PostLickWindow')];
            TarLickHist = LickData(ceil(max(1,fs*SalientWin(end).PreWin(1))):...
                min(length(LickData),ceil(fs*SalientWin(end).PosWin(2))));
            % Also get the name of the target sound:
            TargetName = StimName;
            % also, if there was no shock make sure it doesnt have it.:
            % this is to fix the mismatch between behavior and performance
            if isfield(exptparams,'ThereWasShock') && ~exptparams.ThereWasShock && ...
                ~isfield(exptparams,'OfflineAnalysis') 
%                 TarLickHist = zeros(size(TarLickHist));
                SalientWin(end).PosLick = 0;
            end
        end
        if strcmpi(StimRefOrTar,'Reference')
            cnt1 = cnt1 + NumOfEvPerRef-3;
        else
            cnt1 = cnt1 + NumOfEvPerTar-3;
        end
    end
    cnt1 = cnt1 + 1;
end
% get a histogram of lick based on salient window. One for
% reference, one for target and one for all.
if ~isfield(exptparams, 'AllRefLick') || (TrialIndex ==1)
    exptparams.TarLick.Hist     = 0;
    exptparams.TarLick.Num      = 0;
    exptparams.TarLick.Bound    = 0;
    exptparams.AllRefLick.Hist    = [];
    exptparams.AllRefLick.Bound   = [];
    exptparams.AllRefLick.Num     = [];
    exptparams.TrialObject.TrialdB = exptparams.TrialObject.OveralldB; %%% This should equal something from Trial Object 
    exptparams.LastReversalLevels= [];
    exptparams.LastReversalIndx=[];
                                 
end
% Store the histogram, its total number and bounds for reference,
% target
% first, reference:
for cnt1 = 1:length(AllRefLickHist)
    if length(exptparams.AllRefLick.Hist)<cnt1
        % first time a trial with this length:
        exptparams.AllRefLick.Hist{cnt1} = AllRefLickHist{cnt1};
        exptparams.AllRefLick.Num(cnt1) = 1;
    else
        % we have had a trial with this length before, so add it
        exptparams.AllRefLick.Hist{cnt1}(end+1:length(AllRefLickHist{cnt1}),1)=0;
        exptparams.AllRefLick.Hist{cnt1}(1:length(AllRefLickHist{cnt1})) = ...
            exptparams.AllRefLick.Hist{cnt1}(1:length(AllRefLickHist{cnt1}))+AllRefLickHist{cnt1};
        exptparams.AllRefLick.Num(cnt1) = exptparams.AllRefLick.Num(cnt1)+1;
    end
end
exptparams.AllRefLick.Bound = RefBound;
% now the target:
if exist('TarLickHist','var')
    exptparams.TarLick.Hist(end+1:length(TarLickHist),1) = 0;
    exptparams.TarLick.Hist(1:length(TarLickHist))= ...
        exptparams.TarLick.Hist(1:length(TarLickHist)) + TarLickHist;
    exptparams.TarLick.Num=exptparams.TarLick.Num+1;
    exptparams.TarLick.Bound = TarBound;
end
exptparams.SalientWin = SalientWin; % this is used for display purpose
% adding the multi-target support:
% create a new structure that has the name of the targets and their
% corresponding performance. ALso, keep the original one for backward
% compatibility:

% initialize the performance data:
if isfield(exptparams, 'Performance') && (TrialIndex~=1) 
    perf = exptparams.Performance(1:end-1);
    cnt2 = length(perf) + 1;
else
    cnt2 = 1;
    if isfield(exptparams,'Performance'), exptparams = rmfield(exptparams,'Performance');end
end
perf(cnt2).ThisTrial = 'Sham';
perf(cnt2).Hit = 0; perf(cnt2).HitRate = 0; perf(cnt2).RecentHitRate=0;
perf(cnt2).Safe = 0; perf(cnt2).SafeRate = 0; perf(cnt2).RecentSafeRate=0;
perf(cnt2).DiscriminationRate = 0; perf(cnt2).RecentDiscriminationRate =0;
perf(cnt2).Miss = 0; perf(cnt2).MissRate = 0;
perf(cnt2).SnoozeHit = 0; perf(cnt2).SnoozeHitRate=0;
perf(cnt2).SnoozeMiss = 0; perf(cnt2).SnoozeMissRate = 0;
perf(cnt2).FalsePositive = 0; perf(cnt2).FalsePositiveRate = 0;
perf(cnt2).SnoozeSafe = 0; perf(cnt2).SnoozeSafeRate = 0;
perf(cnt2).SnoozeFalsePositive = 0; perf(cnt2).SnoozeRef = 0;perf(cnt2).SnoozeTar = 0;
perf(cnt2).Sham = IsSham;
perf(cnt2).TrialdB = exptparams.TrialObjects.TrialdB;
if (TrialIndex~=1) 
    perf(cnt2).StepSize= perf(cnt2-1).StepSize;
    perf(cnt2).ReversalInc= perf(cnt2-1).ReversalInc;
    perf(cnt2).HitNum=perf(cnt2-1).HitNum;
    perf(cnt2).ReversalNum= perf(cnt2-1).ReversalNum;
else
    perf(cnt2).StepSize= o.InitialStepSize;
    perf(cnt2).ReversalInc= 0;
    perf(cnt2).HitNum=0;
    perf(cnt2).ReversalNum= 0;
end
for cnt1 = 1:length(SalientWin)
    switch [SalientWin(cnt1).RefOrTar(1) ' ' num2str(SalientWin(cnt1).PreLick) ...
            ' ' num2str(SalientWin(cnt1).PosLick)]
        case 'R 0 0', % Snooze False positive
            perf(cnt2).SnoozeFalsePositive = perf(cnt2).SnoozeFalsePositive + 1/NumOfRef;
            perf(cnt2).SnoozeRef = perf(cnt2).SnoozeRef + 1/NumOfRef;
        case 'R 0 1', % Snooze Safe
            perf(cnt2).SnoozeSafe = perf(cnt2).SnoozeSafe + 1/NumOfRef;
            perf(cnt2).SnoozeRef = perf(cnt2).SnoozeRef + 1/NumOfRef;
        case 'R 1 0', % False Positive
            perf(cnt2).FalsePositive = perf(cnt2).FalsePositive + 1/NumOfRef;
        case 'R 1 1', % Safe
            perf(cnt2).Safe = perf(cnt2).Safe + 1/NumOfRef;
        case 'T 0 0', % Snooze Hit
            perf(cnt2).SnoozeHit = perf(cnt2).SnoozeHit + 1;
            perf(cnt2).SnoozeTar = perf(cnt2).SnoozeTar + 1;
            perf(cnt2).ThisTrial = 'Snooze Hit';
        case 'T 0 1', % Snooze Miss
            perf(cnt2).SnoozeMiss = perf(cnt2).SnoozeMiss + 1;
            perf(cnt2).SnoozeTar = perf(cnt2).SnoozeTar + 1;
            perf(cnt2).ThisTrial = 'Snooze Miss';
        case 'T 1 0', % Hit
            perf(cnt2).Hit = perf(cnt2).Hit + 1;
            perf(cnt2).ThisTrial = 'Hit';
            if perf(cnt2).HitNum==2
                perf(cnt2).HitNum=0;
                switch perf(cnt2).ReversalInc
                    case 0
                        perf(cnt2).ReversalInc =1;
                        perf(cnt2).TrialdB= perf(cnt2.TrialdB)+perf(cnt2).StepSize;
                        exptparams.TrialObjects.TrialdB= perf(cnt2).TrialdB;
                    case 1
                        perf(cnt2).TrialdB= perf(cnt2.TrialdB)+perf(cnt2).StepSize;
                        exptparams.TrialObjects.TrialdB= perf(cnt2).TrialdB;
                    case -1
                        perf(cnt2).ReversalInc =1;
                        perf(cnt2).ReversalNum= perf(cnt2).ReversalNum+1;
                        if perf(cnt2).ReversalNum==2
                            perf(cnt2).ReversalNum=0;
                            perf(cnt2).StepSize= perf(cnt2).StepSize/2;
                        end
                        perf(cnt2).TrialdB= perf(cnt2.TrialdB)+perf(cnt2).StepSize;
                        exptparams.TrialObjects.TrialdB= perf(cnt2).TrialdB;
                end
            else
                perf(cnt2).HitNum=perf(cnt2).HitNum+1;
            end
        case 'T 1 1', % Miss
            perf(cnt2).Miss = perf(cnt2).Miss + 1;
            perf(cnt2).ThisTrial = 'Miss';
            switch perf(cnt2).ReversalInc
                case 0
                    perf(cnt2).ReversalInc =-1;
                    perf(cnt2).TrialdB= perf(cnt2.TrialdB)-perf(cnt2).StepSize;
                    exptparams.TrialObjects.TrialdB= perf(cnt2).TrialdB;
                case 1
                    perf(cnt2).ReversalInc =-1;
                    perf(cnt2).ReversalNum= perf(cnt2).ReversalNum+1;
                    if perf(cnt2).ReversalNum==2
                        perf(cnt2).ReversalNum=0;
                        perf(cnt2).StepSize= perf(cnt2).StepSize/2;
                    end
                    perf(cnt2).TrialdB= perf(cnt2.TrialdB)-perf(cnt2).StepSize;
                    exptparams.TrialObjects.TrialdB= perf(cnt2).TrialdB;
                case -1
                    perf(cnt2).ReversalInc =-1;
                    perf(cnt2).TrialdB= perf(cnt2.TrialdB)-perf(cnt2).StepSize;
                    exptparams.TrialObjects.TrialdB= perf(cnt2).TrialdB;
            end
    end
end
% Now calculate hit and miss rates both for entire experiment and this
% block only:
perf(cnt2).HitRate              = sum(cat(1,perf.Hit)) / (sum(cat(1,perf.Hit)) + sum(cat(1,perf.Miss)));
perf(cnt2).SafeRate             = sum(cat(1,perf.Safe)) / (sum(cat(1,perf.Safe)) + sum(cat(1,perf.FalsePositive)));
perf(cnt2).DiscriminationRate   = perf(cnt2).HitRate * perf(cnt2).SafeRate;
perf(cnt2).MissRate             = 1 - perf(cnt2).HitRate;
perf(cnt2).FalsePositiveRate    = 1 - perf(cnt2).SafeRate;
perf(cnt2).SnoozeHitRate        = sum(cat(1,perf.SnoozeHit)) / (sum(cat(1,perf.SnoozeHit))+ ...
    sum(cat(1,perf.SnoozeMiss)));
perf(cnt2).SnoozeMissRate       = 1 - perf(cnt2).SnoozeHitRate;
perf(cnt2).SnoozeSafeRate       = sum(cat(1,perf.SnoozeSafe)) / (sum(cat(1,perf.SnoozeSafe)) + sum(cat(1,perf.SnoozeFalsePositive)));
% also, a smooth version is necessary for the shortterm display:
x= struct2cell(perf); y =cell2matt(x(24,:,:));
RecentIndex = find(y==exptparams.TrialObjects.TrialdB);
perf(cnt2).RecentHitRate         = sum(cat(1,perf(RecentIndex).Hit))  / ...
    (sum(cat(1,perf(RecentIndex).Hit)) + sum(cat(1,perf(RecentIndex).Miss)));
perf(cnt2).RecentSafeRate        = sum(cat(1,perf(RecentIndex).Safe)) / ...
    (sum(cat(1,perf(RecentIndex).Safe))+ sum(cat(1,perf(RecentIndex).FalsePositive)));
perf(cnt2).RecentDiscriminationRate = perf(cnt2).RecentHitRate * perf(cnt2).RecentSafeRate;
if perf(cnt2).StepSize ==2; %dB
    exptparams.LastReversalLevels=[exptparams.LastReversalLevels,perf(cnt2).TrialdB] ;
    exptparams.LastReversalIndx=[exptparams.LastReversalIndx, TrialIndx];
end
% Now prepare one for display purpose and put it in last array of
% performance:
% change all rates to percentage. If its not rate, put the sum and
% 'out of'
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if isnan(perf(cnt2).(PerfFields{cnt1})), perf(cnt2).(PerfFields{cnt1}) = 0;end
    if ~isempty(strfind(PerfFields{cnt1},'Rate')) % if its a rate, do
        %not divide by number of trials, just make it percentage:
        perfPer.(PerfFields{cnt1}) = round(perf(cnt2).(PerfFields{cnt1})*100);
    else
        if isnumeric(perf(cnt2).(PerfFields{cnt1}))
            perfPer.(PerfFields{cnt1})(1)   = sum(cat(1,perf.(PerfFields{cnt1})));
            perfPer.(PerfFields{cnt1})(2)   = TrialIndex; % by default
        else
            perfPer.(PerfFields{cnt1})      = perf(cnt2).(PerfFields{cnt1});
        end
    end
end
% Now put 'out of' field. If its hit, miss, its out of
% TrialIndex-Shams-Snoozes:
Trial_Sham              = TrialIndex - sum(cat(1,perf.Sham));
Trial_Sham_Snooze       = TrialIndex - sum(cat(1,perf.Sham)) - sum(cat(1,perf.SnoozeTar));
perfPer.Hit(2)          = Trial_Sham_Snooze;
perfPer.Miss(2)         = Trial_Sham_Snooze;
perfPer.SnoozeHit(2)    = Trial_Sham;
perfPer.SnoozeMiss(2)   = Trial_Sham;
perfPer.SnoozeTar(2)    = Trial_Sham;
%
exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;
if isfield(exptparams,'Water')
    exptparams.Performance(end).Water = exptparams.Water .* globalparams.PumpMlPerSec.Pump;
end
%%%%%%%%%%%%%%%%%%%%%%%%%
% adding the multi-target support:
% create a new structure that has the name of the targets and their
% corresponding performance. ALso, keep the original one for backward
% compatibility:
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% return;
if IsSham, return;end   % for shams, we don't add them since we don't know what target
                        % they belong to.
TargetName = strrep(TargetName,'$','');                        
% initialize the performance data:
if isfield(exptparams, 'PerformancePerTarget') && (TrialIndex~=1) 
    AllTargetNames = strvcat(exptparams.PerformancePerTarget.TargetName);
    TargetIndex = find(strcmpi(cellstr(AllTargetNames),TargetName));
    % see if its a new target:
    if ~isempty(TargetIndex), 
        perf = exptparams.PerformancePerTarget(TargetIndex).Performance;
        perf = perf(1:end-1);
        cnt2 = length(perf) + 1;
    else
        TargetIndex = size(AllTargetNames,1)+1;
        cnt2=1;
    end
else % if its the very first time
    cnt2 = 1;
    if isfield(exptparams,'PerformancePerTarget'), exptparams = rmfield(exptparams,'PerformancePerTarget');end
    TargetIndex=1;
end
perf(cnt2).ThisTrial = 'Sham';
perf(cnt2).Hit = 0; perf(cnt2).HitRate = 0; 
perf(cnt2).Safe = 0; perf(cnt2).SafeRate = 0; 
perf(cnt2).DiscriminationRate = 0; 
perf(cnt2).Miss = 0; perf(cnt2).MissRate = 0;
perf(cnt2).SnoozeHit = 0; perf(cnt2).SnoozeHitRate=0;
perf(cnt2).SnoozeMiss = 0; perf(cnt2).SnoozeMissRate = 0;
perf(cnt2).FalsePositive = 0; perf(cnt2).FalsePositiveRate = 0;
perf(cnt2).SnoozeSafe = 0; perf(cnt2).SnoozeSafeRate = 0;
perf(cnt2).SnoozeFalsePositive = 0; perf(cnt2).SnoozeRef = 0;perf(cnt2).SnoozeTar = 0;
perf(cnt2).Sham = IsSham;
for cnt1 = 1:length(SalientWin)
    switch [SalientWin(cnt1).RefOrTar(1) ' ' num2str(SalientWin(cnt1).PreLick) ...
            ' ' num2str(SalientWin(cnt1).PosLick)]
        case 'R 0 0', % Snooze False positive
            perf(cnt2).SnoozeFalsePositive = perf(cnt2).SnoozeFalsePositive + 1/NumOfRef;
            perf(cnt2).SnoozeRef = perf(cnt2).SnoozeRef + 1/NumOfRef;
        case 'R 0 1', % Snooze Safe
            perf(cnt2).SnoozeSafe = perf(cnt2).SnoozeSafe + 1/NumOfRef;
            perf(cnt2).SnoozeRef = perf(cnt2).SnoozeRef + 1/NumOfRef;
        case 'R 1 0', % False Positive
            perf(cnt2).FalsePositive = perf(cnt2).FalsePositive + 1/NumOfRef;
        case 'R 1 1', % Safe
            perf(cnt2).Safe = perf(cnt2).Safe + 1/NumOfRef;
        case 'T 0 0', % Snooze Hit
            perf(cnt2).SnoozeHit = perf(cnt2).SnoozeHit + 1;
            perf(cnt2).SnoozeTar = perf(cnt2).SnoozeTar + 1;
            perf(cnt2).ThisTrial = 'Snooze Hit';
        case 'T 0 1', % Snooze Miss
            perf(cnt2).SnoozeMiss = perf(cnt2).SnoozeMiss + 1;
            perf(cnt2).SnoozeTar = perf(cnt2).SnoozeTar + 1;
            perf(cnt2).ThisTrial = 'Snooze Miss';
        case 'T 1 0', % Hit
            perf(cnt2).Hit = perf(cnt2).Hit + 1;
            perf(cnt2).ThisTrial = 'Hit';
        case 'T 1 1', % Miss
            perf(cnt2).Miss = perf(cnt2).Miss + 1;
            perf(cnt2).ThisTrial = 'Miss';
    end
end
% Now calculate hit and miss rates both for entire experiment and this
% block only:
perf(cnt2).HitRate              = sum(cat(1,perf.Hit)) / (sum(cat(1,perf.Hit)) + sum(cat(1,perf.Miss)));
perf(cnt2).SafeRate             = sum(cat(1,perf.Safe)) / (sum(cat(1,perf.Safe)) + sum(cat(1,perf.FalsePositive)));
perf(cnt2).DiscriminationRate   = perf(cnt2).HitRate * perf(cnt2).SafeRate;
perf(cnt2).MissRate             = 1 - perf(cnt2).HitRate;
perf(cnt2).FalsePositiveRate    = 1 - perf(cnt2).SafeRate;
perf(cnt2).SnoozeHitRate        = sum(cat(1,perf.SnoozeHit)) / (sum(cat(1,perf.SnoozeHit))+ ...
    sum(cat(1,perf.SnoozeMiss)));
perf(cnt2).SnoozeMissRate       = 1 - perf(cnt2).SnoozeHitRate;
perf(cnt2).SnoozeSafeRate       = sum(cat(1,perf.SnoozeSafe)) / (sum(cat(1,perf.SnoozeSafe)) + sum(cat(1,perf.SnoozeFalsePositive)));
% Now prepare one for display purpose and put it in last array of
% performance:
% change all rates to percentage. If its not rate, put the sum and
% 'out of'
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if isnan(perf(cnt2).(PerfFields{cnt1})), perf(cnt2).(PerfFields{cnt1}) = 0;end
    if ~isempty(strfind(PerfFields{cnt1},'Rate')) % if its a rate, do
        %not divide by number of trials, just make it percentage:
        perfPer.(PerfFields{cnt1}) = round(perf(cnt2).(PerfFields{cnt1})*100);
    else
        perfPer.(PerfFields{cnt1})      = perf(cnt2).(PerfFields{cnt1});
    end
end
%
exptparams.PerformancePerTarget(TargetIndex).Performance(cnt2) = perf(cnt2);
exptparams.PerformancePerTarget(TargetIndex).Performance(cnt2+1) = perfPer;
exptparams.PerformancePerTarget(TargetIndex).TargetName = TargetName;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% return;
% also add the lick per target here:
% get a histogram of lick based on salient window. One for
% reference, one for target and one for all.
if ~isfield(exptparams, 'LickPerTarget') || (TrialIndex ==1) ...
        || (length(exptparams.LickPerTarget)<TargetIndex)
    exptparams.LickPerTarget(TargetIndex).TargetName  = [];
    exptparams.LickPerTarget(TargetIndex).TarHist     = [];
    exptparams.LickPerTarget(TargetIndex).TarNum      = 0;
    exptparams.LickPerTarget(TargetIndex).TarBound    = [];
    exptparams.LickPerTarget(TargetIndex).RefHist     = [];
    exptparams.LickPerTarget(TargetIndex).RefNum      = 0;
    exptparams.LickPerTarget(TargetIndex).RefBound    = [];
end
% Store the histogram, its total number and bounds for reference,
% target
% first, reference:
% for this case, only add the average reference and average target:
mm=0;
for cnt1 = 1:length(AllRefLickHist), mm=max(mm,length(AllRefLickHist{cnt1}));end
for cnt1 = 1:length(AllRefLickHist), AllRefLickHist{cnt1}(end+1:mm)=0;end
RefHist = mean(cat(2,AllRefLickHist{:}),2)';

exptparams.LickPerTarget(TargetIndex).TargetName = TargetName;
exptparams.LickPerTarget(TargetIndex).RefHist(end+1:length(RefHist)) = 0;
RefHist(end+1:length(exptparams.LickPerTarget(TargetIndex).RefHist)) = 0;
exptparams.LickPerTarget(TargetIndex).RefHist = ...
    exptparams.LickPerTarget(TargetIndex).RefHist+RefHist;
exptparams.LickPerTarget(TargetIndex).RefNum = ...
    exptparams.LickPerTarget(TargetIndex).RefNum+1;
exptparams.LickPerTarget(TargetIndex).TarHist(end+1:length(TarLickHist)) = 0;
TarLickHist(end+1:length(exptparams.LickPerTarget(TargetIndex).TarHist)) = 0;
exptparams.LickPerTarget(TargetIndex).TarHist = ...
    exptparams.LickPerTarget(TargetIndex).TarHist+TarLickHist';
exptparams.LickPerTarget(TargetIndex).TarNum = ...
    exptparams.LickPerTarget(TargetIndex).TarNum+1;
exptparams.LickPerTarget(TargetIndex).TarBound = TarBound;
exptparams.LickPerTarget(TargetIndex).RefBound = RefBound;