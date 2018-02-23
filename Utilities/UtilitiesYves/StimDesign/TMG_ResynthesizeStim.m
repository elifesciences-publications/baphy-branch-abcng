function [Stimuli,ChangeTime,options,Behavior] = TMG_ResynthesizeStim(mFile,varargin)

% Output arguments
%- Stimuli

P = parsePairs(varargin);
checkField(P,'RootAdress','/auto/data/');
checkField(P,'TrialLst',[]);
checkField(P,'CutWaveform',1);

IndPenetration = min([find(mFile=='0',1,'first') find(mFile=='1',1,'first')]);
Animal = mFile(1:(IndPenetration-2));
Penetration = mFile(IndPenetration+(0:2));
FileDateStr = mFile(IndPenetration+(0:5));

% Parameters
options = [];
SoundSF = 100000;
ChordDuration = 0.03;   % in s
ToneMatrixSR = 1/ChordDuration;  % in Hz

% % Load m-file
% load([ P.RootAdress filesep upper(Animal(1)) Animal(2:end) filesep Animal Penetration filesep mFile(1:end-2) '.mat' ]);

% Load m-file
% cd([P.RootAdress filesep upper(Animal(1)) Animal(2:end) filesep Animal Penetration]);
% if ~exist('tmp','dir')
run([P.RootAdress mFile]);
% run([P.RootAdress mFile]);
%    eval([mFile(1:end-2) ';'])
% else
%      load([mFile '.mat']);
% end

% Load trial information
T = Events2Trials('Events',exptevents,'Stimclass','TMG','Runclass','TMG');
if isempty(P.TrialLst); P.TrialLst = 1:T.NTrials; end

% Reconstruct SO
TH = ReconstructSoundObject(exptparams);
Par = get(TH,'Par');
ChordDuration = Par.ToneDuration;
THcatch = TH;
PreStimSilence = get(THcatch,'PreStimSilence');
MaxIndex = get(TH,'MaxIndex');
THcatch = set(THcatch,'StimulusBisDuration',ChordDuration);
THcatch = ObjUpdate(THcatch);
TotalPreStimSilence = exptparams.TrialObject.ReferenceHandle.PreStimSilence+exptparams.TrialObject.ReferenceHandle.Duration+exptparams.TrialObject.ReferenceHandle.PostStimSilence+get(TH,'PreStimSilence');

[ w , ev , TH , D0 , ChangeD , Parameters] = waveform(TH,1,[],[],1);
fToneNb = size(Parameters.ToneMatrix{1},1);

StimulusBisDuration = str2num(get(TH,'StimulusBisDuration'));

if ~strcmpi(exptparams(1).BehaveObjectClass,'Passive')
    RefSliceDuration = exptparams.BehaveObject.RefSliceDuration;
    RespWinDur = exptparams.BehaveObject.ResponseWindow;
    RefSliceDuration = round(RefSliceDuration/ChordDuration)*ChordDuration;            % sec.
    SliceDuration = RefSliceDuration;
    THcatch = set(THcatch,'MinToC',RefSliceDuration+2*ChordDuration); THcatch = set(THcatch,'MaxToC',RefSliceDuration+2*ChordDuration);
    THcatch = ObjUpdate(THcatch);
    EVPname = [P.RootAdress mFile '.evp'];
    [Behavior] = TMG_CleanBehavior(exptparams,exptevents,FileDateStr,EVPname);
else
    Behavior = [];
