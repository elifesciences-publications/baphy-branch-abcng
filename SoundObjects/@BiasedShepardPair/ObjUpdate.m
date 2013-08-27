function O = ObjUpdate(O);
% Update the changes of a MultiStream object
%
% benglitz 2010

FieldNames = get(O,'FieldNames');
FieldTypes = get(O,'FieldTypes');
for i=1:length(FieldNames) 
  switch FieldTypes{i}
    case 'edit';    
      tmp = get(O,FieldNames{i});
      if ~isnumeric(tmp) tmp = eval(['[',tmp,']']); end
      Par.(FieldNames{i}) = tmp;
    case 'popupmenu';  Par.(FieldNames{i}) = get(O,FieldNames{i}); 
    otherwise error('FieldType not implemented!');
  end
end

Par.PitchClasses = sort(Par.PitchClasses);
Par.BiasDirections = sort(Par.BiasDirections);
Par.NBiasStims = Par.NBiasStims; % not sorted to allow 10 to be the first range
MaxIndexOld = length(Par.PitchClasses)*length(Par.BiasDirections)*Par.NBiases;
MaxIndex = length(Par.NBiasStims)*MaxIndexOld;
O = set(O,'MaxIndex',MaxIndex);
O = set(O,'Par',Par);

% SET NAMES
NPitchClasses = length(Par.PitchClasses);
Par.Biases = [1:Par.NBiases];
Durations = zeros(MaxIndex,1);
Names = cell(MaxIndex,1);
PreStimSilence = get(O,'PreStimSilence');
PostStimSilence = get(O,'PostStimSilence');

for Index=1:MaxIndex
  % GET PARAMETERS OF CURRENT Index
  % LENGTH OF BIAS (1:16 vs. 17:32)
  iNBiasStim = ceil(Index/MaxIndexOld);
  IndexOld = Index - (iNBiasStim-1)*MaxIndexOld;
  %  iPitchClass = ceil(IndexOld/NPitchClasses); % OLD
  cDivider = (Par.NBiases * length(Par.BiasDirections));
  iPitchClass = ceil(IndexOld/cDivider);
  Rem = mod(IndexOld,cDivider);
  if Rem==0 Rem=MaxIndexOld/NPitchClasses; end
  
  % cBias is not used in the following, but via the Index, a different random sequence is drawn
  cDivider = length(Par.BiasDirections);
  iBias = ceil(Rem/cDivider);
  Rem = mod(Rem,cDivider);
  if Rem==0 Rem=MaxIndexOld/(NPitchClasses*Par.NBiases); end
  
  iBiasDirection = Rem;
  
  cNBiasStim = Par.NBiasStims(iNBiasStim);
  NBiasStimByIndex(Index) = cNBiasStim;
  cPitchClass = Par.PitchClasses(iPitchClass);
  PitchClassByIndex(Index) = cPitchClass;
  % cBias is not used in the following, but via the Index, a different random sequence is drawn
  cBias = Par.Biases(iBias);
  BiasByIndex(Index) = cBias;
  cBiasDirection = Par.BiasDirections(iBiasDirection);
  BiasDirectionByIndex(Index) = cBiasDirection;
  
  % COMPUTE STIMULUS LENGTHS FOR DMS AHEAD OF WAVEFORM
  Durations(Index) = PreStimSilence+PostStimSilence+...
    (cNBiasStim-1)*(Par.BetweenBiasPause + Par.BiasDurations) + Par.BiasDurations + ...
    Par.AfterBiasPause + 2*Par.PairDurations + Par.BetweenPairPause;
  
  Names{Index} = sprintf(['PitchClass =  %d  |  BiasDirection = %d  |  BiasVariant = %d  |  NBiasStim = %d  |'],...
    cPitchClass,cBiasDirection,cBias,cNBiasStim);
end
O = set(O,'NBiasStimByIndex',NBiasStimByIndex);
O = set(O,'PitchClassByIndex',PitchClassByIndex);
O = set(O,'BiasByIndex',BiasByIndex);
O = set(O,'BiasDirectionByIndex',BiasDirectionByIndex);
O = set(O,'Names',Names);
O = set(O,'Duration',Durations);

