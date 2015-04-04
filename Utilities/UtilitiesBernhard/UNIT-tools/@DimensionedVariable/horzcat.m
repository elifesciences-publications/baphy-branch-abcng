function vOut = horzcat(varargin)

% --- ONLY  v1 is a dimensioned variable ------
R = ones(length(varargin));
for i=1:length(varargin)
  R(i) = isa(varargin{i},'DimensionedVariable');
end
if find(R==0) 
  error('Unit inconsistency in addition');
  vOut = NaN;
else  %---- ALL varargin are dimensioned variables -----
  for i=2:length(varargin)
    if max(abs(varargin{1}.exponents - varargin{i}.exponents))>varargin{1}.exponentsZeroTolerance
      vOut = NaN;
      error('Unit inconsistency in addition');
    end
  end
  TotalLength = 0;
  for i=1:length(varargin) TotalLength = TotalLength + length(varargin{i}.value); end
  Values = zeros(1,TotalLength); cPos = 0;
  for i=1:length(varargin)
    Values(cPos+1:cPos+length(varargin{i}.value)) = varargin{i}.value;
    cPos = cPos + length(varargin{i}.value);
  end
  vOut = varargin{1};
  vOut.value = Values;
end
