function PumpName = IOMatchPosition2Pump(Position,HW)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump
% 15/01: YB-may Go/NoGo and 2AFC available in a 2AFC setup

if ( nargin>1 && ( isfield(HW,'TwoAFCsetup') && HW.TwoAFCsetup ) && ( isfield(HW,'TwoAFCtask') && ~HW.TwoAFCtask ) )
  % Standard Go/NoGo in a 2AFC setup: Change names to have the left spout considered  as the center spout
  if ~iscell(Position) Position = {Position}; end
  for i=1:length(Position)
    switch Position{i}
      case 'center'; PumpName{i} = 'PumpL';
      case 'left'; PumpName{i} = 'Pump';
      case 'right'; PumpName{i} = 'PumpR';
      otherwise error('Position not implemented!');
    end
  end
else
  % Standard setup or 2AFC task in a 2AFC setup
  if ~iscell(Position) Position = {Position}; end
  for i=1:length(Position)
    switch Position{i}
      case 'center'; PumpName{i} = 'Pump';
      case 'left'; PumpName{i} = 'PumpL';
      case 'right'; PumpName{i} = 'PumpR';
      otherwise error('Position not implemented!');
    end
  end
end
