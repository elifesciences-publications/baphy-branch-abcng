function v1 = power(v1,v2)

% --- ONLY  v1 is a dimensioned variable ------
if(isa(v1,'DimensionedVariable') && ~isa(v2,'DimensionedVariable'))
  v1.value = v1.value.^v2;
  if(length(v2)>1)
    error('For X.^b, b must be scalar when X is dimensioned variable')
  end
  v1.exponents = v2*v1.exponents;
else
  vOut = NaN;
  error('Unit inconsistency in power function');
end

