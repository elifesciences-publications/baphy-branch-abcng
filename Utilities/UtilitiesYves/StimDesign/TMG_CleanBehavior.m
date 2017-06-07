function [Behavior,Bits,LickData] = TMG_CleanBehavior(exptparams,exptevents,FileDateStr,EVPname)
% cd /auto/data/Morbier/morbier081; run('/auto/data/Morbier/morbier081/morbier081d03_a_TMG.m')
% [Behavior,Bits,LickData] = TMG_CleanBehavior(exptparams,exptevents,'081d03','morbier081d03_a_TMG.evp');
    AuxSF = 1000;
    [~,~,rAtot,ATrialIdxtot] = evpread(EVPname,'auxchans',1);
    ATrialIdxtot = [ATrialIdxtot ; length(rAtot)];

    fprintf(['=> ' num2str(length(exptparams(1).Performance)) ' t.\n']);
    o = ReconstructSoundObject(exptparams);
    Par = get(o,'Par'); DifficultyLvl = Par.DifficultyLvl_D1; DiffiNb = Par.DifficultyLvlNb;
    MinToC = Par.MinToC; MaxToC = Par.MaxToC; TarWin = Par.StimulusBisDuration;
    DifficultyLvlByInd = get(o,'DifficultyLvlByInd'); MaxIndex = get(o,'MaxIndex');
    MorphingTypeByInd = get(o,'MorphingTypeByInd'); MorphingNb = max(MorphingTypeByInd);
    BinToC = str2num( get(o,'BinToC') );
    D1param = str2num(get(o,'D1param'));
    SilenceBeforeDur = exptparams.TrialObject.ReferenceHandle.Duration+exptparams.TrialObject.TargetHandle.PreStimSilence;
    MinimalDelayResponse = exptparams.BehaveObject.MinimalDelayResponse;
    ResponseWindow = exptparams.BehaveObject.ResponseWindow;
    ConsecutiveSnoozeNb = 0;
    [SnoozeBits,EarlyBits,HitBits,IndicesLst,IntegrationTimes,LickTimes,OutcomeArray,ToCLst,RefSliceNbLst] =...
        TMG_DissectBehaOutcomes(exptparams,ConsecutiveSnoozeNb);
    TrialNb = exptevents(end).Trial;
    OutcomeLst = zeros(1,TrialNb);
    DiffLst = Par.DifficultyLvl_D1( DifficultyLvlByInd(IndicesLst) );
    FreqPosLst = Par.D1param( MorphingTypeByInd(IndicesLst) );
    RefSliceDuration = min(IntegrationTimes-ToCLst);
    AltLickTimes = LickTimes;
    LongAltLickTimes = AltLickTimes; AltLickTimes = AltLickTimes-RefSliceNbLst*RefSliceDuration;
    LTInd = find(~cellfun(@isempty,cellfun(@strfind,{exptevents.Note},repmat({'LICK,Touch'},1,length(exptevents)),'UniformOutput',0)));
    LickTimes = nan*ones(1,TrialNb);
    LickTimes([exptevents(LTInd).Trial]) = [exptevents(LTInd).StartTime]-SilenceBeforeDur;
    LongLickTimes = LickTimes; LickTimes = LickTimes-RefSliceNbLst*RefSliceDuration;
    
    LongIntegrationTimes = IntegrationTimes;
    IntegrationTimes = IntegrationTimes-RefSliceNbLst*RefSliceDuration;
    AfterResponseDuration = exptparams.BehaveObject.AfterResponseDuration;
    
    % LICK DURING FIRST REF SLICES
    LickEvInd = find(~cellfun(@isempty,cellfun(@strfind,{exptevents.Note},repmat({'LICK,Touch'},1,length(exptevents)),'UniformOutput',0)));
    TrialEv = [exptevents(LickEvInd).Trial];
    for tn = 1:length(RefSliceNbLst)
        RefSlice_LickTime{tn} = [];
        for RefSliceNum = 1:(RefSliceNbLst(tn)-1)
            RefSliceTimes = SilenceBeforeDur + (RefSliceNum-1)*RefSliceDuration +[0 RefSliceDuration];
            LickEv = LickEvInd(TrialEv==tn);
            LickInWinInd = find( [exptevents(LickEv).StartTime]>=RefSliceTimes(1) & [exptevents(LickEv).StartTime]<=RefSliceTimes(2) ,1,'first');
            if ~isempty(LickInWinInd)
                RefSlice_LickTime{tn}(RefSliceNum) = exptevents(LickEv(LickInWinInd)).StartTime;
            else
                LickOn = find( rAtot(ATrialIdxtot(tn):(ATrialIdxtot(tn+1)-1)) )/AuxSF;
                LickOnInd = find( LickOn <= RefSliceTimes(2) &...
                    LickOn >= RefSliceTimes(1), 1 , 'first');
                if ~isempty(LickOnInd)
                    RefSlice_LickTime{tn}(RefSliceNum) = LickOn( LickOnInd );
                else
                    RefSlice_LickTime{tn}(RefSliceNum) = nan;
                end
            end
        end
    end
    
    % CATCH
