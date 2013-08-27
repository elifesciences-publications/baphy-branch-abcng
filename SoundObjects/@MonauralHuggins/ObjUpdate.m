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

MaxIndex = length(Par.Frequencies);
o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Par',Par);

% SET NAMES
Durations = zeros(MaxIndex,1);
for Index=1:MaxIndex  
  % COMPUTE STIMULUS LENGTHS FOR DMS AHEAD OF WAVEFORM
  Durations(Index) = Par.StimDur+get(o,'PreStimSilence')+get(o,'PostStimSilence');
  Names{Index} = ['Index ',n2s(Index),'  |  Frequency ',n2s(Index)];
end
o = set(o,'Names',Names);
o = set(o,'Duration',Durations);