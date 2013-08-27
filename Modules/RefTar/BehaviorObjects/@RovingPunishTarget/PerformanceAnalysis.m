function exptparams = PerformanceAnalysis (o, HW, StimEvents, globalparams, exptparams, TrialIndex, LickData)
% Performance measures are defined as follows:
% Target Lick Analysis
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
% snooze misses). Note snooze miss rate = (1 – snooze hit rate)
%
% Reference Lick Analysis
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
% false positive rate is just =(1 – (safe rate). The discrimination
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


%% Collect lick data
AnalysisWindow = [];
fs = globalparams.HWparams.fsAI;
NumOfRef = 0;
AllRefLickHist = {};
IsoAllRefLickHist= {};

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

%This loop collects the lick data for each reference and target stimulus
RefBound=[];TarBound=[];Refcnt=0;Tarcnt=0;TrialDurs=[];
while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim');
            if strcmpi(StimRefOrTar,'Reference')
                cnt2 = cnt1 + NumOfEvPerRef-3;
                
            else
                cnt2 = cnt1 + NumOfEvPerTar-3;
                
            end
            
            NumOfRef = NumOfRef + strcmpi(StimRefOrTar,'Reference'); %accumilates the # of references in a trial
            
            PreLickWindow = get(o,'PreLickWindow');
            PostLickWindow = get(o,'PostLickWindow');    
            ResponseTime = get(o,'ResponseTime');    
            
            if strcmpi(StimRefOrTar,'Target')
                    AnalysisWindow(end+1).PreWin = sort([StimEvents(cnt1).StartTime-PreLickWindow...
                        StimEvents(cnt1).StartTime]);
                    
                if PostLickWindow > 0
                    AnalysisWindow(end).PosWin = sort([(StimEvents(cnt2).StopTime+ResponseTime)  ...
                        (StimEvents(cnt2).StopTime+ResponseTime+PostLickWindow)]);
                else
                    AnalysisWindow(end).PosWin = sort([(StimEvents(cnt2).StopTime-abs(ResponseTime))  ...
                        (StimEvents(cnt2).StopTime - abs((ResponseTime+PostLickWindow)))]);
                end
                                
                % max in the following line prohibit the negaive or zero indexing:
                AnalysisWindow(end).PreLick = ...
                    ~isempty(find(LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1)):...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))),1));
                AnalysisWindow(end).PosLick = ...
                    ~isempty(find(LickData(ceil(fs*AnalysisWindow(end).PosWin(1):min(length(LickData),fs*AnalysisWindow(end).PosWin(2)))),1));
                AnalysisWindow(end).PreLickAvg = ...
                    (LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1))+1:...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))));
                
            else
                AnalysisWindow(end+1).PreWin = sort([StimEvents(cnt1).StartTime-PreLickWindow...
                    StimEvents(cnt1).StartTime]);
                
                if PostLickWindow > 0
                    AnalysisWindow(end).PosWin = sort([StimEvents(cnt2).StopTime+ResponseTime ...
                        StimEvents(cnt2).StopTime+ResponseTime+PostLickWindow]);
                else
                    AnalysisWindow(end).PosWin = sort([StimEvents(cnt2).StopTime-abs(ResponseTime) ...
                        StimEvents(cnt2).StopTime-abs(ResponseTime+PostLickWindow)]);
                end
                
                % max in the following line prohibit the negaive or zero indexing:
                AnalysisWindow(end).PreLick = ...
                    ~isempty(find(LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1)):...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))),1));
                AnalysisWindow(end).PosLick = ...
                    ~isempty(find(LickData(ceil(fs*AnalysisWindow(end).PosWin(1):min(length(LickData),fs*AnalysisWindow(end).PosWin(2)))),1));
                AnalysisWindow(end).PreLickAvg = ...
                    (LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1))+1:...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))));
                
            end
            
            AnalysisWindow(end).RefOrTar = StimRefOrTar;
            
            % In the following block, we obtain the lick data for references and targets
            if strcmpi(StimRefOrTar,'Reference')
                Refcnt = Refcnt+1;
                RefBound{Refcnt}=[];
                
                % For displaying the Lick histogram of reference, find the boundaries.
                RefBound{Refcnt} = 0;
                RefBound{Refcnt} = [RefBound{Refcnt} PreLickWindow]; % PreStimSilence
                RefBound{Refcnt} = [RefBound{Refcnt} RefBound{Refcnt}(end)+StimEvents(cnt2).StopTime-StimEvents(cnt1).StartTime-PreLickWindow]; % Ref
                RefBound{Refcnt} = [RefBound{Refcnt} RefBound{Refcnt}(end)+ResponseTime]; % response window
                RefBound{Refcnt} = [RefBound{Refcnt} RefBound{Refcnt}(end)+PostLickWindow];
                if PostLickWindow < 0
                    AllRefLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                    IsoAllRefLickHist{end+1} = LickData(ceil(single(((StimEvents(cnt1).StartTime).*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));

                else
                    AllRefLickHist{end+1} = LickData(ceil(single(((StimEvents(cnt1).StartTime).*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs)))+(ResponseTime+PostLickWindow).*fs);
                    IsoAllRefLickHist{end+1} = LickData(ceil(single(((StimEvents(cnt1).StartTime).*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));

                end
                
            else
                Tarcnt = Tarcnt+1;
                IsSham = 0;
                TarBound=[];
                TarBound= 0;
                TarBound= [TarBound PreLickWindow]; % PreStimSilence
                TarBound= [TarBound TarBound(end)+StimEvents(cnt2).StopTime-StimEvents(cnt1).StartTime]; % Ref
                TarBound= [TarBound TarBound(end)+ResponseTime]; % response window
                TarBound= [TarBound TarBound(end)+PostLickWindow]; %Currently set to the first 400ms of the PostStimSilence
                if PostLickWindow < 0
                TarLickHist = LickData(ceil(single(((StimEvents(cnt1).StartTime-PreLickWindow).*fs)+1)):ceil(single((StimEvents(cnt1).StopTime.*fs))));
                IsoTarLickHist = LickData(ceil(single(((StimEvents(cnt1).StartTime).*fs)+1)):ceil(single((StimEvents(cnt1).StopTime.*fs))));
                else
                TarLickHist = LickData(ceil(single((StimEvents(cnt1).StartTime-PreLickWindow).*fs))+1:ceil(single((StimEvents(cnt1).StopTime.*fs)))+(ResponseTime+PostLickWindow).*fs);
                IsoTarLickHist = LickData(ceil(single((StimEvents(cnt1).StartTime).*fs))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                end
                % Also get the name of the target sound:
                TargetName = StimName;

            end
            
            if strcmpi(StimRefOrTar,'Reference')
                cnt1 = cnt1 + NumOfEvPerRef-3;
                
            else
                cnt1 = cnt1 + NumOfEvPerTar-3;
                
            end
        end
    end
    cnt1 = cnt1 + 1;
    
end
%% Creat a histogram of licks

% Store the histogram, its total number and bounds for reference and target
% reference licks. Currently assumes that the trial length is determined by
% the number of references

%Add together all references traces

%set historgram values to 0 or empty if first trial because there is no
%history of data to build on
if ~isfield(exptparams, 'AllRefLick') || (TrialIndex ==1)
    exptparams.TarLick.Hist     = 0;
    exptparams.TarLick.Num      = 0;
    exptparams.TarLick.Bound    = 0;
    exptparams.TarLick.Sham    = 0;
    exptparams.AllRefLick.Hist    = [];
    exptparams.AllRefLick.Bound   = [];
    exptparams.AllRefLick.Num     = [];
    exptparams.AllRefLick.All    = [];
    exptparams.TarDi=[];
    exptparams.RefDi=[];
end

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

% target licks
if exist('TarLickHist','var')
    exptparams.TarLick.Hist(end+1:length(TarLickHist),1) = 0;
    exptparams.TarLick.Hist(1:length(TarLickHist))= ...
        exptparams.TarLick.Hist(1:length(TarLickHist)) + TarLickHist;
    exptparams.TarLick.Num=exptparams.TarLick.Num+1;
    exptparams.TarLick.Bound = TarBound;
end
exptparams.AnalysisWindow = AnalysisWindow; % this is used for display purpose

%Sham Trials
if Tarcnt == 0
    exptparams.TarLick.Sham  = exptparams.TarLick.Sham+1;
    
end

%% Performance Analysis

% initialize the performance data:
if isfield(exptparams, 'Performance') && (TrialIndex~=1)
    perf = exptparams.Performance(1:end-1);
    cnt2 = length(perf) + 1;
    
else
    cnt2 = 1;
    
    if isfield(exptparams,'Performance'), exptparams = rmfield(exptparams,'Performance')
        
    end
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
perf(cnt2).DiscriminationIndex = 0; perf(cnt2).RecentDiscriminationIndex =0;

for cnt1 = 1:length(AnalysisWindow)
    %     [AnalysisWindow(cnt1).RefOrTar(1) ' ' num2str(AnalysisWindow(cnt1).PreLick) ...
    %             ' ' num2str(AnalysisWindow(cnt1).PosLick)]
    switch [AnalysisWindow(cnt1).RefOrTar(1) ' ' num2str(AnalysisWindow(cnt1).PreLick) ...
            ' ' num2str(AnalysisWindow(cnt1).PosLick)]
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

% Discrimination Index
if IsSham == 0
    PreLW = AnalysisWindow(end).PreLickAvg;
    DiWin = length(IsoTarLickHist)/5;
    TarDi = zeros(1,(length(IsoTarLickHist)/DiWin));
    TarIndexNow = 1;
    for i2 = 1:length(TarDi);
        TarTemp = IsoTarLickHist(1:TarIndexNow+(DiWin-1));
        if mean(PreLW) > mean(TarTemp)
            TarDi(i2) = TarDi(i2)+1;
        end
        TarIndexNow = TarIndexNow+DiWin;
    end
    exptparams.TarDi{TrialIndex} = TarDi;
else
    exptparams.TarDi{TrialIndex}=[];
end

ht = [];
for i = 1:length(exptparams.TarDi)
    if isempty(exptparams.TarDi{i})==0
        ht = [ht; exptparams.TarDi{i}(1,:)];
    end
end
ht = [mean(ht,1) 1]';

for i = 1:length(IsoAllRefLickHist)
    PreLW = AnalysisWindow(i).PreLickAvg;
    DiWin = length(IsoAllRefLickHist{1,1})/5;
    RefDi = zeros(1,(length(IsoAllRefLickHist{1,1})/DiWin));
    RefIndexNow = 1;
    RefIndex = length(IsoAllRefLickHist{i})/DiWin;
    for i2 = 1:RefIndex
        RefTemp = IsoAllRefLickHist{i}(1:RefIndexNow+(DiWin-1));
        if mean(PreLW) > mean(RefTemp)
            RefDi(i2) = RefDi(i2)+1;
        end
        RefIndexNow = RefIndexNow+DiWin;
    end
end
exptparams.RefDi{TrialIndex} = RefDi;

fa = [];
for i2 = 1:size(exptparams.RefDi{1},1)
    fa_temp=[];
    for i = 1:length(exptparams.RefDi)
        fa_temp = [fa_temp; exptparams.RefDi{i}(i2,:)];
    end
    fa = [fa; nanmean(fa_temp,1)];
end
fa = [nanmean(fa,1) 1]';

w=([0;diff(fa(:,1))]+[diff(fa(:,1));0])./2;
di=sum(w.*ht(:,1));
w2=([0;diff(ht(:,1))]+[diff(ht(:,1));0])./2;
di2=1-sum(w2.*fa(:,1));
di3=(di+di2)./2;

if IsSham == 0
    if length(TarDi) ~= length(RefDi)
        disp('Target and Reference max durations are not equal: Di will not be accurate')
        
    end
end

% Now calculate hit and miss rates both for entire experiment and this
% block only:
perf(cnt2).DiscriminationIndex = di3;
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
RecentIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;

perf(cnt2).RecentHitRate         = sum(cat(1,perf(RecentIndex).Hit))  / ...
    (sum(cat(1,perf(RecentIndex).Hit)) + sum(cat(1,perf(RecentIndex).Miss)));
perf(cnt2).RecentSafeRate        = sum(cat(1,perf(RecentIndex).Safe)) / ...
    (sum(cat(1,perf(RecentIndex).Safe))+ sum(cat(1,perf(RecentIndex).FalsePositive)));
perf(cnt2).RecentDiscriminationRate = perf(cnt2).RecentHitRate * perf(cnt2).RecentSafeRate;

%Discrimination Index
bht = [];
for i = 1:length(RecentIndex)
    if isempty(exptparams.TarDi{RecentIndex(i)})==0
        bht = [bht; exptparams.TarDi{RecentIndex(i)}(1,:)];
    end
end
bht = [mean(bht,1) 1]';

bfa = [];
for i2 = 1:size(exptparams.RefDi{1},1)
    fa_temp=[];
    for i = 1:length(RecentIndex)
        fa_temp = [fa_temp; exptparams.RefDi{RecentIndex(i)}(i2,:)];
    end
    bfa = [bfa; nanmean(fa_temp,1)];
end
bfa = [nanmean(bfa,1) 1]';

w=([0;diff(bfa(:,1))]+[diff(bfa(:,1));0])./2;
bdi=sum(w.*bht(:,1));
w2=([0;diff(bht(:,1))]+[diff(bht(:,1));0])./2;
bdi2=1-sum(w2.*bfa(:,1));
bdi3=(bdi+bdi2)./2;

perf(cnt2).RecentDiscriminationIndex = bdi3;

% Now prepare one for display purpose and put it in last array of
% performance:
% change all rates to percentage. If its not rate, put the sum and
% 'out of'
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if isnan(perf(cnt2).(PerfFields{cnt1})), perf(cnt2).(PerfFields{cnt1}) = 0;end
    if ~isempty(strfind(PerfFields{cnt1},'Rate')) || ~isempty(strfind(PerfFields{cnt1},'Index'))% if its a rate, do
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

exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;
if isfield(exptparams,'Water')
    exptparams.Performance(end).Water = exptparams.Water .* globalparams.PumpMlPerSec.Pump;
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




