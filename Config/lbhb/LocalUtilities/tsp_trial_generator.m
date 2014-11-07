clear exptparams;
exptparams(1).TrialObject(1).descriptor = 'MultiRefTar';
exptparams(1).TrialObject(1).ReferenceClass = 'SpNoise';

% exptparams(1).TrialObject(1).ReferenceHandle = handle of a SpNoise object
exptparams(1).TrialObject(1).ReferenceHandle(1).descriptor = 'SpNoise';
exptparams(1).TrialObject(1).ReferenceHandle(1).SamplingRate = 100000;
exptparams(1).TrialObject(1).ReferenceHandle(1).Loudness = 0;
exptparams(1).TrialObject(1).ReferenceHandle(1).PreStimSilence = 0.5;
exptparams(1).TrialObject(1).ReferenceHandle(1).PostStimSilence = 0.5;
exptparams(1).TrialObject(1).ReferenceHandle(1).Names = {'BNB+si464+si2077', 'BNB+si464+si2077', 'BNB+si464+si2077', 'BNB+si464+si2077', 'BNB+si464+si2077', 'BNB+si516+si2004', 'BNB+si530+si1377', 'BNB+si567+si664', 'BNB+si590+si516', 'BNB+si664+si1824', 'BNB+si748+si2180', 'BNB+si756+si1112', 'BNB+si860+si464', 'BNB+si919+si748', 'BNB+si920+si1105', 'BNB+si953+si860', 'BNB+si1079+si953', 'BNB+si1105+si1798', 'BNB+si1112+si1908', 'BNB+si1138+si2262', 'BNB+si1230+si756', 'BNB+si1377+si1742', 'BNB+si1742+si1138', 'BNB+si1798+si2196', 'BNB+si1824+si919', 'BNB+si1889+si590', 'BNB+si1908+si2260', 'BNB+si2004+si530', 'BNB+si2016+si1889', 'BNB+si2077+si920', 'BNB+si2180+si2016', 'BNB+si2196+si1079', 'BNB+si2260+si567', 'BNB+si2262+si1230'};
exptparams(1).TrialObject(1).ReferenceHandle(1).MaxIndex = 34;
exptparams(1).TrialObject(1).ReferenceHandle(1).UserDefinableFields = {'PreStimSilence', 'edit', 0, 'PostStimSilence', 'edit', 0, 'LowFreq', 'edit', 1000, 'HighFreq', 'edit', 2000, 'RelAttenuatedB', 'edit', 0, 'SplitChannels', 'popupmenu', 'No|Yes', 'BaseSound', 'popupmenu', 'Speech|FerretVocal', 'Subsets', 'edit', 1, 'IterateStepMS', 'edit', 0, 'IterationCount', 'edit', 0, 'TonesPerOctave', 'edit', 0, 'UseBPNoise', 'edit', 1, 'ShuffleOnset', 'edit', 0, 'SetSizeMult', 'edit', 2, 'CoherentFrac', 'edit', 0.1, 'BaselineFrac', 'edit', 0, 'RepIdx', 'edit', [0 1], 'Duration', 'edit', 3};
exptparams(1).TrialObject(1).ReferenceHandle(1).LowFreq = [400 3000];
exptparams(1).TrialObject(1).ReferenceHandle(1).HighFreq = [650 6000];
exptparams(1).TrialObject(1).ReferenceHandle(1).RelAttenuatedB = 0;
exptparams(1).TrialObject(1).ReferenceHandle(1).SplitChannels = 'Yes';
exptparams(1).TrialObject(1).ReferenceHandle(1).IterateStepMS = 0;
exptparams(1).TrialObject(1).ReferenceHandle(1).IterationCount = 0;
exptparams(1).TrialObject(1).ReferenceHandle(1).TonesPerOctave = 0;
exptparams(1).TrialObject(1).ReferenceHandle(1).BaseSound = 'Speech     ';
exptparams(1).TrialObject(1).ReferenceHandle(1).TonesPerBurst = [0 0];
exptparams(1).TrialObject(1).ReferenceHandle(1).UseBPNoise = 1;
exptparams(1).TrialObject(1).ReferenceHandle(1).Subsets = 1;
exptparams(1).TrialObject(1).ReferenceHandle(1).SNR = 1000;
exptparams(1).TrialObject(1).ReferenceHandle(1).ShuffleOnset = 2;
exptparams(1).TrialObject(1).ReferenceHandle(1).SetSizeMult = 1;
exptparams(1).TrialObject(1).ReferenceHandle(1).CoherentFrac = 0;
exptparams(1).TrialObject(1).ReferenceHandle(1).BaselineFrac = 0.15;
exptparams(1).TrialObject(1).ReferenceHandle(1).emtx = [];
exptparams(1).TrialObject(1).ReferenceHandle(1).idxset = [1 26;1 26;1 26;1 26;1 26;2 24;3 18;4 6;5 2;6 21;7 27;8 15;9 1;10 7;11 14;12 9;13 12;14 20;15 23;16 30;17 8;18 19;19 16;20 28;21 10;22 5;23 29;24 3;25 22;26 11;27 25;28 13;29 4;30 17];
exptparams(1).TrialObject(1).ReferenceHandle(1).ShuffledOnsetTimes = [2 2.5;2 2.5;2 2.5;2 2.5;2 2.5;0.5 1.5;0 0;0 2.5;1 1;1.5 1.5;2 1;2 2;0.5 2;1 1.5;1.5 2;1 1.5;2.5 1;0.5 0.5;0.5 0;1 2.5;0 1.5;0 2;1.5 2.5;2 0;2.5 0;2 2.5;0.5 0;0 0.5;0 0;0.5 1;2.5 1;2.5 0.5;0.5 0;0.5 0.5];
exptparams(1).TrialObject(1).ReferenceHandle(1).SamplingRateEnv = 2000;
exptparams(1).TrialObject(1).ReferenceHandle(1).Duration = 6;
exptparams(1).TrialObject(1).ReferenceHandle(1).RepIdx = [1 5];

