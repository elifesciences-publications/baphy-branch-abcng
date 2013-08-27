function LightName = IOMatchPosition2Light(HW,Position)
% The ordered Index here ranges over the values 1...NPumps
% This function is used for backward compatibility with the old format of having only 1 pump

if ~iscell(Position) Position = {Position}; end
for i=1:length(Position)
  switch Position{i}
    case 'center'; LightName{i} = 'Light';
    case 'left'; LightName{i} = 'LightL';
    case 'right'; LightName{i} = 'LightR';
    otherwise error('Position not implemented!');
  end
end
