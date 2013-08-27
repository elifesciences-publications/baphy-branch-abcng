function o = ObjUpdate(o);
% Update the changes of a MultiStream object
%
% benglitz 2010

FieldNames = get(o,'FieldNames');
FieldTypes = get(o,'FieldTypes');
for i=1:length(FieldNames) 
  switch FieldTypes{i}
    case 'edit';    
      tmp = get(o,FieldNames{i});
      if ~isnumeric(tmp) tmp = eval(['[',tmp,']']); end
      Par.(FieldNames{i}) = tmp;
    case 'popupmenu';  Par.(FieldNames{i}) = get(o,FieldNames{i}); 
    otherwise error('FieldType not implemented!');
  end
end

Par.BiasBasePitches = sort(Par.BiasBasePitches);
MaxIndex = Par.Randomizations*length(Par.BiasBasePitches);
o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Par',Par);

% SET NAMES
Durations = zeros(MaxIndex,1);
for Index=1:MaxIndex
  % GET PARAMETERS OF CURRENT Index
  iBiasBasePitch = ceil(Index/Par.Randomizations);
  cBiasBasePitch = Par.BiasBasePitches(iBiasBasePitch);
  cRandomization = mod(Index,Par.Randomizations);
  if ~cRandomization cRandomization = Par.Randomizations; end
  
  % COMPUTE STIMULUS LENGTHS FOR DMS AHEAD OF WAVEFORM
  Durations(Index) = get(o,'PreStimSilence')+get(o,'PostStimSilence')+...
    Par.PitchSteps*(Par.NBiasStim*(Par.BiasDur + Par.BetweenBiasPause) ...
    + Par.TestDur + Par.AfterBiasPause) + ...
    Par.NBiasLeadIn*(Par.BiasDur + Par.BetweenBiasPause);
    
  Names{Index} = ['BiasBasePitch = ',n2s(cBiasBasePitch), '  |  Randomization = ',n2s(cRandomization)];
end
o = set(o,'Names',Names);
o = set(o,'Duration',Durations);