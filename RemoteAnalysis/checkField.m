function checkField(P,Field,DefVal)

if ~isempty(P) FN = fieldnames(P); else FN = {}; end
ApproxMatch = strcmp(lower(FN),lower(Field));
if  sum(ApproxMatch)% A POTENTIALLY INEXACT MATCH EXiSTS
  if ~sum(strcmp(FN,Field)) % NO EXACT MATCH, CORRECT TO
    UserField = FN{ApproxMatch};
    fprintf(['Argument name ''',UserField,''' corrected to ''',Field,'''\n']);
    P(1).(Field) = P.(UserField);
    P = rmfield(P,UserField);
  end
else % NO MATCH, NOT EVEN INEXACT EXISTS
  if ~exist('DefVal','var')
    error(['checkField : The argument ''',Field,''' needs to be assigned!']);
  else
    P(1).(Field) = DefVal;
  end
end
assignin('caller','P',P);