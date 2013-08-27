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
AllTarLickHist={};
TarDurs=[];

NumOfEvPerStim = get(exptparams.TrialObject,'NumOfEvPerStim'); % how many sounds we have in each stim? ex: torc=3, discrim=6, etc..
if isfield(get(exptparams.TrialObject),'NumOfEvPerRef'),
    NumOfEvPerRef = get(exptparams.TrialObject,'NumOfEvPerRef');
    NumOfEvPerTar = get(exptparams.TrialObject,'NumOfEvPerTar');
    
else
    NumOfEvPerRef = NumOfEvPerStim;
    NumOfEvPerTar = NumOfEvPerStim;
    
end

cnt1 = 1;

TrialObject = get(exptparams.TrialObject);
TargetObject = get(TrialObject.TargetHandle);
ReferenceObject = get(TrialObject.ReferenceHandle);
RefPreStimSilence = ReferenceObject.PreStimSilence;
RefPostStimSilence = ReferenceObject.PostStimSilence;
TarPreStimSilence = TargetObject.PreStimSilence;
TarPostStimSilence = TargetObject.PostStimSilence;


%This loop collects the lick data for each reference and target stimulus
Tarcnt=0;Discnt=0;
while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim');
            
            NumOfRef = NumOfRef + strcmpi(StimRefOrTar,'Reference'); %accumilates the # of references in a trial
            
            PreLickWindow = get(o,'PreLickWindow');
            PostLickWindow = get(o,'PostLickWindow');
              ResponseTime = get(o,'ResponseTime');
          
            if strcmpi(StimRefOrTar,'Reference')
                
                AnalysisWindow(end+1).PreWin = [StimEvents(cnt1).StartTime...
                    StimEvents(cnt1).StartTime+PreLickWindow];
                
                AnalysisWindow(end).PosWin = sort([(StimEvents(cnt1).StopTime)  ...
                    (StimEvents(cnt1).StopTime+PostLickWindow)]);
            elseif strcmpi(StimRefOrTar,'Target')
                AnalysisWindow(end+1).PreWin = [StimEvents(cnt1).StartTime -  (TarPreStimSilence+RefPostStimSilence+PreLickWindow)...
                    StimEvents(cnt1).StartTime];
                
                AnalysisWindow(end).PosWin = sort([(StimEvents(cnt1).StartTime+ResponseTime)  ...
                    (StimEvents(cnt1).StopTime)]);
                
            end

            % max in the following line prohibit the negaive or zero indexing:
            AnalysisWindow(end).PreLick = ...
                ~isempty(find(LickData(ceil(max(1,fs*AnalysisWindow(end).PreWin(1)):...
                max(1,fs*AnalysisWindow(end).PreWin(2)))),1));
            AnalysisWindow(end).PosLick = ...
                ~isempty(find(LickData(ceil(fs*AnalysisWindow(end).PosWin(1):min(length(LickData),fs*AnalysisWindow(end).PosWin(2)))),1));
            
            % In the following block, we obtain the lick data for references and targets
            if strcmpi(StimRefOrTar,'Reference')
                AllRefLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                AnalysisWindow(end).RefTarDis = 'Reference';
                AnalysisWindow(end).Snooze = ...
                    isempty(find(LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StopTime.*fs)))),1));
                AnalysisWindow(end).Safe = ...
                    sum([find(LickData(ceil(single((StimEvents(cnt1).StartTime.*fs)))+1:ceil(single((StimEvents(cnt1).StartTime.*fs)))+(fs*PreLickWindow)),1)...
                    find(LickData(ceil(single((StimEvents(cnt1).StopTime.*fs)))-(fs*PreLickWindow):ceil(single((StimEvents(cnt1).StopTime.*fs)))),1)])>1;
                
            else
                Tarcnt = Tarcnt+1;
                AllTarLickHist{end+1} = LickData(ceil(single((StimEvents(cnt1).StartTime).*fs))+1:ceil(single((StimEvents(cnt1).StopTime.*fs))));
                
                % Also get the name of the target sound:
                TargetName = StimName;
                TarDurs = [TarDurs; StimEvents(cnt1).Rove(1)];
                AnalysisWindow(end).RefTarDis = 'Target';
                
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
TarDur = get(get(exptparams.TrialObject,'TargetHandle'),'Duration');
PossibleTarDurs = TarDur;

if ~isfield(exptparams, 'AllRefLick') || (TrialIndex ==1)
    exptparams.AllTarLick.Hist{1}     = [];
    exptparams.AllTarLick.Hist{2}     = [];
    exptparams.AllTarLick.Hist{3}     = [];
    exptparams.AllTarLick.Num      =  zeros(1,length(PossibleTarDurs));
    exptparams.AllRefLick.Hist    = [];
    exptparams.AllRefLick.Num     = 0;
    exptparams.Tarcnt = [];
    
end

for cnt1 = 1:length(AllRefLickHist)
    
    if isempty(exptparams.AllRefLick.Hist)
        exptparams.AllRefLick.Hist{1}=vertical(AllRefLickHist{cnt1});
        
    else
        exptparams.AllRefLick.Hist{1}=[exptparams.AllRefLick.Hist{1} vertical(AllRefLickHist{cnt1})];
        
    end
    
    exptparams.AllRefLick.Num = exptparams.AllRefLick.Num+1;
    
end

