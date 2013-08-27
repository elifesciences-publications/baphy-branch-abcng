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
AllRefLickHist = {};
AllTone1sLickHist={};
AllFM1sLickHist={};
AllTone3sLickHist={};
AllFM3sLickHist={};

NumOfEvPerStim = get(exptparams.TrialObject,'NumOfEvPerStim'); % how many sounds we have in each stim? ex: torc=3, discrim=6, etc..
if isfield(get(exptparams.TrialObject),'NumOfEvPerRef'),
    NumOfEvPerRef = get(exptparams.TrialObject,'NumOfEvPerRef');
    NumOfEvPerTar = get(exptparams.TrialObject,'NumOfEvPerTar');
    
else
    NumOfEvPerRef = NumOfEvPerStim;
    NumOfEvPerTar = NumOfEvPerStim;
    
end

cnt1 = 1;
Tone1s = 0;
Tone3s = 0;
FM1s = 0;
FM3s = 0;

%This loop collects the lick data for each reference and target stimulus
Tone1scnt=0;FM1scnt=0;Tone3scnt=0;FM3scnt=0;
while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim');
            
            NumOfRef = NumOfRef + strcmpi(StimRefOrTar,'Reference'); %accumilates the # of references in a trial
            
            PreLickWindow = get(o,'PreLickWindow');
            PostLickWindow = get(o,'PostLickWindow');
            ResponseTime = get(o,'ResponseTime');
            
            AnalysisWindow(end+1).PreWin = sort([StimEvents(cnt1).StartTime-PreLickWindow...
                StimEvents(cnt1).StartTime]);
            
            AnalysisWindow(end).PosWin = sort([(StimEvents(cnt1).StopTime+ResponseTime)  ...
                (StimEvents(cnt1).StartTime+ResponseTime+-PostLickWindow)]);
            
            % max in the following line prohibit the negaive or zero indexing:
            AnalysisWindow(end).PreLick = ...
                ~isempty(find(LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1)):...
                max(1,fs*AnalysisWindow(end).PreWin(2)))),1));
            AnalysisWindow(end).PosLick = ...
                ~isempty(find(LickData(ceil(fs*AnalysisWindow(end).PosWin(1):min(length(LickData),fs*AnalysisWindow(end).PosWin(2)))),1));
            AnalysisWindow(end).PreLickAvg = ...
                (LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1))+1:...
                max(1,fs*AnalysisWindow(end).PreWin(2)))));
            
            % In the following block, we obtain the lick data for references and targets
            if strcmpi(StimRefOrTar,'Reference')
                AllRefLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                AnalysisWindow(end).RefToneFM = 'Rf';
                AnalysisWindow(end).Snooze = ...
                    isempty(find(LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs)))),1));
                AnalysisWindow(end).Safe = ...
                    sum([find(LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StartTime.*fs)))+(fs*PreLickWindow)),1)...
                    find(LickData(ceil(single((StimEvents(cnt1).StopTime.*fs)))-(fs*PreLickWindow):ceil(single((StimEvents(cnt1).StopTime.*fs)))),1)])>1;
                
            else
                if StimEvents(cnt1).Rove(1) == 1
                    Tone1scnt = Tone1scnt+1;
                    Tone1s = 1;
                    AllTone1sLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime).*fs))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                    
                    % Also get the name of the target sound:
                    TargetName = StimName;
                    AnalysisWindow(end).RefToneFM = 'T1';
                    
                elseif StimEvents(cnt1).Rove(1) == 2
                    Tone3scnt = Tone3scnt+1;
                    Tone3s = 1;
                    AllTone3sLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime).*fs))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                    
                    % Also get the name of the target sound:
                    TargetName = StimName;
                    AnalysisWindow(end).RefToneFM = 'T3';
                    
                elseif StimEvents(cnt1).Rove(1) == 3
                    FM1scnt = FM1scnt+1;
                    FM1s = 1;
                    AllFM1sLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime).*fs))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                    
                    % Also get the name of the target sound:
                    TargetName = StimName;
                    AnalysisWindow(end).RefToneFM = 'F1';
                    
                elseif StimEvents(cnt1).Rove(1) == 4
                    FM3scnt = FM3scnt+1;
                    FM3s = 1;
                    AllFM3sLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime).*fs))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                    
                    % Also get the name of the target sound:
                    TargetName = StimName;
                    AnalysisWindow(end).RefToneFM = 'F3';
                    
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
RefDur = get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration');
PossibleToneDurs = get(get(exptparams.TrialObject,'TargetHandle'),'Duration');
PossibleFMDurs = PossibleToneDurs;

