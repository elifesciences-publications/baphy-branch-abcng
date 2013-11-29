function Props = HF_computeShepardProps(RefHandle,StimTags)
% Set parameters
Par = RefHandle.Par; PreSilence = RefHandle.PreStimSilence;

switch RefHandle.RunClass
  case 'SHT'
    O = ShepardTuning; FN = fieldnames(Par);
    for i=1:length(FN) O = set(O,FN{i},Par.(FN{i})); end
    NIndices = get(O,'MaxIndex');
    for iI=1:NIndices
      %M = regexp(StimTags{iI},'=[ ]{1,2}(?<Value>[-0-9]{1,2})','tokens');
      cRandomization = i;
      [w,e,O] = waveform(O,iI,[],'Simulation');
      Props(iI).Pitches = get(O,'LastPitchSequence');
      Props(iI).Randomization = cRandomization;
      Props(iI).ToneDuration = Par.StimDur;
      Props(iI).PrePauseDurs = [inf;repmat(Par.PauseDur,Par.PitchSteps-1,1)];
      for iT=1:Par.PitchSteps
        Props(iI).ToneStarts(iT) = PreSilence + (iT-1)*(Props(iI).ToneDuration + Par.PauseDur);
      end
    end
    
  case 'SHP'
    O = ShepardPair; FN = fieldnames(Par);
    for i=1:length(FN) O = set(O,FN{i},Par.(FN{i})); end
    NIndices = get(O,'MaxIndex');
    for iI=1:NIndices
      [w,e,O] = waveform(O,iI,[],'Simulation');
      Props(iI).Pitches = get(O,'LastPitchSequence');
      cDurations = Par.PairDurations;
      Props(iI).ToneDuration = Par.PairDurations;
      if length(Par.PairDurations)>1 error('Different Lengths not implemented'); end;
      Props(iI).PrePauseDurs = [inf;Par.BetweenPairPause];
      Props(iI).ToneStarts = PreSilence + [0,Props(iI).ToneDuration + Par.BetweenPairPause];
    end
    
  case 'BST';
    O = BiasedShepardTuning; FN = fieldnames(Par);
    for i=1:length(FN) O = set(O,FN{i},Par.(FN{i})); end; clear i;
    NIndices = get(O,'MaxIndex');
    for iI=1:NIndices
      M = regexp(StimTags{iI},'=[ ]{1,2}(?<Value>[-0-9]{1,2})','tokens');
      cBiasBasePitch = str2num(M{1}{1});
      Props(iI).BiasBasePitch = cBiasBasePitch;
      Props(iI).Randomization = str2num(M{2}{1});
      [w,e,O] = waveform(O,iI,[],'Simulation');
      BiasPitches = mod(get(O,'LastBiasPitches'),12);
      TestPitches = mod(get(O,'LastTestPitches'),12);
      Props(iI).ToneDuration = Par.BiasDur;
      % LEADIN
      Props(iI).Pitches = zeros(1,length(BiasPitches)+length(TestPitches));
      Props(iI).Pitches(1:Par.NBiasLeadIn) = BiasPitches(1:Par.NBiasLeadIn);
      BiasPitches = reshape(BiasPitches(Par.NBiasLeadIn+1:end),Par.PitchSteps,Par.NBiasStim);
      Props(iI).PrePauseDurs = [inf,repmat(Par.BetweenBiasPause,1,Par.NBiasLeadIn-1)];
      SingleDur = Par.BiasDur + Par.BetweenBiasPause;
      Props(iI).ToneStarts = PreSilence + [0:SingleDur:SingleDur*(Par.PitchSteps-1)];
      Props(iI).Kind(1:Par.NBiasLeadIn) = 0; % LeadInd
      % BIASING/TEST SEQUENCE
      k = Par.NBiasLeadIn;
      for i=1:Par.PitchSteps
        % BIAS
        cInd = k+1:k+Par.NBiasStim;
        Props(iI).Pitches(cInd) = BiasPitches(i,:);
        Props(iI).PrePauseDurs(cInd) = repmat(Par.BetweenBiasPause,Par.NBiasStim,1);
        Props(iI).ToneStarts(cInd) = Props(iI).ToneStarts(cInd(1)-1) + SingleDur*[1:Par.NBiasStim];
        Props(iI).Kind(cInd) = 1;
        k = k + Par.NBiasStim;
        
        % TEST
        k=k+1;
        Props(iI).Pitches(k) = TestPitches(i);
        Props(iI).PrePauseDurs(k) = Par.AfterBiasPause;
        Props(iI).ToneStarts(k) = Props(iI).ToneStarts(k-1) + Props(iI).ToneDuration + Par.AfterBiasPause ;
        Props(iI).Kind(k) = 2; % Test
      end
    end
    
  case 'BSP';
    O = BiasedShepardPair; FN = fieldnames(Par);
    for i=1:length(FN) try O = set(O,FN{i},Par.(FN{i})); end; end
    NConds = get(O,'MaxIndex');
    PitchClasses = Par.PitchClasses;
    NBiasStim = Par.NBiasStims;
    for iS=1:NConds
      M = regexp(StimTags{iS},'=[ ]{1,2}(?<Value>[-0-9]{1,2})','tokens');
      cPitchClass = str2num(M{1}{1});
      PitchClasses(iS) = cPitchClass;
      iPitchClass = cPitchClass/3+1;
      cBiasDirection = str2num(M{2}{1});
      BiasDirections(iS) = cBiasDirection;
      cBiasVariant = str2num(M{3}{1});
      iBiasVariant = cBiasVariant;
      BiasVariants(iS) = cBiasVariant;
      [w,e,O] = waveform(O,iS,[],'Simulation');
      Shifts = get(O,'LastShifts');
      BiasDirections(iS) = get(O,'LastBiasDirection');
      cNBiasStims = length(Shifts);
      % BIAS
      Pitches =  Shifts + repmat(cPitchClass,cNBiasStims,1);
      % TEST PAIR
      Pitches = [Pitches;cPitchClass;cPitchClass+6];
      % WRAP PITCHES
      Pitches = mod(Pitches,12);
      
      Props(iS).ToneDuration = Par.BiasDurations;
      Props(iS).PrePauseDurs = [inf;repmat(Par.BetweenBiasPause,cNBiasStims-1,1);Par.AfterBiasPause;Par.BetweenPairPause];
      for iB=1:cNBiasStims
        if iB==1 cPrePause = 0; else cPrePause = Props(iS).PrePauseDurs(iB); end
        Props(iS).ToneStarts(iB) = PreSilence + (iB-1)*(Props(iS).ToneDuration + cPrePause);
      end
      Props(iS).ToneStarts(end+1) = Props(iS).ToneStarts(end) + Props(iS).ToneDuration + Par.AfterBiasPause ;
      Props(iS).ToneStarts(end+1) = Props(iS).ToneStarts(end) + Props(iS).ToneDuration + Par.BetweenPairPause ;
      
      Props(iS).Pitches = Pitches;
      Props(iS).PitchClass = cPitchClass;
      Props(iS).BiasDirection = cBiasDirection;
      Props(iS).BiasVariant = cBiasVariant;
      Props(iS).NBiasStims = cNBiasStims;
    end
    
  otherwise error('Stimulus not implemented!');
end




