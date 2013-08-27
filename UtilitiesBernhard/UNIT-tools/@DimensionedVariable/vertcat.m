function vOut = vertcat(v1,v2)

% --- ONLY  v1 is a dimensioned variable ------
if(isa(v1,'DimensionedVariable') && ~isa(v2,'DimensionedVariable'))
    vOut = NaN;
    error('Unit inconsistency in addition');
end

% --- ONLY  v2 is a dimensioned variable ------
if(~isa(v1,'DimensionedVariable') && isa(v2,'DimensionedVariable'))
    vOut = NaN;
    error('Unit inconsistency in addition');
end

%---- BOTH v1 and v2 are dimensioned variables -----
if(isa(v1,'DimensionedVariable') && isa(v2,'DimensionedVariable'))
    if(max(abs(v1.exponents - v2.exponents))>v1.exponentsZeroTolerance)
        vOut = NaN;
        error('Unit inconsistency in addition');
    end
    vOut = v1;
    vOut.value = vertcat(v1.value,v2.value);
end
