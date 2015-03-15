function LightName = IOMatchPosition2Light(HW,Position)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump
% 15/01: YB-may Go/NoGo and 2AFC available in a 2AFC setup

if ( nargin>1 && ( isfield(HW,'TwoAFCsetup') && HW.TwoAFCsetup ) && ( isfield(HW,'TwoAFCtask') && ~HW.TwoAFCtask ) )
  % Standard Go/NoGo setup: Change names to have the left spout considered  as the center spout in a Go/NoGo task in a 2AFC setup
if ~iscell(Position) Position = {Position}; end
for i=1:length(Position)
  switch Position{i}
    case 'center'; LightName{i} = 'LightL';
    case 'left'; LightName{i} = 'Light';
    case 'right'; LightName{i} = 'LightR';
    otherwise error('Position not implemented!');
  end
end

else
  % Standard setup or 2AFC task in a 2AFC setup
if ~iscell(Position) Position = {Position}; end
for i=1:length(Position)
  switch Position{i}
    case 'center'; LightName{i} = 'Light';
    case 'left'; LightName{i} = 'LightL';
    case 'right'; LightName{i} = 'LightR';
    otherwise error('Position not implemented!');
  end
end
end