if ~isfield(exptparams, 'AllRefLick') || (TrialIndex ==1)
    exptparams.AllTone1sLick.Hist     = [];
    exptparams.AllTone1sLick.Num      =  zeros(1,length(PossibleToneDurs));
    exptparams.AllTone3sLick.Hist     = [];
    exptparams.AllTone3sLick.Num      =  zeros(1,length(PossibleToneDurs));
    exptparams.AllFM1sLick.Hist     = [];
    exptparams.AllFM1sLick.Num      =  zeros(1,length(PossibleToneDurs));
    exptparams.AllFM3sLick.Hist     = [];
    exptparams.AllFM3sLick.Num      =  zeros(1,length(PossibleToneDurs));
    exptparams.AllRefLick.Hist    = [];
    exptparams.AllRefLick.Num     = 0;
    exptparams.Tone1scnt = [];
    exptparams.Tone3scnt = [];
    exptparams.FM1scnt = [];
    exptparams.FM3scnt = [];
    
end

for cnt1 = 1:length(AllRefLickHist)
    
    if isempty(exptparams.AllRefLick.Hist)
        exptparams.AllRefLick.Hist=AllRefLickHist{cnt1};
        
    else
        exptparams.AllRefLick.Hist=[exptparams.AllRefLick.Hist AllRefLickHist{cnt1}];
        
    end
    
    exptparams.AllRefLick.Num = exptparams.AllRefLick.Num+1;
    
end

if Tone1s == 1
    for cnt1 = 1:length(AllTone1sLickHist)
        
        if isempty(exptparams.AllTone1sLick.Hist)
            exptparams.AllTone1sLick.Hist=AllTone1sLickHist{cnt1};
            
        else
            exptparams.AllTone1sLick.Hist=[exptparams.AllTone1sLick.Hist AllTone1sLickHist{cnt1}];
            
        end
        
        exptparams.AllTone1sLick.Num = exptparams.AllTone1sLick.Num+1;
        
    end
end

if Tone3s == 1
    for cnt1 = 1:length(AllTone3sLickHist)
        
        if isempty(exptparams.AllTone3sLick.Hist)
            exptparams.AllTone3sLick.Hist=AllTone3sLickHist{cnt1};
            
        else
            exptparams.AllTone3sLick.Hist=[exptparams.AllTone3sLick.Hist AllTone3sLickHist{cnt1}];
            
        end
        
        exptparams.AllTone3sLick.Num = exptparams.AllTone3sLick.Num+1;
        
    end
end

if FM1s == 1
    for cnt1 = 1:length(AllFM1sLickHist)
        
        if isempty(exptparams.AllFM1sLick.Hist)
            exptparams.AllFM1sLick.Hist=AllFM1sLickHist{cnt1};
            
        else
            exptparams.AllFM1sLick.Hist=[exptparams.AllFM1sLick.Hist AllFM1sLickHist{cnt1}];
            
        end
        
        exptparams.AllFM1sLick.Num = exptparams.AllFM1sLick.Num+1;
        
    end
end

if FM3s == 1
    for cnt1 = 1:length(AllFM3sLickHist)
        
        if isempty(exptparams.AllFM3sLick.Hist)
            exptparams.AllFM3sLick.Hist=AllFM3sLickHist{cnt1};
            
        else
            exptparams.AllFM3sLick.Hist=[exptparams.AllFM3sLick.Hist AllFM3sLickHist{cnt1}];
            
        end
        
        exptparams.AllFM3sLick.Num = exptparams.AllFM3sLick.Num+1;
        
    end
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

