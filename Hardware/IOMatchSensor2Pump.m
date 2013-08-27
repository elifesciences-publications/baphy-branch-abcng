function PumpName = IOMatchSensor2Pump(Sensor)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump

if ~iscell(Sensor) Sensor = {Sensor}; end
for i=1:length(Sensor)
  switch Sensor{i}
    case 'Touch'; PumpName{i} = 'Pump';
    case 'TouchL'; PumpName{i} = 'PumpL';
    case 'TouchR'; PumpName{i} = 'PumpR';
    otherwise error('Sensor not implemented!');
  end
end
