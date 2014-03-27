function [Props,StimTags] = HF_computeShepardProps(varargin)
% Derive Properties per Tone for the different ShepardTone Stimuli
% Minimally assigns:
% - ToneStarts
% - ToneDurations
% - Pitches
%
% More Properties are assigned based on the RunClass.

P = parsePairs(varargin);
checkField(P,'RefHandle',[]);
checkField(P,'Parameters',[]);
if isempty(P.RefHandle) & isempty(P.Parameters) error('Need to specify eitehr RefHandle or Parameters'); end
if ~isempty(P.RefHandle)
  RunClass = P.RefHandle.RunClass;  
  Par = P.RefHandle.Par; 
  PreSilence = P.RefHandle.PreStimSilence;
  PostSilence = P.RefHandle.PostStimSilence;
elseif ~isempty(P.Parameters)
  RunClass = P.Parameters.RunClass;
  PreSilence = P.Parameters.PreSilence;
  PostSilence = P.Parameters.PostSilence;
  Par = rmfield(P.Parameters,{'PreSilence','RunClass'});
end

% CREATE BASIS OBJECT 
switch RunClass
  case {'BSP','SHS'}; RunClass = 'BSP'; O = BiasedShepardPair; 
  case 'SHT'; O = ShepardTuning;
  case 'SHP'; O = ShepardPair;
  case 'BST'; O = BiasedShepardTuning;
  case 'BSC'; O = BiasedShepardComparison;
end
O = set(O,'PreStimSilence',PreSilence);
O = set(O,'PostStimSilence',PostSilence);
FN = fieldnames(Par);
for i=1:length(FN) try O = set(O,FN{i},Par.(FN{i})); end; end
NIndices = get(O,'MaxIndex'); StimTags = get(O,'Names');
TrialLengths =   get(O,'Duration');

