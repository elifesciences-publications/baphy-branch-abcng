function O = ObjUpdate(O)
% Update the changes of a PsycholinguisticObject
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

O = set(O,'Par',Par);
MaxIndex = get(O,'MaxIndex');
% SET NAMES
Durations = zeros(MaxIndex,1);
Names = cell(1);
PreStimSilence = get(O,'PreStimSilence');
PostStimSilence = get(O,'PostStimSilence');

for Index=1:MaxIndex
  Durations(Index) = PreStimSilence + PostStimSilence + 120; % INSERT DURATIONS HERE 
end

[p, ~, ~] = fileparts(mfilename('fullpath'));
switch O.StimulusType
    case 'PilotScrambling'
%         load([p filesep 'stim-orders-ferret.mat']);
        load([p filesep 'ScramblingOrder' filesep 'r1.mat']);
        sounds = stim_order(:,1);
end
O = set(O,'MaxIndex',numel(sounds));
O = set(O,'Names',sounds);
O = set(O,'Duration',Durations);