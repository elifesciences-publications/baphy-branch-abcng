function exptparams = PerformanceAnalysis (o, HW, StimEvents, globalparams, exptparams, TrialIndex, LickData)
% Performance measures are defined as follows:
%   Hit: Animal licks in TarPre but not in TarPos (ie. no shock)
%   Miss: Animal licks in TarPre and also in TarPos
%   False Positive: Animal licks in DisPre but not in DisPos
%   Correct Rejection: Animal licks in DisPre and in DisPos
%   Snooze: Animal does not lick in Ref
%   Safe: Animal licks in RefBeg and in RefEnd
%
% The lick rate is calculated as the number of licks (or lick
% duration) divided by the duration of the time window being
% measured. For more discussion, see section on lick rate analysis.

%% Collect lick data
AnalysisWindow = [];
fs = globalparams.HWparams.fsAI;
NumOfRef = 0;
AllToneRefLickHist = {};
AllTorcRefLickHist={};
AllToneRefToneTarLickHist={};
AllTorcRefTorcTarLickHist = {};
AllToneRefTorcTarLickHist={};
AllTorcRefToneTarLickHist={};
ToneRefDurs=[];
TorcRefDurs=[];
Tar=0;
Dis=0;

NumOfEvPerStim = get(exptparams.TrialObject,'NumOfEvPerStim'); % how many sounds we have in each stim? ex: torc=3, discrim=6, etc..
if isfield(get(exptparams.TrialObject),'NumOfEvPerRef'),
    NumOfEvPerRef = get(exptparams.TrialObject,'NumOfEvPerRef');
    NumOfEvPerTar = get(exptparams.TrialObject,'NumOfEvPerTar');
    
else
    NumOfEvPerRef = NumOfEvPerStim;
    NumOfEvPerTar = NumOfEvPerStim;
    
end

cnt1 = 1;
%This loop collects the lick data for each reference and target stimulus
Tarcnt=0;Discnt=0;
while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim');
            
            NumOfRef = NumOfRef + strcmpi(StimRefOrTar,'Reference'); %accumilates the # of references in a trial
            
            
            % In the following block, we obtain the lick data for references and targets
            if strcmpi(StimRefOrTar,'Reference')
                PreLickWindow = get(o,'PreLickWindow');
                PostLickWindow = get(o,'PostLickWindow');
                ResponseTime = get(o,'ResponseTime');
                
                AnalysisWindow(end+1).PreWin = sort([StimEvents(cnt1).StartTime...
                    StimEvents(cnt1).StartTime+PreLickWindow]);
                
                AnalysisWindow(end).PosWin = sort([(StimEvents(cnt1).StopTime+ResponseTime)  ...
                    (StimEvents(cnt1).StopTime+ResponseTime+PostLickWindow)]);
                
                % max in the following line prohibit the negaive or zero indexing:
                AnalysisWindow(end).PreLick = ...
                    ~isempty(find(LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1)):...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))),1));
                AnalysisWindow(end).PosLick = ...
                    ~isempty(find(LickData(ceil(fs*AnalysisWindow(end).PosWin(1):min(length(LickData),fs*AnalysisWindow(end).PosWin(2)))),1));
                AnalysisWindow(end).PreLickAvg = ...
                    (LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1))+1:...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))));
                AnalysisWindow(end).RefTarDis = 'Reference';
                AnalysisWindow(end).Snooze = ...
                    isempty(find(LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs)))),1));
                AnalysisWindow(end).Safe = ...
                    sum([find(LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StartTime.*fs)))+(fs*PreLickWindow)),1)...
                    find(LickData(ceil(single((StimEvents(cnt1).StopTime.*fs)))-(fs*PreLickWindow):ceil(single((StimEvents(cnt1).StopTime.*fs)))),1)])>1;
 
                StimOrder = num2str([StimEvents(cnt1+2).Rove(1)]);
                switch StimOrder
                    case '2'
                        AllToneRefLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                        ToneRefDurs = [ToneRefDurs; StimEvents(cnt1).Rove];
                      
                    case '1'
                        AllTorcRefLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                        TorcRefDurs = [TorcRefDurs; StimEvents(cnt1).Rove];
 
                end
                
            else
                Target = get(exptparams.TrialObject);
                Gap = Target.Gap;
                PreLickWindow = get(o,'PreLickWindow');
                PostLickWindow = get(o,'PostLickWindow');
                ResponseTime = get(o,'ResponseTime');
                
                AnalysisWindow(end+1).PreWin = sort([StimEvents(cnt1).StartTime-Gap-PreLickWindow...
                    StimEvents(cnt1).StartTime-Gap]);
                
                AnalysisWindow(end).PosWin = sort([(StimEvents(cnt1).StopTime+ResponseTime)  ...
                    (StimEvents(cnt1).StopTime+ResponseTime+PostLickWindow)]);
                
                % max in the following line prohibit the negaive or zero indexing:
                AnalysisWindow(end).PreLick = ...
                    ~isempty(find(LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1)):...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))),1));
                AnalysisWindow(end).PosLick = ...
                    ~isempty(find(LickData(ceil(fs*AnalysisWindow(end).PosWin(1):min(length(LickData),fs*AnalysisWindow(end).PosWin(2)))),1));
                AnalysisWindow(end).PreLickAvg = ...
                    (LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1))+1:...
                    max(1,fs*AnalysisWindow(end).PreWin(2)))));
                
                if StimEvents(cnt1).Rove(1) ~= StimEvents(cnt1).Rove(2)
                    Tarcnt = Tarcnt+1;
                    Tar = 1;
                    
                    % Also get the name of the target sound:
                    AnalysisWindow(end).RefTarDis = 'Target';
                    
                else
                    Discnt = Discnt+1;
                    Dis = 1;
                    
                    % Also get the name of the target sound:
                    AnalysisWindow(end).RefTarDis = 'Distractor';
                    
                end
                
                StimOrder = num2str([StimEvents(cnt1).Rove(1) StimEvents(cnt1).Rove(2)]);
                switch StimOrder
                    case '2  2'
                        AllToneRefToneTarLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                 
                    case '2  1'
                        AllToneRefTorcTarLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                    
                    case '1  2'
                        AllTorcRefToneTarLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                    
                    case '1  1'
                        AllTorcRefTorcTarLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                
                end
                
                
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
x = get(exptparams.TrialObject,'RoveDurs');
if x(1,1) ~=0
  DurIncrement = x(1,2);
  RefDur = get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration');
  PossibleRefDurs = RefDur(1):DurIncrement:RefDur(2);
