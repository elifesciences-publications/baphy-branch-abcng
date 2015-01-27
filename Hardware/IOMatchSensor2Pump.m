function PumpName = IOMatchSensor2Pump(Sensor,HW)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump
% 15/01: YB-may Go/NoGo and 2AFC available in a 2AFC setup

if ( nargin>1 && ( isfield(HW,'TwoAFCsetup') && HW.TwoAFCsetup ) && ( isfield(HW,'TwoAFCtask') && ~HW.TwoAFCtask ) )
  % Standard Go/NoGo setup: Change names to have the left spout considered  as the center spout in a Go/NoGo task in a 2AFC setup
  if ~iscell(Sensor) Sensor = {Sensor}; end
  for i=1:length(Sensor)
    switch Sensor{i}
      case 'Touch'; PumpName{i} = 'Pump';
      case 'TouchL'; PumpName{i} = 'PumpL';
      case 'TouchR'; PumpName{i} = 'PumpR';
      otherwise error('Sensor not implemented!');
    end
  end
else
  % Standard setup or 2AFC task in a 2AFC setup
  if ~iscell(Sensor) Sensor = {Sensor}; end
  for i=1:length(Sensor)
    switch Sensor{i}
      case 'Touch'; PumpName{i} = 'Pump';
      case 'TouchL'; PumpName{i} = 'PumpL';
      case 'TouchR'; PumpName{i} = 'PumpR';
      otherwise error('Sensor not implemented!');
    end
  end
end