%     if any(DifficultyLvl==0)
        CatchIndices = find( ismember(DifficultyLvlByInd,find(DifficultyLvl==0)) );
        % Catch trials
        CatchBit = ismember(IndicesLst,CatchIndices);
        CatchSnoozeBits = SnoozeBits&CatchBit; CatchEarlyBits = EarlyBits&CatchBit; CatchHitBits = HitBits&CatchBit;
%         CatchIndicesLst = IndicesLst(CatchBit); CatchIntegrationTimes = IntegrationTimes(CatchBit); CatchLickTimes = LickTimes(CatchBit); CatchToCLst = ToCLst(CatchBit);
%         CatchRefSliceNbLst = RefSliceNbLst(CatchBit); CatchLongIntegrationTimes = LongIntegrationTimes(CatchBit); CatchLongLickTimes = LongLickTimes(CatchBit);
        % NonCatch trials
        NonCatchBit = ~CatchBit;
        SnoozeBits = SnoozeBits&NonCatchBit; EarlyBits = EarlyBits&NonCatchBit; HitBits = HitBits&NonCatchBit;
%         IndicesLst = IndicesLst(NonCatchBit); IntegrationTimes = IntegrationTimes(NonCatchBit); LickTimes = LickTimes(NonCatchBit); ToCLst = ToCLst(NonCatchBit);
%         RefSliceNbLst = RefSliceNbLst(NonCatchBit);  LongIntegrationTimes = LongIntegrationTimes(NonCatchBit); LongLickTimes = LongLickTimes(NonCatchBit);
%     end    
    