else
  RefDur = get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration');
  PossibleRefDurs = mean(RefDur);
end

TarDur = mean(RefDur);;

if (TrialIndex ==1)
    exptparams.AllToneRefLick.Hist     = [];
    exptparams.AllToneRefLick.Num      =  zeros(1,length(PossibleRefDurs));
    exptparams.AllTorcRefLick.Hist     = [];
    exptparams.AllTorcRefLick.Num      =  zeros(1,length(PossibleRefDurs));
    exptparams.AllToneRefToneTarLick.Hist     = [];
    exptparams.AllToneRefToneTarLick.Num      =  zeros(1,length(TarDur));
    exptparams.AllToneRefTorcTarLick.Hist     = [];
    exptparams.AllToneRefTorcTarLick.Num      =  zeros(1,length(TarDur));
    exptparams.AllTorcRefTorcTarLick.Hist     = [];
    exptparams.AllTorcRefTorcTarLick.Num      =  zeros(1,length(TarDur));
    exptparams.AllTorcRefToneTarLick.Hist     = [];
    exptparams.AllTorcRefToneTarLick.Num      =  zeros(1,length(TarDur));
    
    exptparams.Refcnt = [];
    exptparams.Tarcnt = [];
    exptparams.Discnt = [];
    
end

for cnt1 = 1:length(AllToneRefLickHist)
    DurIndex = find(ToneRefDurs(cnt1) == PossibleRefDurs);
    
    if isempty(exptparams.AllToneRefLick.Hist) || length(exptparams.AllToneRefLick.Hist) < DurIndex
        exptparams.AllToneRefLick.Hist{DurIndex}=AllToneRefLickHist{cnt1};
        
    elseif isempty(exptparams.AllToneRefLick.Hist{DurIndex})
        exptparams.AllToneRefLick.Hist{DurIndex}=AllToneRefLickHist{cnt1};
        
    else
        exptparams.AllToneRefLick.Hist{DurIndex}=[exptparams.AllToneRefLick.Hist{DurIndex} AllToneRefLickHist{cnt1}];
        
    end
    
    exptparams.AllToneRefLick.Num(DurIndex) = exptparams.AllToneRefLick.Num(DurIndex)+1;
    
end

