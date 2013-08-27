function [PumpName,PumpLine] = IOMatchIndex2Pump(HW,Indices)
% The Index here ranges over the values 1...NPumps

LineNames = HW.DIO.Line.LineName;
LineIndices=find(~cellfun(@isempty,strfind(LineNames,'Pump'))));
PumpLines = LineIndices(Indices);
PumpNames = LineNames(PumpLines);