perf(cnt2).T1Hit = 0; perf(cnt2).T1HitRate = 0; perf(cnt2).RecentT1HitRate=0;
perf(cnt2).T3Hit = 0; perf(cnt2).T3HitRate = 0; perf(cnt2).RecentT3HitRate=0;
perf(cnt2).FM1Hit = 0; perf(cnt2).FM1HitRate = 0; perf(cnt2).RecentFM1HitRate=0;
perf(cnt2).FM3Hit = 0; perf(cnt2).FM3HitRate = 0; perf(cnt2).RecentFM3HitRate=0;

perf(cnt2).T1Miss = 0; perf(cnt2).T1MissRate = 0; perf(cnt2).RecentT1MissRate=0;
perf(cnt2).T3Miss = 0; perf(cnt2).T3MissRate = 0; perf(cnt2).RecentT3MissRate=0;
perf(cnt2).FM1Miss = 0; perf(cnt2).FM1MissRate = 0; perf(cnt2).RecentFM1MissRate=0;
perf(cnt2).FM3Miss = 0; perf(cnt2).FM3MissRate = 0; perf(cnt2).RecentFM3MissRate=0;

perf(cnt2).Safe = 0; perf(cnt2).SafeRate = 0; perf(cnt2).RecentSafeRate=0;
perf(cnt2).Snooze = 0; perf(cnt2).SnoozeRate = 0; perf(cnt2).RecentSnoozeRate=0;

perf(cnt2).T1DiscrimRate = 0; perf(cnt2).RecentT1DiscrimRate =0;
perf(cnt2).T3DiscrimRate = 0; perf(cnt2).RecentT3DiscrimRate =0;
perf(cnt2).FM1DiscrimRate = 0; perf(cnt2).RecentFM1DiscrimRate =0;
perf(cnt2).FM3DiscrimRate = 0; perf(cnt2).RecentFM3DiscrimRate =0;

%Code performance
for cnt1 = 1:length(AnalysisWindow)
    switch [AnalysisWindow(cnt1).RefToneFM ' ' num2str(AnalysisWindow(cnt1).PreLick) ...
            ' ' num2str(AnalysisWindow(cnt1).PosLick)]
        case 'T1 1 0', % Hit
            perf(cnt2).T1Hit = perf(cnt2).T1Hit + 1;
        case 'T1 1 1', % Miss
            perf(cnt2).T1Miss = perf(cnt2).T1Miss + 1;
        case 'T3 1 0', % Hit
            perf(cnt2).T3Hit = perf(cnt2).T3Hit + 1;
        case 'T3 1 1', % Miss
            perf(cnt2).T3Miss = perf(cnt2).T3Miss + 1;
        case 'F1 1 0', % Hit
            perf(cnt2).FM1Hit = perf(cnt2).FM1Hit + 1;
        case 'F1 1 1', % Miss
            perf(cnt2).FM1Miss = perf(cnt2).FM1Miss + 1;
        case 'F3 1 0', % Hit
            perf(cnt2).FM3Hit = perf(cnt2).FM3Hit + 1;
        case 'F3 1 1', % Miss
            perf(cnt2).FM3Miss = perf(cnt2).FM3Miss + 1;
            
    end
    
    if strcmp([AnalysisWindow(cnt1).RefToneFM ' ' num2str(AnalysisWindow(cnt1).Safe)],'Rf 1')
        perf(cnt2).Safe = perf(cnt2).Safe + 1;
    end
    
    if strcmp([AnalysisWindow(cnt1).RefToneFM ' ' num2str(AnalysisWindow(cnt1).Snooze)],'Rf 1')
        perf(cnt2).Snooze = perf(cnt2).Snooze + 1;
    end
    
end