for cnt1 = 1:length(AllTorcRefLickHist)
    DurIndex = find(TorcRefDurs(cnt1) == PossibleRefDurs);
    
    if isempty(exptparams.AllTorcRefLick.Hist) || length(exptparams.AllTorcRefLick.Hist) < DurIndex
        exptparams.AllTorcRefLick.Hist{DurIndex}=AllTorcRefLickHist{cnt1};
        
    elseif isempty(exptparams.AllTorcRefLick.Hist{DurIndex})
        exptparams.AllTorcRefLick.Hist{DurIndex}=AllTorcRefLickHist{cnt1};
        
    else
        exptparams.AllTorcRefLick.Hist{DurIndex}=[exptparams.AllTorcRefLick.Hist{DurIndex} AllTorcRefLickHist{cnt1}];
        
    end
    
    exptparams.AllTorcRefLick.Num(DurIndex) = exptparams.AllTorcRefLick.Num(DurIndex)+1;
    
end

for cnt1 = 1:length(AllToneRefToneTarLickHist)
    DurIndex = 1;
    
    if isempty(exptparams.AllToneRefToneTarLick.Hist) || length(exptparams.AllToneRefToneTarLick.Hist) < DurIndex
        exptparams.AllToneRefToneTarLick.Hist{DurIndex}=AllToneRefToneTarLickHist{cnt1};
        
    elseif isempty(exptparams.AllToneRefToneTarLick.Hist{DurIndex})
        exptparams.AllToneRefToneTarLick.Hist{DurIndex}=AllToneRefToneTarLickHist{cnt1};
        
    else
        exptparams.AllToneRefToneTarLick.Hist{DurIndex}=[exptparams.AllToneRefToneTarLick.Hist{DurIndex} AllToneRefToneTarLickHist{cnt1}];
        
    end
    
    exptparams.AllToneRefToneTarLick.Num(DurIndex) = exptparams.AllToneRefToneTarLick.Num(DurIndex)+1;
    
end


for cnt1 = 1:length(AllToneRefTorcTarLickHist)
    DurIndex = 1;
    
    if isempty(exptparams.AllToneRefTorcTarLick.Hist) || length(exptparams.AllToneRefTorcTarLick.Hist) < DurIndex
        exptparams.AllToneRefTorcTarLick.Hist{DurIndex}=AllToneRefTorcTarLickHist{cnt1};
        
    elseif isempty(exptparams.AllToneRefTorcTarLick.Hist{DurIndex})
        exptparams.AllToneRefTorcTarLick.Hist{DurIndex}=AllToneRefTorcTarLickHist{cnt1};
        
    else
        exptparams.AllToneRefTorcTarLick.Hist{DurIndex}=[exptparams.AllToneRefTorcTarLick.Hist{DurIndex} AllToneRefTorcTarLickHist{cnt1}];
        
    end
    
    exptparams.AllToneRefTorcTarLick.Num(DurIndex) = exptparams.AllToneRefTorcTarLick.Num(DurIndex)+1;
    
end

for cnt1 = 1:length(AllTorcRefTorcTarLickHist)
    DurIndex = 1;
    
    if isempty(exptparams.AllTorcRefTorcTarLick.Hist) || length(exptparams.AllTorcRefTorcTarLick.Hist) < DurIndex
        exptparams.AllTorcRefTorcTarLick.Hist{DurIndex}=AllTorcRefTorcTarLickHist{cnt1};
        
    elseif isempty(exptparams.AllTorcRefTorcTarLick.Hist{DurIndex})
        exptparams.AllTorcRefTorcTarLick.Hist{DurIndex}=AllTorcRefTorcTarLickHist{cnt1};
        
    else
        exptparams.AllTorcRefTorcTarLick.Hist{DurIndex}=[exptparams.AllTorcRefTorcTarLick.Hist{DurIndex} AllTorcRefTorcTarLickHist{cnt1}];
        
    end
    
    exptparams.AllTorcRefTorcTarLick.Num(DurIndex) = exptparams.AllTorcRefTorcTarLick.Num(DurIndex)+1;
    
end

for cnt1 = 1:length(AllTorcRefToneTarLickHist)
    DurIndex = 1;
    
    if isempty(exptparams.AllTorcRefToneTarLick.Hist) || length(exptparams.AllTorcRefToneTarLick.Hist) < DurIndex
        exptparams.AllTorcRefToneTarLick.Hist{DurIndex}=AllTorcRefToneTarLickHist{cnt1};
        
    elseif isempty(exptparams.AllTorcRefToneTarLick.Hist{DurIndex})
        exptparams.AllTorcRefToneTarLick.Hist{DurIndex}=AllTorcRefToneTarLickHist{cnt1};
        
    else
        exptparams.AllTorcRefToneTarLick.Hist{DurIndex}=[exptparams.AllTorcRefToneTarLick.Hist{DurIndex} AllTorcRefToneTarLickHist{cnt1}];
        
    end
    
    exptparams.AllTorcRefToneTarLick.Num(DurIndex) = exptparams.AllTorcRefToneTarLick.Num(DurIndex)+1;
    
