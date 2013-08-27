function v1 = minus(v1,v2)

% --- ONLY  v1 is a dimensioned variable ------
if(isa(v1,'DimensionedVariable') && ~isa(v2,'DimensionedVariable')) || (~isa(v1,'DimensionedVariable') && isa(v2,'DimensionedVariable'))
    v1 = NaN; error('Unit inconsistency in subtraction');
end

%---- BOTH v1 and v2 are dimensioned variables -----
if(max(abs(v1.exponents - v2.exponents))>v1.exponentsZeroTolerance)
  v1 = NaN;
  error('Unit inconsistency in subtraction');
end

v1.value = v1.value - v2.value;
