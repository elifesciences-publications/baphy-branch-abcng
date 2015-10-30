function M = maxLocalStd(X,SR,Window)
% 15/08: YB
% StepSize = round(Window*SR);
% MaxIter = ceil(length(X)/StepSize);
% X(end+1:MaxIter*StepSize) = 0;
% WX = reshape(X,StepSize,MaxIter);
%
% SS = std(WX);
% M = max(SS);

Conseq0 = 0.15;   % s
Min0length = round(Conseq0*SR);
Ind2remove = [];
Ind0 = find(X==0);
Xnum = 1;
if length(Ind0)~=length(X)
  while Xnum<=length(Ind0)
    Length0 = find(X(Ind0(Xnum):end)~=0,1,'first')-1;
    if ~isempty(Length0)
      if Length0>=Min0length
        Ind2remove = [Ind2remove Ind0(Xnum):(Ind0(Xnum)+Length0)];
      end
      Xnum = find(Ind0(Xnum:end)>(Ind0(Xnum)+Length0),1,'first')+Xnum-1;;
    elseif isempty(Length0)
      if length(Ind0)>=(Xnum+Min0length)
        Ind2remove = [Ind2remove Ind0(Xnum):Ind0(end)];
      end
      break
    end
  end
  X = X(setdiff(1:length(X),Ind2remove));
  StepSize = length(X);
  MaxIter = ceil(length(X)/StepSize);
  X(end+1:MaxIter*StepSize) = 0;
  WX = reshape(X,StepSize,MaxIter);
  
  SS = std(WX);
  M = max(SS);
else % case where X is only 0's
  M = 1;
end