exptparams(1).TrialObject(1).TargetClass = 'JitterTone';

% exptparams(1).TrialObject(1).TargetHandle = handle of a JitterTone object
exptparams(1).TrialObject(1).TargetHandle(1).descriptor = 'JitterTone';
exptparams(1).TrialObject(1).TargetHandle(1).SamplingRate = 100000;
exptparams(1).TrialObject(1).TargetHandle(1).Loudness = 0;
exptparams(1).TrialObject(1).TargetHandle(1).PreStimSilence = 0.5;
exptparams(1).TrialObject(1).TargetHandle(1).PostStimSilence = 0.5;
exptparams(1).TrialObject(1).TargetHandle(1).Names = {'500', '4000'};
exptparams(1).TrialObject(1).TargetHandle(1).MaxIndex = 2;
exptparams(1).TrialObject(1).TargetHandle(1).UserDefinableFields = {'PreStimSilence', 'edit', 0, 'PostStimSilence', 'edit', 0, 'Frequencies', 'edit', 1000, 'SplitChannels', 'popupmenu', 'No|Yes', 'ChordCount', 'edit', 1, 'ChordWidth', 'edit', 0.2, 'JitterOctaves', 'edit', 0, 'Duration', 'edit', 1};
exptparams(1).TrialObject(1).TargetHandle(1).Frequencies = [500 4000];
exptparams(1).TrialObject(1).TargetHandle(1).SplitChannels = 'Yes';
exptparams(1).TrialObject(1).TargetHandle(1).ChordCount = 1;
exptparams(1).TrialObject(1).TargetHandle(1).ChordWidth = 0.2;
exptparams(1).TrialObject(1).TargetHandle(1).JitterOctaves = 0.1;
exptparams(1).TrialObject(1).TargetHandle(1).Duration = 0.75;