end

exptparams.AnalysisWindow = AnalysisWindow; % this is used for display purpose


%% Performance Analysis
% initialize the performance data:
if isfield(exptparams, 'Performance') && (TrialIndex~=1)
    perf = exptparams.Performance(1:end-1);
    cnt2 = length(perf) + 1;
    
else
    cnt2 = 1;
    
    if isfield(exptparams,'Performance')
        exptparams = rmfield(exptparams,'Performance')
    end
    
end
perf(cnt2).Hit = 0; perf(cnt2).HitRate = 0; perf(cnt2).RecentHitRate=0;
perf(cnt2).Miss = 0; perf(cnt2).MissRate = 0; perf(cnt2).RecentMissRate = 0;
perf(cnt2).FalsePositive = 0; perf(cnt2).FalsePositiveRate = 0; perf(cnt2).RecentFalsePositiveRate = 0;
perf(cnt2).CorrectRejection = 0; perf(cnt2).CorrectRejectionRate = 0; perf(cnt2).RecentCorrectRejectionRate = 0;
perf(cnt2).Safe = 0; perf(cnt2).SafeRate = 0; perf(cnt2).RecentSafeRate=0;
perf(cnt2).Snooze = 0; perf(cnt2).SnoozeRate = 0; perf(cnt2).RecentSnoozeRate=0;
perf(cnt2).DiscrimRate = 0; perf(cnt2).RecentDiscrimRate =0;

%Code performance
for cnt1 = 1:length(AnalysisWindow)
    switch [AnalysisWindow(cnt1).RefTarDis(1) ' ' num2str(AnalysisWindow(cnt1).PreLick) ...
            ' ' num2str(AnalysisWindow(cnt1).PosLick)]
        case 'T 1 0', % Hit
            perf(cnt2).Hit = perf(cnt2).Hit + 1;
        case 'T 1 1', % Miss
            perf(cnt2).Miss = perf(cnt2).Miss + 1;
        case 'D 1 0', % False Positive
            perf(cnt2).FalsePositive = perf(cnt2).FalsePositive + 1;
        case 'D 1 1', % Correct Rejection
            perf(cnt2).CorrectRejection = perf(cnt2).CorrectRejection + 1;
    end
    
    if strcmp([AnalysisWindow(cnt1).RefTarDis(1) ' ' num2str(AnalysisWindow(cnt1).Safe)],'R 1')
        perf(cnt2).Safe = perf(cnt2).Safe + 1;
    end
    
    if strcmp([AnalysisWindow(cnt1).RefTarDis(1) ' ' num2str(AnalysisWindow(cnt1).Snooze)],'R 1')
        perf(cnt2).Snooze = perf(cnt2).Snooze + 1;
    end
    
end

if Tar == 0
    perf(cnt2).Hit(1) = NaN;
    perf(cnt2).Miss(1) = NaN;
end

if Dis == 0
    perf(cnt2).FalsePositive(1) = NaN;
    perf(cnt2).CorrectRejection(1) = NaN;
end

perf(cnt2).Hit(2) = Tarcnt;
perf(cnt2).Miss(2) = Tarcnt;
perf(cnt2).FalsePositive(2) = Discnt;
perf(cnt2).CorrectRejection(2) = Discnt;
perf(cnt2).Safe(2) = NumOfRef;
perf(cnt2).Snooze(2) = NumOfRef;


% Now calculate hit and miss rates both for entire experiment and this
% block only:
HitData = cat(1,perf.Hit);
MissData = cat(1,perf.Miss);
FalsePositiveData = cat(1,perf.FalsePositive);
CorrectRejectionData = cat(1,perf.CorrectRejection);
SafeData = cat(1,perf.Safe);
SnoozeData = cat(1,perf.Snooze);

