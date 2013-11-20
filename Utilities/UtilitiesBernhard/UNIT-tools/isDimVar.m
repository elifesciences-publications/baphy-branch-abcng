function out = isDimVar(var)

if strcmp(class(var),'DimensionedVariable') out = 1; else out = 0; end