% ASSIGN INDIVIDUAL PROPERTIES
for iI = 1:NIndices
  switch RunClass
    case 'BSP';
      PitchClasses = Par.PitchClasses;
      NBiasStim = Par.NBiasStims;
      M = regexp(StimTags{iI},'=[ ]{1,2}(?<Value>[-0-9]{1,2})','tokens');
      cPitchClass = str2num(M{1}{1});
      PitchClasses(iI) = cPitchClass;
      iPitchClass = cPitchClass/3+1;
      cBiasDirection = str2num(M{2}{1});
      BiasDirections(iI) = cBiasDirection;
      cBiasVariant = str2num(M{3}{1});
      iBiasVariant = cBiasVariant;
      BiasVariants(iI) = cBiasVariant;
      [w,e,O] = waveform(O,iI,[],'Simulation');
      Shifts = get(O,'LastShifts');
      BiasDirections(iI) = get(O,'LastBiasDirection');
      cNBiasStims = length(Shifts);
      % BIAS
      Pitches =  Shifts + repmat(cPitchClass,cNBiasStims,1);
      % TEST PAIR
      Pitches = [Pitches;cPitchClass;cPitchClass+6];
      % WRAP PITCHES
      Pitches = mod(Pitches,12);
      
      Props(iI).ToneDurations = repmat(Par.BiasDurations,cNBiasStims,1);
      if cNBiasStims>0
        Props(iI).PrePauseDurs = [inf;repmat(Par.BetweenBiasPause,cNBiasStims-1,1);Par.AfterBiasPause;Par.BetweenPairPause];
      else
        Props(iI).PrePauseDurs = [inf;Par.BetweenPairPause];       
      end
        
      % ADD BIAS TONES
      for iB=1:cNBiasStims
        if iB==1 cPrePause = 0; else cPrePause = Props(iI).PrePauseDurs(iB); end
        Props(iI).ToneStarts(iB,1) = PreSilence + sum(Props(iI).ToneDurations(1:iB-1)) + (iB-1)*cPrePause;
      end
      % ADD TEST TONES
      Props(iI).ToneDurations(end+1:end+2,1) = Par.PairDurations;
      if cNBiasStims > 0 
      Props(iI).ToneStarts(end+1,1) = Props(iI).ToneStarts(iB,1) + Props(iI).ToneDurations(iB) + Par.AfterBiasPause ;
      else
        Props(iI).ToneStarts(1,1) = Par.AfterBiasPause + PreSilence; iB = 0;
      end
      Props(iI).ToneStarts(end+1,1) = Props(iI).ToneStarts(iB+1,1) + Props(iI).ToneDurations(iB+1) + Par.BetweenPairPause ;
      
      Props(iI).Pitches = Pitches;
      Props(iI).PitchClass = cPitchClass;
      Props(iI).BiasDirection = cBiasDirection;
      Props(iI).BiasVariant = cBiasVariant;
      Props(iI).NBiasStims = cNBiasStims;
      Props(iI).TrialLength = TrialLengths(iI); 
      
    case 'BST';
      M = regexp(StimTags{iI},'=[ ]{1,2}(?<Value>[-0-9]{1,2})','tokens');
      cBiasBasePitch = str2num(M{1}{1});
      Props(iI).BiasBasePitch = cBiasBasePitch;
      Props(iI).BiasPitchRange = Par.BiasPitchRange;
      Props(iI).Randomization = str2num(M{2}{1});
      [w,e,O] = waveform(O,iI,[],'Simulation');
      BiasPitches = mod(get(O,'LastBiasPitches'),12);
      TestPitches = mod(get(O,'LastTestPitches'),12);
      Props(iI).ToneDurations = repmat(Par.BiasDur,[1,length(BiasPitches)+length(TestPitches)]);
      % LEADIN
      Props(iI).Pitches = zeros(1,length(BiasPitches)+length(TestPitches));
      Props(iI).Pitches(1:Par.NBiasLeadIn) = BiasPitches(1:Par.NBiasLeadIn);
      BiasPitches = reshape(BiasPitches(Par.NBiasLeadIn+1:end),Par.NBiasStim,Par.PitchSteps)';
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
        Props(iI).ToneStarts(k) = Props(iI).ToneStarts(k-1) + Props(iI).ToneDurations(k-1) + Par.AfterBiasPause ;
        Props(iI).Kind(k) = 2; % Test
      end
      
    case 'SHT';
      cRandomization = i;
      [w,e,O] = waveform(O,iI,[],'Simulation');
      Props(iI).Pitches = get(O,'LastPitchSequence');
      Props(iI).Randomization = cRandomization;
      Props(iI).ToneDurations = repmat(Par.StimDur,size(Props(iI).Pitches));
      Props(iI).PrePauseDurs = [inf;repmat(Par.PauseDur,Par.PitchSteps-1,1)];
      for iT=1:Par.PitchSteps
        Props(iI).ToneStarts(iT) = PreSilence + sum(Props(iI).ToneDurations(1:iT-1)) + (iT-1)*Par.PauseDur;
      end
      
    case 'SHP';
      [w,e,O] = waveform(O,iI,[],'Simulation');
      Props(iI).Pitches = get(O,'LastPitchSequence');
      cDurations = Par.PairDurations;
      if length(cDurations)>1 error('Different Lengths not implemented'); end;
      Props(iI).ToneDurations = [cDurations,cDurations];
      Props(iI).PrePauseDurs = [inf;Par.BetweenPairPause];
      Props(iI).ToneStarts = PreSilence + [0,Props(iI).ToneDurations(1) + Par.BetweenPairPause];
      
    case 'BSC'; % BIASED SHEPARD COMPARISON
      [w,e,O] = waveform(O,iI,[],'Simulation');
      Props(iI).Pitches =  get(O,'LastPitches');
      Props(iI).ToneStarts = get(O,'LastStarts');
      Props(iI).ToneDurations = get(O,'LastDurations');
      Props(iI).PrePauseDurs = [inf;Props(iI).ToneStarts(2:end) - (Props(iI).ToneStarts(1:end-1)+Props(iI).ToneDurations(1:end-1))];
      Props(iI).TrialLength = TrialLengths(iI);       
      M = regexp(StimTags{iI},'=[ ]{1,2}(?<Value>[-+0-9e\.]{1,20}[ ]{2})','tokens');
      Props(iI).PitchClass = str2num(M{1}{1});
      Props(iI).BiasDirection = str2num(M{2}{1});
      Props(iI).BiasVariant = str2num(M{3}{1});
      Props(iI).NBiasStims = str2num(M{4}{1});
      Props(iI).TestPitchStep = str2num(M{5}{1});
      
    otherwise error('Stimulus not implemented!');
  end
end
  
  