%     % CHANGE TIMES from EVENTS
%     % because Catch 'CT' are incorrect in the IntegrationTimes
%     ChangeNoteInd = find(~cellfun(@isempty,cellfun(@strfind,{exptevents.Note},repmat({'Change'},1,length(exptevents)),'UniformOutput',0)));
%     for ind = 1:length(ChangeNoteInd)
%         Note = exptevents(ChangeNoteInd(ind)).Note;
%         CTlst(ind) = str2num(Note(end-15:end-11));
%     end
    % SOUND OFFSETS from EVENTS
    OffsetNoteInd = find(~cellfun(@isempty,cellfun(@strfind,{exptevents.Note},repmat({'STIM,OFF'},1,length(exptevents)),'UniformOutput',0)));
    SoundOffsetsT = [exptevents(OffsetNoteInd).StartTime];
    SoundOffsetsTrials = [exptevents(OffsetNoteInd).Trial];
    SoundOffsetsTimes = zeros(1,TrialNb); SoundOffsetsTimes(SoundOffsetsTrials) = SoundOffsetsT;
    % TRIAL STOPS from EVENTS
    TrialStopNoteInd = find(~cellfun(@isempty,cellfun(@strfind,{exptevents.Note},repmat({'TRIALSTOP'},1,length(exptevents)),'UniformOutput',0)));
    TrialStopTimes = [exptevents(TrialStopNoteInd).StartTime];
    
    NotUsableTrials = TrialNb;
    %% HIT-CHANGE
    % 1) FIND LICK TIMES IF THEY ARE OUT OF THE RESP.WIN.
    HITIND = find(HitBits);
    OutcomeLst(HitBits) = 2;
    IND = find( (LickTimes(HitBits)-ToCLst(HitBits)) < MinimalDelayResponse  |...
        (LickTimes(HitBits)-ToCLst(HitBits)) > ResponseWindow | isnan(LickTimes(HitBits)) );
    % Backup with first licks
    AltIND = find( (AltLickTimes(HitBits)-ToCLst(HitBits)) < MinimalDelayResponse  |...
        (AltLickTimes(HitBits)-ToCLst(HitBits)) > ResponseWindow | isnan(AltLickTimes(HitBits)) );
    DiffIND = setdiff(IND,AltIND);
    disp([num2str(length(DiffIND)) ' Hit taken from exptparams']);
    LongLickTimes(HITIND(DiffIND)) = LongAltLickTimes(HITIND(DiffIND));
    LickTimes(HITIND(DiffIND)) = LongAltLickTimes(HITIND(DiffIND))-RefSliceNbLst(HITIND(DiffIND))*RefSliceDuration;
    IND = intersect(IND,AltIND);
    % Backup with sound offsets
    AltIND_t = find( SoundOffsetsTimes~=0 );    
    DiffIND = setdiff(IND,AltIND_t);
    disp([num2str(length(DiffIND)) ' Hit taken from sound offset events']);
    LongLickTimes(HITIND(DiffIND)) = LongAltLickTimes(HITIND(DiffIND));
    LickTimes(HITIND(DiffIND)) = LongAltLickTimes(HITIND(DiffIND))-RefSliceNbLst(HITIND(DiffIND))*RefSliceDuration;
    IND = intersect(IND,AltIND_t);
    
    IND = HITIND(IND);
    if ~isempty(IND)
        [~,~,rA,ATrialIdx] = evpread(EVPname,'auxchans',1,'trials',IND);
        ATrialIdx = [ATrialIdx ; length(rA)];
        for C = 1:length(IND)
            LickOn = find( rA(ATrialIdx(C):(ATrialIdx(C+1)-1)) )/AuxSF - SilenceBeforeDur;
            LickOnInd = find( LickOn > (LongIntegrationTimes(IND(C))+MinimalDelayResponse) & ...
                LickOn < (LongIntegrationTimes(IND(C))+ResponseWindow) ,1,'first' );
            if ~isempty(LickOnInd)
                LongLickTimes(IND(C)) = LickOn( LickOnInd );
                LickTimes(IND(C)) = LongLickTimes(IND(C))-RefSliceNbLst(IND(C))*RefSliceDuration;
            else
                NotUsableTrials(length(NotUsableTrials)+1) = IND(C);
                disp('HIT: No Lick in this trial');
            end
        end
    end
    if length(SoundOffsetsTrials)<TrialNb % First sessions missed events
        SoundOffsetsTimes(HitBits) = LongLickTimes(HitBits)+SilenceBeforeDur;
    end
    % 2) CLEAN ANALOG CHANNELS
    % Check for artefacts
    Dur = 1.1*AuxSF; l = [];
    for tN = HITIND
        ind = ATrialIdxtot(tN:(tN+1));
        InTrial_Change = ind(1)+round(  (SilenceBeforeDur+RefSliceNbLst(tN)*RefSliceDuration+IntegrationTimes(tN)) * AuxSF);
        l = [l ; find(rAtot(InTrial_Change+(0:Dur)))];
    end
    Penetration = num2str(FileDateStr(1:3)); Depth = num2str(FileDateStr(4));
    if Penetration>=39%1%num2str(FileDateStr(1:3))<=40%(length(find(l>=935 & l<=970))/length(l)) > 0.03 % (length(find(l>=925 & l<=975))/length(l)) > 0.035
        RemoveArt = 1;
        disp('--> extra licks @ 9.7s removed')
    else
        RemoveArt = 0;
    end
	for tN = setdiff(HITIND,NotUsableTrials)
        ind = ATrialIdxtot(tN:(tN+1));
        TrialData = rAtot(ind(1):(ind(2)-1));
        InTrial_BeforeChange = round([ (SilenceBeforeDur+RefSliceNbLst(tN)*RefSliceDuration) ,...
            (SilenceBeforeDur+LongLickTimes(tN)) ]* AuxSF);
        TrialData(InTrial_BeforeChange(1):InTrial_BeforeChange(2)) = 0;
        if RemoveArt
            TrialData(round((SilenceBeforeDur+LongIntegrationTimes(tN))* AuxSF)+(937:974)) = 0;
        end
        rAtot(ind(1):(ind(2)-1)) = TrialData;
    end
    
    %% HIT-NO CHANGE = CORRECT REJECTION
    % For Catch, IntegrationTime = SoundDuration = 4.11+0.85 (excepted some longer sessions like <morbier046a02_a_TMG>)
    HITIND = find(CatchHitBits);
    OutcomeLst(CatchHitBits) = 4;
    IND = find( ~isnan(LongLickTimes(CatchHitBits)) );
    IND = HITIND(IND);
    if ~isempty(IND)
        LongLickTimes(CatchHitBits) = nan; LickTimes(CatchHitBits) = nan; % Fake lick added during experiment
    end
    if length(SoundOffsetsTrials)<TrialNb % First sessions missed events
        SoundOffsetsTimes(CatchHitBits) = SilenceBeforeDur+RefSliceNbLst(CatchHitBits)*RefSliceDuration+IntegrationTimes(CatchHitBits);
    end
    % 2) CLEAN ANALOG CHANNELS
	for tN = HITIND
        ind = ATrialIdxtot(tN:(tN+1));
        TrialData = rAtot(ind(1):(ind(2)-1));
        InTrial_BeforeChange = round([ (SilenceBeforeDur+RefSliceNbLst(tN)*RefSliceDuration) ,...
            (SilenceBeforeDur+RefSliceNbLst(tN)*RefSliceDuration+IntegrationTimes(tN)) ]* AuxSF);
        TrialData(InTrial_BeforeChange(1):InTrial_BeforeChange(2)) = 0;
        rAtot(ind(1):(ind(2)-1)) = TrialData;
    end
    
    %% MISS    
    % 1) THERE SHOULD BE NO LICK TIMES
    MISSIND = find(SnoozeBits);
    OutcomeLst(SnoozeBits) = 3;
    IND = find( ~isnan(LongLickTimes(SnoozeBits)) );
    IND = MISSIND(IND);
    if ~isempty(IND) % Lick detected in events in the RefSlices
