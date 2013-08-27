function DataMakeLocal(varargin)

dbopen;

if length(varargin)==1 % Just a filename, hand to evpmakelocal
  Filenames{1} = varargin{1};
else
  P = parsePairs(varargin);
  checkField(P,'Selector');
  R = mysql(['SELECT * FROM gDataRaw WHERE parmfile like "%',P.Selector,'%" AND not(training)']);
  
  MD_getGlobals;
  k=0;
  Filenames = {};
  for i=1:length(R)
      EVPVersion = 5; % FIRST TRY 5
      Filename = LF_getFilename(R(i).cellid,R(i).parmfile,EVPVersion);
      if ~exist(Filename,'file') % SWITCHING TO EVP4/AO Recording
        EVPVersion = 4;
        Filename = LF_getFilename(R(i).cellid,R(i).parmfile,EVPVersion);
      end
      k=k+1;
      Filenames{k} = Filename;
  end
end

for i=1:length(Filenames)
  fprintf(['===== [ ',escapeMasker(Filenames{i}),' ] =======\n\n']);
  Result = evpmakelocal(Filenames{i});
  fprintf('\n [ OK ] \n\n');
end

function Filename = LF_getFilename(CellID,Parmfile,EVPVersion)

global MD;
DF = MD_dataFormat('Mode','operator','EVPVersion',EVPVersion);
switch EVPVersion
  case 4;
    Path = MD_getDir('Identifier',[CellID,'01'],'DB',1,'Kind','recording','EVPVersion',EVPVersion);
    Filename = [Parmfile(1:end-1),'evp'];
  case 5;
    Path = MD_getDir('Identifier',CellID,'DB',1,'Kind','raw','EVPVersion',EVPVersion);

    Fields = regexp(Parmfile(1:end-2),DF.I2S.RE('Behavior'),DF.I2S.Opt{:});
    Identifier = DF.S2I.FH(MD.Animals.P2A.(Fields.Animal),str2num(Fields.Penetration),...
      Fields.Depth,str2num(Fields.Recording));
    Filename = [Identifier,'.tgz'];
end
Filename = [Path,Filename];