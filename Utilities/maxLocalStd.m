function M = maxLocalStd(X,SR,Window)

StepSize = round(Window*SR);
MaxIter = ceil(length(X)/StepSize);
X(end+1:MaxIter*StepSize) = 0; 
WX = reshape(X,StepSize,MaxIter);

SS = std(WX);
M = max(SS);