if Tone1s == 0
    perf(cnt2).T1Hit(1) = NaN;
    perf(cnt2).T1Miss(1) = NaN;
end

if Tone3s == 0
    perf(cnt2).T3Hit(1) = NaN;
    perf(cnt2).T3Miss(1) = NaN;
end

if FM1s == 0
    perf(cnt2).FM1Hit(1) = NaN;
    perf(cnt2).FM1Miss(1) = NaN;
end

if FM3s == 0
    perf(cnt2).FM3Hit(1) = NaN;
    perf(cnt2).FM3Miss(1) = NaN;
end

perf(cnt2).T1Hit(2) = Tone1scnt;
perf(cnt2).T1Miss(2) = Tone1scnt;
perf(cnt2).T3Hit(2) = Tone3scnt;
perf(cnt2).T3Miss(2) = Tone3scnt;
perf(cnt2).FM1Hit(2) = FM1scnt;
perf(cnt2).FM1Miss(2) = FM1scnt;
perf(cnt2).FM3Hit(2) = FM3scnt;
perf(cnt2).FM3Miss(2) = FM3scnt;
perf(cnt2).Safe(2) = NumOfRef;
perf(cnt2).Snooze(2) = NumOfRef;

% Now calculate hit and miss rates both for entire experiment and this
% block only:
T1HitData = cat(1,perf.T1Hit);
T1MissData = cat(1,perf.T1Miss);
T3HitData = cat(1,perf.T3Hit);
T3MissData = cat(1,perf.T3Miss);
FM1HitData = cat(1,perf.FM1Hit);
FM1MissData = cat(1,perf.FM1Miss);
FM3HitData = cat(1,perf.FM3Hit);
FM3MissData = cat(1,perf.FM3Miss);
SafeData = cat(1,perf.Safe);
SnoozeData = cat(1,perf.Snooze);

perf(cnt2).T1HitRate              = nansum(T1HitData(:,1)) / (nansum(T1HitData(:,1)) + nansum(T1MissData(:,1)));
perf(cnt2).T1MissRate             = 1 - perf(cnt2).T1HitRate;
perf(cnt2).T3HitRate              = nansum(T3HitData(:,1)) / (nansum(T3HitData(:,1)) + nansum(T3MissData(:,1)));
perf(cnt2).T3MissRate             = 1 - perf(cnt2).T3HitRate;
perf(cnt2).FM1HitRate              = nansum(FM1HitData(:,1)) / (nansum(FM1HitData(:,1)) + nansum(FM1MissData(:,1)));
perf(cnt2).FM1MissRate             = 1 - perf(cnt2).FM1HitRate;
perf(cnt2).FM3HitRate              = nansum(FM3HitData(:,1)) / (nansum(FM3HitData(:,1)) + nansum(FM3MissData(:,1)));
perf(cnt2).FM3MissRate             = 1 - perf(cnt2).FM3HitRate;

perf(cnt2).SafeRate             = sum(SafeData(:,1))/sum(SafeData(:,2));
perf(cnt2).SnoozeRate             = sum(SnoozeData(:,1))/sum(SnoozeData(:,2));

perf(cnt2).T1DiscrimRate   = perf(cnt2).T1HitRate * perf(cnt2).SafeRate;
perf(cnt2).T3DiscrimRate   = perf(cnt2).T3HitRate * perf(cnt2).SafeRate;
perf(cnt2).FM1DiscrimRate   = perf(cnt2).FM1HitRate * perf(cnt2).SafeRate;
perf(cnt2).FM1DiscrimRate   = perf(cnt2).FM1HitRate * perf(cnt2).SafeRate;

% also, a smooth version is necessary for the shortterm display:
NotNan=find(isnan(T1HitData(:,1))==0);
RecentIndex_temp = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
RecentT1Index=[];
for i = 1:length(RecentIndex_temp)
    if isempty(find(RecentIndex_temp(i)==NotNan))==0
        RecentT1Index = [RecentT1Index RecentIndex_temp(i)];
    end
