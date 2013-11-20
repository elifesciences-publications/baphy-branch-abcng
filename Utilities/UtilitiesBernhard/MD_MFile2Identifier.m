function Identifier = MD_MFile2Identifier(MFile)

if MFile(end-1:end)=='.m';  MFile = MFile(1:end-2); end
Pos = find(filesep==MFile);
if ~isempty(Pos)
  MFile = MFile(Pos(end)+1:end);
end
Pos = find(MFile=='_');
Identifier = MFile(1:Pos(1)-1);