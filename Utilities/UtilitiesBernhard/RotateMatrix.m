function RotateMatrix(obj,event)
% Rotate a three dimensional set of axes using the mouse
% Used for 3D array display in MANTA.
% Right Click should reset the view (needs to be implemented)

global Rotating_ ; Rotating_ =1;
global Matrix_ MatrixHandles_ AxDebug;

cFIG = gcf;
StartingPoint = get(0,'PointerLocation');
AxPos = cell2mat(get(MatrixHandles_,'Position'));
Children = get(cFIG,'Children'); OtherChildren = setdiff(Children,MatrixHandles_(:));
if ~isempty(AxDebug)
  figure(2); AxDebug = axes('Pos',[0.1,0.1,0.8,0.8]); 
end

while Rotating_
  % COLLECT USER MOVEMENT
  FinalPoint = get(0,'PointerLocation');
  Diffs = (FinalPoint - StartingPoint)/1000;
  %PPP(Diffs,'\n');
  
  % COMPUTE ROTATION MATRICES
  RotationMatrixAzimuth = [cos(Diffs(1)),-sin(Diffs(1)),0;sin(Diffs(1)),cos(Diffs(1)),0;0,0,1];
  RotationMatrixElevation = [1,0,0;0,cos(-Diffs(2)),-sin(-Diffs(2));0,sin(-Diffs(2)),cos(-Diffs(2))];
  
  % PROJECT MATRIX BASED ON THE AMOUNT OF MOVEMENT
  NewPositions3D = RotationMatrixAzimuth*Matrix_';
  NewPositions3D = RotationMatrixElevation*NewPositions3D;
  NewPositions2D = NewPositions3D([1,3],:);
  Depth = NewPositions3D(2,:); [tmp,SortInd] = sort(Depth,'ascend');
  %plot3(AxDebug,NewPositions3D(1,:),NewPositions3D(2,:),NewPositions3D(3,:),'.');
  %axis(AxDebug,2*[-1,1,-1,1,-1,1]);
  
  % PREVENT MATRIX FROM GOING NEGATIVE OR EXCEEDING 1
  NewPositions2D = NewPositions2D - repmat(min(NewPositions2D,[],2),1,size(NewPositions2D,2));
  NewPositions2D = NewPositions2D./(1.2+repmat(max(NewPositions2D,[],2),1,size(NewPositions2D,2)))+0.05;
  %plot(AxDebug,NewPositions2D(1,:),NewPositions2D(2,:),'.');
  %axis(AxDebug,2*[-1,1,-1,1]);
  
  % SET THE POSITIONS OF THE AXES
  for i=1:length(MatrixHandles_)
    set(MatrixHandles_(i),'Position',[NewPositions2D(:,i)',AxPos(i,3:4)]);
  end
  set(cFIG,'Children',[MatrixHandles_(SortInd);OtherChildren]);
  
  pause(0.04);
end
% SET NEW ROTATION OF THE MATRIX
Matrix_ = NewPositions3D';