end

NotNan=find(isnan(T3HitData(:,1))==0);
RecentIndex_temp = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
RecentT3Index=[];
for i = 1:length(RecentIndex_temp)
    if isempty(find(RecentIndex_temp(i)==NotNan))==0
        RecentT3Index = [RecentT3Index RecentIndex_temp(i)];
    end
end

NotNan=find(isnan(FM1HitData(:,1))==0);
RecentIndex_temp = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
RecentFM1Index=[];
for i = 1:length(RecentIndex_temp)
    if isempty(find(RecentIndex_temp(i)==NotNan))==0
        RecentFM1Index = [RecentFM1Index RecentIndex_temp(i)];
    end
end

NotNan=find(isnan(FM3HitData(:,1))==0);
RecentIndex_temp = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;
RecentFM3Index=[];
for i = 1:length(RecentIndex_temp)
    if isempty(find(RecentIndex_temp(i)==NotNan))==0
        RecentFM3Index = [RecentFM3Index RecentIndex_temp(i)];
    end
end

RecentRefIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;

if Tone1scnt ~= 0
    perf(cnt2).RecentT1HitRate              = nansum(T1HitData(RecentT1Index,1)) / (nansum(T1HitData(RecentT1Index,1)) + nansum(T1MissData(RecentT1Index,1)));
else
    perf(cnt2).RecentT1HitRate              = perf(max(1,cnt2-1)).RecentT1HitRate;
end

if Tone3scnt ~= 0
    perf(cnt2).RecentT3HitRate              = nansum(T3HitData(RecentT3Index,1)) / (nansum(T3HitData(RecentT3Index,1)) + nansum(T3MissData(RecentT3Index,1)));
else
    perf(cnt2).RecentT3HitRate              = perf(max(1,cnt2-1)).RecentT3HitRate;
end

if FM1scnt ~= 0
    perf(cnt2).RecentFM1HitRate              = nansum(FM1HitData(RecentFM1Index,1)) / (nansum(FM1HitData(RecentFM1Index,1)) + nansum(FM1MissData(RecentFM1Index,1)));
else
    perf(cnt2).RecentFM1HitRate              = perf(max(1,cnt2-1)).RecentFM1HitRate;
end

if FM3scnt ~= 0
    perf(cnt2).RecentFM3HitRate              = nansum(FM3HitData(RecentFM3Index,1)) / (nansum(FM3HitData(RecentFM3Index,1)) + nansum(FM3MissData(RecentFM3Index,1)));
else
    perf(cnt2).RecentFM3HitRate              = perf(max(1,cnt2-1)).RecentFM3HitRate;
end

perf(cnt2).RecentSafeRate             = sum(SafeData(RecentRefIndex,1))/sum(SafeData(RecentRefIndex,2));
perf(cnt2).RecentSnoozeRate             = sum(SnoozeData(RecentRefIndex,1))/sum(SnoozeData(RecentRefIndex,2));

perf(cnt2).RecentT1DiscrimRate = perf(cnt2).RecentT1HitRate * perf(cnt2).RecentSafeRate;
perf(cnt2).RecentT3DiscrimRate = perf(cnt2).RecentT3HitRate * perf(cnt2).RecentSafeRate;
perf(cnt2).RecentFM1DiscrimRate = perf(cnt2).RecentFM1HitRate * perf(cnt2).RecentSafeRate;
perf(cnt2).RecentFM3DiscrimRate = perf(cnt2).RecentFM3HitRate * perf(cnt2).RecentSafeRate;


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

if Tone1s
  exptparams.Tone1scnt = [exptparams.Tone1scnt TrialIndex];
end

if Tone3s
  exptparams.Tone3scnt = [exptparams.Tone3scnt TrialIndex];
end

if FM1s
  exptparams.FM1scnt = [exptparams.FM1scnt TrialIndex];
end

if FM3s
  exptparams.FM3scnt = [exptparams.FM3scnt TrialIndex];
end

