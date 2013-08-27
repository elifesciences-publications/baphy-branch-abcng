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

MaxIndex = 1;
o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Par',Par);

% SET NAMES
Index = 1;
Durations(Index) = 2*Par.ToneDur + Par.AfterTonePause + ...
  Par.NTonesSeq*Par.SeqToneDur + (Par.NTonesSeq-1)*Par.WithinSeqPause + Par.AfterSeqPause + ....
  get(o,'PreStimSilence')+get(o,'PostStimSilence');

Names{Index} = ['Standard ',n2s(Index)];
  
o = set(o,'Names',Names);
o = set(o,'Duration',Durations);