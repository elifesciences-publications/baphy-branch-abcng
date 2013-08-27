function PumpName = IOMatchPosition2Pump(Position)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump

if ~iscell(Position) Position = {Position}; end
for i=1:length(Position)
  switch Position{i}
    case 'center'; PumpName{i} = 'Pump';
    case 'left'; PumpName{i} = 'PumpL';
    case 'right'; PumpName{i} = 'PumpR';
    otherwise error('Position not implemented!');
  end
end
