function O = ObjUpdate(O);
% Update the changes of a WhiteNoise object
%
% benglitz 2013

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

O = set(O,'MaxIndex',1);
O = set(O,'Par',Par);

% SET NAMES
Names{1} = 'Noise';
Duration =  get(O,'PreStimSilence')+get(O,'PostStimSilence')+Par.StimDuration; 
O = set(O,'Names',Names);
O = set(O,'Duration',Duration);