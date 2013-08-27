function SensorName = IOMatchPosition2Sensor(Position)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump

if ~iscell(Position) Position = {Position}; end
for i=1:length(Position)
  switch Position{i}
    case 'center'; SensorName{i} = 'Touch';
    case 'left'; SensorName{i} = 'TouchL';
    case 'right'; SensorName{i} = 'TouchR';
    otherwise error('Position not implemented!');
  end
end