end
%%
for TrialNum = P.TrialLst
    ToneMatrixTot = [];
    num = find(TrialNum==P.TrialLst);
    Index =  cell2mat(T.Index(TrialNum));
    switch exptparams(1).BehaveObjectClass
        case {'RewardTargetCont';'Passive'}
            [ w , ev , TH , D0 , ChangeD , Parameters] = waveform(TH,Index,[],[],TrialNum);
            ToneMatrixTot = Parameters.ToneMatrix{1};
        case 'RewardTargetContinuous'
            RefSliceCounter = exptparams(1).Performance(TrialNum).RefSliceCounter;
            IndexRefSlice = exptparams(1).Performance(TrialNum).IndexRefSlice;
            wTot = [ ];
            % This has been checked in TMG_RegenerateTMG.m
            for RefNum = 1:RefSliceCounter
                [w,~,~,~,~,Parameters] = waveform(THcatch,IndexRefSlice(RefNum),[],[],TrialNum);
                TMtemp = Parameters.ToneMatrix{1}(:,1:round((SliceDuration+2*ChordDuration)/ChordDuration));
                w = w(1:round((SliceDuration+2*ChordDuration+PreStimSilence)*SoundSF));
                stim = w;
                if RefNum == 1
                    NormFactor = maxLocalStd(stim(round(PreStimSilence*SoundSF)+(1:round(SliceDuration*SoundSF))),SoundSF,floor(round(SliceDuration*SoundSF)/SoundSF));
                end
                stim = stim/NormFactor;
                y = stim(round(PreStimSilence*SoundSF)+(1:round(SliceDuration*SoundSF)));
                wTot = [wTot y'];
                ToneMatrixTot = [ToneMatrixTot TMtemp(:,1:round(SliceDuration/ChordDuration))];
            end
            [ ActualTrialSound , ev , TH , D0 , ChangeD , Parameters] = waveform(TH,Index,[],[],TrialNum);
            TargetSliceToC = Parameters.ToC;
            TarSliceDuration = TargetSliceToC+RespWinDur;
            TMtemp = Parameters.ToneMatrix{1};
            ToneMatrixTot = [ToneMatrixTot TMtemp(:,1:round(TargetSliceToC/ChordDuration))];
            Parameters.ToC = Parameters.ToC+SliceDuration*RefSliceCounter;
            stim = ActualTrialSound;
            stim = stim/NormFactor;
            y = stim(round(PreStimSilence*SoundSF)+(1:round(TarSliceDuration*SoundSF)));
            wTot = [wTot y']; w = wTot;
            
%             StopSoundT_ind = find( (cellfun(@strcmp,{exptevents.Note},repmat({'STIM,OFF'},size({exptevents.Note})))) & ([exptevents.Trial] == TrialNum) );
%             if ~isempty(StopSoundT_ind)
%                 StopSoundT = exptevents(StopSoundT_ind).StartTime;
%             else   % problem of Hit events absent in Hit trials in a large batch of sessions (fixed now)
%                 StopSoundT = exptparams.Performance(TrialNum).LickTime;
%             end
            if P.CutWaveform
                StopSoundT = Behavior.SoundOffsetTime(TrialNum);
                StopSoundT = min( (StopSoundT-TotalPreStimSilence+...
                    get(TH,'PreStimSilence')), length(w)/SoundSF);
                w = w(1:floor(StopSoundT*SoundSF));
            end
            %                 exptparams(1).Performance(1).RefSliceCounter = 2;
            %                 exptparams(1).Performance(1).IndexRefSlice = [86 22];
            %
            %                 [ w , ev , o , D0 , ChangeD , Parameters] = waveform(o,Index,[],[],TrialNum);
    end
    FreqRanges = FindFreq(exptparams);
    D0information{num} = Parameters.D0information;
    ToC = Parameters.ToC;

    TrialMaxDuration = ToC;
    IndTrialDur(num) = ToC;

    Stimuli.PreChangeToneMatrix{num} = ToneMatrixTot;
    Stimuli.PostChangeToneMatrix{num} = Parameters.ToneMatrix{2};
    Stimuli.SoundStatistics = D0information;
    Stimuli.FreqRanges = FreqRanges;
    Behavior.SoundStatistics(TrialNum,:) = Parameters.D0information;
    Stimuli.waveform{num} = w( round(get(TH,'PreStimSilence')*SoundSF+1) : end ); %round((get(o,'PreStimSilence')+ToC)*SoundSF) );
    ChangeTime(num) = ToC;
end


options.sF = ToneMatrixSR;
FrequencySpace = get(TH,'FrequencySpace');
options.F = FrequencySpace;

function Ranges = FindFreq(exptparams)

BinNb = exptparams.TrialObject.TargetHandle.Par.DistriBinNb/2;
F0 = exptparams.TrialObject.TargetHandle.Par.F0;
HalfCutOct = exptparams.TrialObject.TargetHandle.Par.OctaveNb/2;
Fbins = F0-HalfCutOct;
for BinNum = 1:BinNb
    Fbins = [Fbins  F0-(HalfCutOct-BinNum*HalfCutOct/(BinNb/2))];
end
Fbins = 2.^Fbins;
Ranges{1} = [find(exptparams.TrialObject.TargetHandle.FrequencySpace<Fbins(1),1,'last')...
    find(exptparams.TrialObject.TargetHandle.FrequencySpace<Fbins(2),1,'last')];
for rn = 2:BinNb    
    Ranges{rn} = [Ranges{end}(2)+1 ...
        find(exptparams.TrialObject.TargetHandle.FrequencySpace<Fbins(rn+1),1,'last')];
end
Ranges{end}(end) = find(exptparams.TrialObject.TargetHandle.FrequencySpace>Fbins(end),1,'first');