exptparams(1).TrialObject(1).SamplingRate = 100000;
exptparams(1).TrialObject(1).OveralldB = 65;
exptparams(1).TrialObject(1).RelativeTarRefdB = [-5 -5];
exptparams(1).TrialObject(1).RefTarFlipFreq = 0;
exptparams(1).TrialObject(1).ReferenceCountFreq = [0 0 0.2 0.4 0.3 0.2 0.1 0];
exptparams(1).TrialObject(1).TargetIdxFreq = [0.8 0];
exptparams(1).TrialObject(1).TargetChannel = [1 2];
exptparams(1).TrialObject(1).CatchIdxFreq = [0 0.1];
exptparams(1).TrialObject(1).CatchChannel = 2;
exptparams(1).TrialObject(1).CueTrialCount = 5;
exptparams(1).TrialObject(1).SingleRefSegmentLen = 0.4;
exptparams(1).TrialObject(1).TarIdxSet = [2 1 1 1 1 1 1 1 2 1 1 1 2 1 1 1 1 2 1 1 1 1 1 1 2 2 2 1 1 1 1 1 1 1 2 1 2];
exptparams(1).TrialObject(1).CatchIdxSet = zeros(1,0);
exptparams(1).TrialObject(1).CatchSeg = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
exptparams(1).TrialObject(1).OverlapRefTar = 'Yes';
exptparams(1).TrialObject(1).PostTrialSilence = 1;
exptparams(1).TrialObject(1).OnsetRampTime = 0.1;
exptparams(1).TrialObject(1).SaveData = 'Yes';
exptparams(1).TrialObject(1).TargetMatchContour = 'No';
exptparams(1).TrialObject(1).NumberOfTrials = 34;
exptparams(1).TrialObject(1).NumberOfRefPerTrial = [];
exptparams(1).TrialObject(1).NumberOfTarPerTrial = 1;
exptparams(1).TrialObject(1).ReferenceMaxIndex = 34;
exptparams(1).TrialObject(1).TargetMaxIndex = 2;
exptparams(1).TrialObject(1).ReferenceIndices = {12, 18, 27, 6, 25, 15, 10, 28, 1, 19, 3, 20, 31, 32, 22, 13, 2, 17, 9, 29, 14, 23, 7, 21, 8, 16, 4, 11, 26, 24, 34, 5, 30, 33};
exptparams(1).TrialObject(1).TargetIndices = {1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1};
exptparams(1).TrialObject(1).CatchIndices = {[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []};
exptparams(1).TrialObject(1).SingleRefDuration = [1.2 2.4 1.6 2.8 2 1.2 2 2 1.6 1.2 1.2 2.4 2 2 2 2 1.6 2 2 1.6 1.2 1.6 2 1.6 1.6 1.6 2 1.6 2 2 2.4 1.2 1.2 2.4];
exptparams(1).TrialObject(1).ShamPercentage = 0;
exptparams(1).TrialObject(1).NumOfEvPerStim = 3;
exptparams(1).TrialObject(1).NumOfEvPerRef = 3;
exptparams(1).TrialObject(1).NumOfEvPerTar = 3;
exptparams(1).TrialObject(1).RunClass = 'TSP';
exptparams(1).TrialObject(1).UserDefinableFields = {'OveralldB', 'edit', 60, 'RelativeTarRefdB', 'edit', 0, 'ReferenceCountFreq', 'edit', [0 0.4 0.3 0.2 0.1 0], 'SingleRefSegmentLen', 'edit', 0, 'CueTrialCount', 'edit', '5', 'OverlapRefTar', 'popupmenu', 'Yes|No', 'TargetIdxFreq', 'edit', '1', 'TargetChannel', 'edit', '1', 'CatchIdxFreq', 'edit', '0', 'OnsetRampTime', 'edit', 0, 'TargetMatchContour', 'popupmenu', 'Yes|No', 'PostTrialSilence', 'edit', 1, 'SaveData', 'popupmenu', 'Yes|No'};

exptparams(1).BehaveObjectClass = 'RewardTargetLBHB';
exptparams(1).TrialObjectClass = 'MultiRefTar';
exptparams(1).TotalRepetitions = 2;
exptparams(1).StartTime = [2014 10 31 13 11 24.674];
exptparams(1).Water = 3.162;
exptparams(1).comment = 'Experiment: RewardTargetLBHB TrialObject: MultiRefTar Reference Class: SpNoise Target Class: JitterTone';




fprintf('Creating Trial Object %s\n',exptparams.TrialObjectClass);
TrialObject=feval(exptparams.TrialObjectClass);
fields=get(TrialObject,'UserDefinableFields');
for cnt1 = 1:3:length(fields),
    try 
       % exptparams(1).TrialObject = handle of a MultiRefTar object since objects are changing,
        TrialObject = set(TrialObject,fields{cnt1},exptparams.TrialObject.(fields{cnt1}));
    catch
        disp(['property ' fields{cnt1} ' not found, using default']);
    end
end

fprintf('Creating Reference Object %s\n',exptparams.TrialObject.ReferenceClass);
RefObject=feval(exptparams.TrialObject.ReferenceClass);
fields=get(RefObject,'UserDefinableFields');
for cnt1 = 1:3:length(fields),
    try % since objects are changing,
        RefObject = set(RefObject,fields{cnt1},exptparams.TrialObject.ReferenceHandle.(fields{cnt1}));
    catch
        if strcmp(fields{cnt1},'UseBPNoise'),
            % special case, for old data use non-default value
            disp('Setting UseBPNoise=0 for backwards compatability');
            RefObject = set(RefObject,fields{cnt1},0);
        else
            disp(['property ' fields{cnt1} ' not found, using default']);
        end
    end
end
if ~strcmpi(exptparams.TrialObject.TargetClass,'None'),
    fprintf('Creating Target Object %s\n',exptparams.TrialObject.TargetClass);
    TarObject=feval(exptparams.TrialObject.TargetClass);
    fields=get(TarObject,'UserDefinableFields');
    for cnt1 = 1:3:length(fields),
        try % since objects are changing,
            TarObject = set(TarObject,fields{cnt1},exptparams.TrialObject.TargetHandle.(fields{cnt1}));
        catch
            if strcmp(fields{cnt1},'UseBPNoise'),
                % special case, for old data use non-default value
                disp('Setting UseBPNoise=0 for backwards compatability');
                TarObject = set(TarObject,fields{cnt1},0);
            else
                disp(['property ' fields{cnt1} ' not found, using default']);
            end
        end
    end
else
    TarObject=[];
end
TrialObject = set(TrialObject, 'TargetHandle', TarObject);
TrialObject = set(TrialObject, 'ReferenceHandle', RefObject);

NonUserDefFields=setdiff(fieldnames(exptparams.TrialObject),...
   {'ReferenceClass','ReferenceHandle',...
   'TargetClass','TargetHandle',...
   'descriptor','RunClass','UserDefinableFields'});
for ii=1:length(NonUserDefFields),
    if isfield(TrialObject,NonUserDefFields{ii}),
        TrialObject=set(TrialObject,NonUserDefFields{ii},...
                        exptparams.TrialObject.(NonUserDefFields{ii}));
    end
end
exptparams.TrialObject=TrialObject;
exptparams=RandomizeSequence(exptparams.TrialObject,exptparams,[],1,1);

fs=get(exptparams.TrialObject,'SamplingRate');
SNRs=get(exptparams.TrialObject,'RelativeTarRefdB');
to=get(exptparams.TrialObject,'TargetHandle');
Frequencies=get(to,'Frequencies');
NumberOfTrials=get(exptparams.TrialObject,'NumberOfTrials');

outpath='C:\Data\stim\';
TargetTimes=ones(NumberOfTrials,1);
FileList=cell(NumberOfTrials,1);
bb=sprintf('TSP_%.0f_%.0fdB_%.0f_%.0fdB',...
   Frequencies(1),SNRs(1),Frequencies(2),SNRs(2));
for ii=1:NumberOfTrials,
   [w,ev]=waveform(exptparams.TrialObject,ii);
   t=evtimes(ev,'*Target');
   TargetTimes(ii)=t(2);
   fprintf('%s %d: Target onset at t=%.2f\n',bb,ii,TargetTimes(ii));
   FileList{ii}=sprintf('%s_%d',bb,ii);
   wavfile=[outpath FileList{ii}];
   w=w./5.001;
   wavwrite(w,fs,24,wavfile);
end

parmfile=[outpath bb '.mat'];
save(parmfile,'FileList','TargetTimes');
