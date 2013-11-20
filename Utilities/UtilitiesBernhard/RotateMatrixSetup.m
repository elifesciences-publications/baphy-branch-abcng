function RotateMatrixSetup()

set(gcf,'ButtonDownFcn',{@RotateMatrix},...
  'WindowButtonUpFcn','global Rotating_ ; Rotating_ = 0;','Units','norm');
clear global MatrixHandles_ Matrix_; 
global MatrixHandles_ Matrix_; 

m=0; 
for iX=1:3 % left to right
  for iY=1:3 % front to back
    for iZ=1:3 % top to bottom
      m=m+1; 
      Matrix_(m,:) = [iX-2.5,iY-2.5,iZ-2.5]; 
      MatrixHandles_(m) = axes('Pos',[iX/3.5-iY/20,iZ/3.5-iY/20,0.1,0.1],'Color','white'); 
    end; 
  end; 
end