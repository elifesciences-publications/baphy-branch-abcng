function Ind = IOGetIndex(Engine,Names)

if ~iscell(Names) Names = {Names}; end
for i=1:length(Names)
  tmp=find(strcmp(Engine.Line.LineName,Names{i}));
  if isempty(tmp),
    error(['Channel of Name ',Names{i},' is not defined.']);
  else
    Ind(i) = tmp;
  end
end