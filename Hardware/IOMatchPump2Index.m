function IndicesOrdered = IOMatchPump2Index(HW,PumpNames)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump

if ~iscell(PumpNames) PumpNames = {PumpNames}; end

switch HW.params.HWSetup
  case 0
    IndicesOrdered = 1:length(PumpNames);
  otherwise
    LineNames = HW.DIO.Line.LineName;
    for i=1:length(PumpNames)
      LineIndices(i)=find(strcmp(LineNames,PumpNames{i}));
    end
    [LinesSorted,IndicesOrdered] = sort(LineIndices);
end
