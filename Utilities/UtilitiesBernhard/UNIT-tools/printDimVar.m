function Str = printDimVar(Val,Nsign)

if ~exist('Nsign','var') Nsign = 2; end

if isDimVar(Val)
 [uo,us] = unitsOf(Val);
 Num = u2num(Val); Factor = 1; FactorS = '';
 if Num<=.1 & Num>1e-4 Factor=1e3; FactorS='m'; end
 if Num<=1e-4 & Num>1e-7 Factor=1e6; FactorS='\mu '; end
 Str = [n2s(Factor*Num,Nsign),' ',FactorS,us];
else
 Str = n2s(Val,Nsign);
end