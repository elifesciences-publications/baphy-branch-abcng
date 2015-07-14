function M_Pupil_TCPIP(obj,event)
% Callback function of the TCPIP connection for Baphy Pupillometry GUI,
% hacked from MANTA
global MG
Sep = filesep;

% GET DATA FROM STIMULATOR
if ~obj.BytesAvailable 
  echo('\n\tWARNING : No Bytes Available.\n'); 
  return; 
end
ArrivalTime = now;
tmp = char(fread(obj,obj.BytesAvailable))'; flushinput(obj);
Terms = find(tmp==MG.Stim.MSGterm); Terms = [0,Terms];
for i=2:length(Terms) Messages{i-1} = tmp(Terms(i-1)+1:Terms(i)-1); end
Pos = find(int8(Messages{end})==MG.Stim.COMterm);
if isempty(Pos)  Pos = length(Messages{end})+1; end
[TV,TS] = datenum2time(ArrivalTime);

echo([' <---> TCPIP message received: ',escapeMasker(Messages{end}),' (',TS{1},')\n']); 

COMMAND = Messages{end}(1:Pos-1);
DATA = Messages{end}(Pos+1:end);

switch COMMAND
  case 'INIT';    
    BaseName = DATA;
    MG.Pupil.BaseName = BaseName;
    MG.Pupil.BasePath = BaseName(1:find(BaseName==filesep,1,'last'));
    % UPDATE DISPLAY
    set(MG.Pupil.BaseName,'String',BaseName);
    set(MG.Pupil.CurrentFileSize,'String','');
    % PARSE NAME AND CHECK EXISTENCE OF DIRECTORY
    mkdirAll(BaseName);
    M_sendMessage([COMMAND,' OK']);

  case 'START';
    M_parseFilename(DATA);
   
    % 
    % UPDATE DISPLAY -- replace with update_status, filename etc in pupil
    % GUI
    %set(MG.GUI.BaseName,'String',MG.DAQ.BaseName);
    %set(MG.GUI.Animal,'String',MG.DAQ.Penetration);
    %set(MG.GUI.Condition,'String',MG.DAQ.Condition);
    %set(MG.GUI.Trial,'String',MG.DAQ.Trial);
    %set(MG.GUI.CurrentFileSize,'String','');
    
    % PREPARE FILES FOR SAVING
    %M_prepareRecording; M_Logger('\n => Files ready ... \n'); 
    
    drawnow;
    
    M_sendMessage([COMMAND,' OK']);
    
    % Start recording pupil data 
    % call SOMETHING IN pupil.m
    
  case 'STOP';
    MG.DAQ.StopMessageReceived = 1;
    % Stop recording pupil data 
    % call SOMETHING IN pupil.m
    % M_stopRecording; 

%
% Following 3 cases are probably not necessary but worth leaving around in
% case they become useful
%
  case 'SETVAR';
    eval(DATA);
    M_sendMessage('SETVAR OK');
    
  case 'RUNFUN';
    eval(DATA); % NO RESPONSE MESSAGE SENT, SINCE SOME COMMANDS DON'T TERMINATE (here M_startEndine)
     
  case 'GETVAR';
     % SVD hack, don't repeat certain values over and over to save space in
     % tranmitted string.
     SendStruct=eval(DATA);
     lastsysmatch=1;
     lastarraymatch=1;
     for ii=2:length(SendStruct),
        if isfield(SendStruct,'Array') && strcmp(SendStruct(ii).Array,SendStruct(lastarraymatch).Array),
           SendStruct(ii).Array='';
        else
           lastarraymatch=ii;
        end
        if isfield(SendStruct,'System') && strcmp(SendStruct(ii).System,SendStruct(lastsysmatch).System),
           SendStruct(ii).System='';
        else
           lastsysmatch=ii;
        end
     end
    String = HF_var2string(SendStruct);
    M_sendMessage(String);
    
  case 'COMTEST';
    M_sendMessage([COMMAND,' OK']);
    
  otherwise fprintf(['WARNING: Unknown command received: ',COMMAND,'\n']);
end

  


