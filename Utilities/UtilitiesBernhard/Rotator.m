function Rotator(handle,event,AX)

global Rotating_ ; Rotating_ =1;
[StartingAz,StartingEl] = view;

if ~exist('AX','var') | isempty(AX) AX = gca; end

StartingPoint = get(0,'PointerLocation');
while Rotating_
  FinalPoint = get(0,'PointerLocation');
  DiffAz = (FinalPoint(1)-StartingPoint(1));
  DiffEl = (FinalPoint(2)-StartingPoint(2));
  for i=1:length(AX)
    view(AX(i),StartingAz-DiffAz/2,StartingEl-DiffEl/2);
  end
  pause(0.04);
end