%         disp('MISS: !CARAMBA! should be NaN');
        LongLickTimes(SnoozeBits) = nan; LickTimes(SnoozeBits) = nan;
    end
    % 2) CLEAN ANALOG CHANNELS
	for tN = MISSIND
        ind = ATrialIdxtot(tN:(tN+1));
        TrialData = rAtot(ind(1):(ind(2)-1));
        InTrial_BeforeChange = round([ (SilenceBeforeDur+RefSliceNbLst(tN)*RefSliceDuration) ,...
            (SilenceBeforeDur+LongIntegrationTimes(tN)+ResponseWindow) ]* AuxSF);
        TrialData(InTrial_BeforeChange(1):InTrial_BeforeChange(2)) = 0;
        rAtot(ind(1):(ind(2)-1)) = TrialData;
    end

    %% EARLY
    % 1) CHECK THERE ARE LICK TIMES BEFORE THE RESP.WIN.
    EARLYIND = find(EarlyBits);
    OutcomeLst(EarlyBits) = 1;
    IND = find( (LickTimes(EarlyBits)-ToCLst(EarlyBits)) >= MinimalDelayResponse  |...
        isnan(LickTimes(EarlyBits)) );
    % Backup with first licks
    AltIND = find( (AltLickTimes(EarlyBits)-ToCLst(EarlyBits)) >= MinimalDelayResponse  |...
        isnan(AltLickTimes(EarlyBits)) );
    DiffIND = setdiff(IND,AltIND);
    LongLickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND));
    LickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND))-RefSliceNbLst(EARLYIND(DiffIND))*RefSliceDuration;
    IND = intersect(IND,AltIND);
    % Backup with sound offsets
    AltIND_t = find( SoundOffsetsTimes~=0 );    
    DiffIND = setdiff(IND,AltIND_t);
    LongLickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND));
    LickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND))-RefSliceNbLst(EARLYIND(DiffIND))*RefSliceDuration;
    IND = intersect(IND,AltIND_t);
    
    IND = EARLYIND(IND);
    if ~isempty(IND)
        [~,~,rA,ATrialIdx] = evpread(EVPname,...
            'auxchans',1,'trials',IND);
        ATrialIdx = [ATrialIdx ; length(rA)];
        for C = 1:length(IND)
            LickOn = find( rA(ATrialIdx(C):(ATrialIdx(C+1)-1)) )/AuxSF - SilenceBeforeDur;
            LickOnInd = find( LickOn <= (LongIntegrationTimes(IND(C))+MinimalDelayResponse) &...
                LickOn >= (RefSliceNbLst(IND(C))*RefSliceDuration), 1 , 'first');
            if ~isempty(LickOnInd)
                LongLickTimes(IND(C)) = LickOn( LickOnInd );
                LickTimes(IND(C)) = LongLickTimes(IND(C))-RefSliceNbLst(IND(C))*RefSliceDuration;
            else
                NotUsableTrials(length(NotUsableTrials)+1) = IND(C);
                disp('EARLY: Trial not used');
            end
        end
    end
    % 2) CLEAN ANALOG CHANNELS
	for tN = setdiff(EARLYIND,NotUsableTrials)
        ind = ATrialIdxtot(tN:(tN+1));
        TrialData = rAtot(ind(1):(ind(2)-1));
        InTrial_BeforeChange = round([ (SilenceBeforeDur+RefSliceNbLst(tN)*RefSliceDuration) ,...
            (SilenceBeforeDur+LongLickTimes(tN)) ]* AuxSF);
        TrialData(InTrial_BeforeChange(1):InTrial_BeforeChange(2)) = 0;
        rAtot(ind(1):(ind(2)-1)) = TrialData;
    end
    
    %% EARLY-NO CHANGE
    EARLYIND = find(CatchEarlyBits);
    OutcomeLst(CatchEarlyBits) = 1;
    IND = find( LickTimes(CatchEarlyBits) >= IntegrationTimes(CatchEarlyBits)  |...
        isnan(LickTimes(CatchEarlyBits)) );
    % Backup with first licks
    AltIND = find( AltLickTimes(CatchEarlyBits) >= IntegrationTimes(CatchEarlyBits)  |...
        isnan(AltLickTimes(CatchEarlyBits)) );
    DiffIND = setdiff(IND,AltIND);
    LongLickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND));
    LickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND))-RefSliceNbLst(EARLYIND(DiffIND))*RefSliceDuration;
    IND = intersect(IND,AltIND);
    % Backup with sound offsets
    AltIND_t = find( SoundOffsetsTimes~=0 );
    DiffIND = setdiff(IND,AltIND_t);
    LongLickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND));
    LickTimes(EARLYIND(DiffIND)) = LongAltLickTimes(EARLYIND(DiffIND))-RefSliceNbLst(EARLYIND(DiffIND))*RefSliceDuration;
    IND = intersect(IND,AltIND_t);
    
    IND = EARLYIND(IND);
    if ~isempty(IND)
        [~,~,rA,ATrialIdx] = evpread(EVPname,...
            'auxchans',1,'trials',IND);
        ATrialIdx = [ATrialIdx ; length(rA)];
        for C = 1:length(IND)
            LickOn = find( rA(ATrialIdx(C):(ATrialIdx(C+1)-1)) )/AuxSF - SilenceBeforeDur;
            LickOnInd = find( LickOn >= (RefSliceNbLst(IND(C))*RefSliceDuration) &...
                LickOn <= (RefSliceNbLst(IND(C))*RefSliceDuration+IntegrationTimes(IND(C))), 1 , 'first');
            if ~isempty(LickOnInd)
                LongLickTimes(IND(C)) = LickOn( LickOnInd );
                LickTimes(IND(C)) = LongLickTimes(IND(C))-RefSliceNbLst(IND(C))*RefSliceDuration;
            else
                NotUsableTrials(length(NotUsableTrials)+1) = IND(C);
                disp('EARLY CATCH: Trial not used');
            end
        end
    end
    % 2) CLEAN ANALOG CHANNELS
	for tN = setdiff(EARLYIND,NotUsableTrials)
        ind = ATrialIdxtot(tN:(tN+1));
        TrialData = rAtot(ind(1):(ind(2)-1));
        InTrial_BeforeChange = round([ (SilenceBeforeDur+RefSliceNbLst(tN)*RefSliceDuration) ,...
            (SilenceBeforeDur+LongLickTimes(tN)) ]* AuxSF);
        TrialData(InTrial_BeforeChange(1):InTrial_BeforeChange(2)) = 0;
        rAtot(ind(1):(ind(2)-1)) = TrialData;
    end
    
    LongLickTimes = LongLickTimes+SilenceBeforeDur;
    LongIntegrationTimes = LongIntegrationTimes+SilenceBeforeDur;
    
    %% STRUCTURE
    Penetration = str2num(FileDateStr(1:3)); Depth = FileDateStr(4);
    % BEHAVIOR
    Behavior.Name = FileDateStr;
    Behavior.Recording = str2num(FileDateStr(5:6));
    Behavior.Penetration = Penetration;
    Behavior.Depth = Depth;
    Behavior.RefSliceDuration = RefSliceDuration;
    Behavior.MinDelay = MinimalDelayResponse;
    Behavior.ResponseWindow = ResponseWindow;
    Behavior.Trial = 1:TrialNb;
    Behavior.Outcome = OutcomeLst;
    Behavior.ChangeSize = DiffLst;
    Behavior.PreStimSilence = SilenceBeforeDur;
    Behavior.ChangeFreq = FreqPosLst;
    Behavior.LickTime = LongLickTimes;
    Behavior.ShortLickTime = LongLickTimes-SilenceBeforeDur-RefSliceNbLst*RefSliceDuration;
    Behavior.SoundOffsetTime = SoundOffsetsTimes;
    Behavior.ChangeTime = LongIntegrationTimes;
%     Behavior.ChangeTime(CatchBit|CatchEarlyBits) = nan;
    Behavior.ShortChangeTime = IntegrationTimes;
%     Behavior.ShortChangeTime(CatchBit|CatchEarlyBits) = nan;
    Behavior.TrialStopTime = TrialStopTimes;
    Behavior.RefSlice_LickTime = RefSlice_LickTime;
    Behavior.RefSliceNb = RefSliceNbLst;
    Behavior.TrashTrial = zeros(1,TrialNb); Behavior.TrashTrial(NotUsableTrials) = 1;
    % BOOLEAN
    Bits.HitBits = HitBits;
    Bits.EarlyBits = EarlyBits;
    Bits.SnoozeBits = SnoozeBits;
    Bits.CatchHitBits = CatchHitBits;
    Bits.CatchEarlyBits = CatchEarlyBits;
    % LICK DATA
    LickData.rA = rAtot;
    LickData.ATrialIdx = ATrialIdxtot;