perf(cnt2).HitRate              = nansum(HitData(:,1)) / (nansum(HitData(:,1)) + nansum(MissData(:,1)));
perf(cnt2).MissRate             = 1 - perf(cnt2).HitRate;
perf(cnt2).FalsePositiveRate    = nansum(FalsePositiveData(:,1)) / (nansum(FalsePositiveData(:,1)) + nansum(CorrectRejectionData(:,1)));
perf(cnt2).CorrectRejectionRate    = 1 - perf(cnt2).FalsePositiveRate;
perf(cnt2).SafeRate             = sum(SafeData(:,1))/sum(SafeData(:,2));
perf(cnt2).SnoozeRate             = sum(SnoozeData(:,1))/sum(SnoozeData(:,2));
perf(cnt2).DiscrimRate   = perf(cnt2).HitRate * perf(cnt2).SafeRate;

% also, a smooth version is necessary for the shortterm display:
NotNan=find(isnan(HitData(:,1))==0);
RecentIndex_temp = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
RecentTargetIndex=[];
for i = 1:length(RecentIndex_temp)
    if isempty(find(RecentIndex_temp(i)==NotNan))==0
        RecentTargetIndex = [RecentTargetIndex RecentIndex_temp(i)];
    end
end

NotNan=find(isnan(CorrectRejectionData(:,1))==0);
RecentIndex_temp = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
RecentDisIndex=[];
for i = 1:length(RecentIndex_temp)
    if isempty(find(RecentIndex_temp(i)==NotNan))==0
        RecentDisIndex = [RecentDisIndex RecentIndex_temp(i)];
    end
end

RecentRefIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;

if Tarcnt ~= 0
    perf(cnt2).RecentHitRate              = nansum(HitData(RecentTargetIndex,1)) / (nansum(HitData(RecentTargetIndex,1)) + nansum(MissData(RecentTargetIndex,1)));
    perf(cnt2).RecentMissRate             = 1 - perf(cnt2).RecentHitRate;
else
    perf(cnt2).RecentHitRate              = perf(max(1,cnt2-1)).RecentHitRate;
    perf(cnt2).RecentMissRate             = perf(max(1,cnt2-1)).RecentMissRate;
end

if Discnt ~= 0
perf(cnt2).RecentFalsePositiveRate    = nansum(FalsePositiveData(RecentDisIndex,1)) / (nansum(FalsePositiveData(RecentDisIndex,1)) + nansum(CorrectRejectionData(RecentDisIndex,1)));
perf(cnt2).RecentCorrectRejectionRate    = 1 - perf(cnt2).RecentFalsePositiveRate;
else
    perf(cnt2).RecentFalsePositiveRate              = perf(max(1,cnt2-1)).RecentFalsePositiveRate;
    perf(cnt2).RecentCorrectRejectionRate             = perf(max(1,cnt2-1)).RecentCorrectRejectionRate;
end


perf(cnt2).RecentSafeRate             = sum(SafeData(RecentRefIndex,1))/sum(SafeData(RecentRefIndex,2));
perf(cnt2).RecentSnoozeRate             = sum(SnoozeData(RecentRefIndex,1))/sum(SnoozeData(RecentRefIndex,2));
perf(cnt2).RecentDiscrimRate = perf(cnt2).RecentHitRate * perf(cnt2).RecentSafeRate;

% Now prepare one for display purpose and put it in last array of
% performance:
% change all rates to percentage. If its not rate, put the sum and
% 'out of'
PerfFields = fieldnames(perf);
for cnt1 = 1:length(PerfFields)
    if isnan(perf(cnt2).(PerfFields{cnt1})), perf(cnt2).(PerfFields{cnt1}) = 0;end
    if ~isempty(strfind(PerfFields{cnt1},'Rate')) || ~isempty(strfind(PerfFields{cnt1},'Index'))% if its a rate, do
        %not divide by number of trials, just make it percentage:
        perfPer.(PerfFields{cnt1}) = roundTo(perf(cnt2).(PerfFields{cnt1}),2)*100;
    else
        if isnumeric(perf(cnt2).(PerfFields{cnt1}))
            FeildData = cat(1,perf.(PerfFields{cnt1}));
            perfPer.(PerfFields{cnt1})(1)   = nansum(FeildData(:,1));
            perfPer.(PerfFields{cnt1})(2)   = nansum(FeildData(:,2));
        else
            perfPer.(PerfFields{cnt1})      = perf(cnt2).(PerfFields{cnt1});
        end
    end
end
exptparams.Performance(cnt2) = perf(cnt2);
exptparams.Performance(cnt2+1) = perfPer;

if Tar
  exptparams.Tarcnt = [exptparams.Tarcnt TrialIndex];
end

if Dis
  exptparams.Discnt = [exptparams.Discnt TrialIndex];
end
