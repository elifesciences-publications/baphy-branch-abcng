function [HW,globalparams] = IOConnectWithManta(HW,globalparams)          

global Verbose; if isempty(Verbose) Verbose = 0; end
global BaphyMANTAConn

% ESTABLISH SIMPLE TCPIP SERVER TO COMMUNICATE FOR SAVING & SYNCHING
HW.MANTA = struct('COMterm','|','MSGterm',33,'TimeOut',5,'Port',33330);

% TAKE LAST CONNECTION AS THE ACTIVE ONE
if ~isempty(BaphyMANTAConn)
  HW.MANTA.Connect = strcmp(get(BaphyMANTAConn,'Status'),'open');
else
  HW.MANTA.Connect = 0;
end
  
% TEST PREVIOUS CONNECTIONS & CONNECT
if HW.MANTA.Connect > 0
  fprintf(['Checking Connection...']);
  MSG =  ['COMTEST', HW.MANTA.COMterm, HW.MANTA.MSGterm];
  try 
    RESP = IOSendMessageManta(HW,MSG);
  catch
    RESP = '';
  end
  switch RESP
    case 'COMTEST OK';  fprintf('OK\n'); HW.MANTA.Connect = 1;
    otherwise fprintf('dead\n'); HW.MANTA.Connect = 0; 
  end
end

% CONNECT TO MANTA
if ~HW.MANTA.Connect
  fprintf('Waiting for connect from MANTA ... '); Connected = 0;
  %HW.MANTA.Server=jtcp('ACCEPT',HW.MANTA.Port,'timeout',10000);
  BaphyMANTAConn = tcpip('0.0.0.0',HW.MANTA.Port,'TimeOut',10,'OutputBufferSize',2^18,'InputBufferSize',2^18,'NetworkRole','server');
  fopen(BaphyMANTAConn);
  flushinput(BaphyMANTAConn); flushoutput(BaphyMANTAConn);
  set(BaphyMANTAConn,'Terminator',HW.MANTA.MSGterm);
  fprintf([' TCP IP connection established.\n']);
end  
  
% SEND INITIALIZATION
SaveFile = M_setRawFileName(globalparams.mfilename);
fprintf('MANTA saving to: %s\n',SaveFile);
MSG = ['INIT',HW.MANTA.COMterm,SaveFile,HW.MANTA.MSGterm];
IOSendMessageManta(HW,MSG,'INIT OK','>> Recording System ready!\n');

% TRANSFER VARIABLES
Vars = {'MG.DAQ.ArraysByBoard','MG.DAQ.SystemsByBoard',...
  'MG.DAQ.ElectrodesByChannel'};
for i=1:length(Vars)
  MSG = ['GETVAR',HW.MANTA.COMterm,Vars{i},HW.MANTA.MSGterm];
  RESP = IOSendMessageManta(HW,MSG);
  if RESP(end)=='!'; RESP = RESP(1:end-1); end
  globalparams.(Vars{i}(find(Vars{i}=='.',1,'last')+1:end)) = eval(RESP);
end