for cnt1 = 1:length(AllTarLickHist)
    DurIndex = find(TarDurs(cnt1) == PossibleTarDurs);
    
    if isempty(exptparams.AllTarLick.Hist) || length(exptparams.AllTarLick.Hist) < DurIndex
        exptparams.AllTarLick.Hist{DurIndex}=vertical(AllTarLickHist{cnt1});
        
    elseif isempty(exptparams.AllTarLick.Hist{DurIndex})
        exptparams.AllTarLick.Hist{DurIndex}=vertical(AllTarLickHist{cnt1});
        
    else
        exptparams.AllTarLick.Hist{DurIndex}=[exptparams.AllTarLick.Hist{DurIndex} vertical(AllTarLickHist{cnt1})];
        
    end
    
    exptparams.AllTarLick.Num(DurIndex) = exptparams.AllTarLick.Num(DurIndex)+1;
    
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
perf(cnt2).Safe = 0; perf(cnt2).SafeRate = 0; perf(cnt2).RecentSafeRate=0;
perf(cnt2).Snooze = 0; perf(cnt2).SnoozeRate = 0; perf(cnt2).RecentSnoozeRate=0;
perf(cnt2).DiscrimRate = 0; perf(cnt2).RecentDiscrimRate =0;
perf(cnt2).HitS=0;
perf(cnt2).HitM=0;
perf(cnt2).HitL=0;
perf(cnt2).HitRateS=0;
perf(cnt2).HitRateM=0;
perf(cnt2).HitRateL=0;

perf(cnt2).MissS=0;
perf(cnt2).MissM=0;
perf(cnt2).MissL=0;
perf(cnt2).MissRateS=0;
perf(cnt2).MissRateM=0;
perf(cnt2).MissRateL=0;
%Code performance
for cnt1 = 1:length(AnalysisWindow)
    switch [AnalysisWindow(cnt1).RefTarDis(1) ' ' num2str(AnalysisWindow(cnt1).PreLick) ...
            ' ' num2str(AnalysisWindow(cnt1).PosLick)]
        
        case 'T 1 0', % Hit
            LengthIndex = find(TarDurs == PossibleTarDurs);
            perf(cnt2).Hit = perf(cnt2).Hit + 1;
            if LengthIndex == 1
                perf(cnt2).HitS = perf(cnt2).HitS + 1;
            elseif LengthIndex == 2
                perf(cnt2).HitM = perf(cnt2).HitM + 1;
            elseif LengthIndex == 3
                perf(cnt2).HitL = perf(cnt2).HitL + 1;
            end
            
        case 'T 1 1', % Miss
            LengthIndex = find(TarDurs == PossibleTarDurs);
            perf(cnt2).Miss = perf(cnt2).Miss + 1;
            if LengthIndex == 1
                perf(cnt2).MissS = perf(cnt2).MissS + 1;
            elseif LengthIndex == 2
                perf(cnt2).MissM = perf(cnt2).MissM + 1;
            elseif LengthIndex == 3
                perf(cnt2).MissL = perf(cnt2).MissL + 1;
            end
            
    end
    
    if strcmp([AnalysisWindow(cnt1).RefTarDis(1) ' ' num2str(AnalysisWindow(cnt1).Safe)],'R 1')
        perf(cnt2).Safe = perf(cnt2).Safe + 1;
    end
    
    if strcmp([AnalysisWindow(cnt1).RefTarDis(1) ' ' num2str(AnalysisWindow(cnt1).Snooze)],'R 1')
        perf(cnt2).Snooze = perf(cnt2).Snooze + 1;
    end
    
end

perf(cnt2).Hit(2) = Tarcnt;
perf(cnt2).Miss(2) = Tarcnt;
perf(cnt2).Safe(2) = NumOfRef;
perf(cnt2).Snooze(2) = NumOfRef;
perf(cnt2).HitS(2)=Tarcnt;
perf(cnt2).HitM(2)=Tarcnt;
perf(cnt2).HitL(2)=Tarcnt;
perf(cnt2).MissS(2)=Tarcnt;
perf(cnt2).MissM(2)=Tarcnt;
perf(cnt2).MissL(2)=Tarcnt;


% Now calculate hit and miss rates both for entire experiment and this
% block only:
HitData = cat(1,perf.Hit);
HitDataS = cat(1,perf.HitS);
HitDataM = cat(1,perf.HitM);
HitDataL = cat(1,perf.HitL);
MissData = cat(1,perf.Miss);
MissDataS = cat(1,perf.MissS);
MissDataM = cat(1,perf.MissM);
MissDataL = cat(1,perf.MissL);
SafeData = cat(1,perf.Safe);
SnoozeData = cat(1,perf.Snooze);

perf(cnt2).HitRate              = nansum(HitData(:,1)) / (nansum(HitData(:,1)) + nansum(MissData(:,1)));
perf(cnt2).HitRateS              = nansum(HitDataS(:,1)) / (nansum(HitDataS(:,1)) + nansum(MissDataS(:,1)));
perf(cnt2).HitRateM              = nansum(HitDataM(:,1)) / (nansum(HitDataM(:,1)) + nansum(MissDataM(:,1)));
perf(cnt2).HitRateL              = nansum(HitDataL(:,1)) / (nansum(HitDataL(:,1)) + nansum(MissDataL(:,1)));

perf(cnt2).MissRate             = 1 - perf(cnt2).HitRate;
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

RecentRefIndex = max(1 , TrialIndex-exptparams.TrialBlock+1):TrialIndex;

perf(cnt2).RecentHitRate              = nansum(HitData(RecentTargetIndex,1)) / (nansum(HitData(RecentTargetIndex,1)) + nansum(MissData(RecentTargetIndex,1)));
perf(cnt2).RecentMissRate             = 1 - perf(cnt2).HitRate;
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

exptparams.Tarcnt = [exptparams.Tarcnt TrialIndex];
