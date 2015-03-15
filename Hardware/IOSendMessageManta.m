function [RESP,HW] = IOSendMessageManta(HW,MSG,ACK,Output,Reconnect)

global Verbose
global BaphyMANTAConn

if ~exist('Output','var') Output = ''; end

% CLEAR BUFFER BEFORE READING
flushinput(BaphyMANTAConn);
% jtcp('read',HW.MANTA.Server,'maxnumbytes',inf);

% SEND MESSAGE
fwrite(BaphyMANTAConn,MSG);
%jtcp('write',BaphyMANTAConn,int8(MSG));

% IF YOU EXPECT A CERTAIN RESPONSE OR WANT THE RESPONSE
if ~exist('ACK','var') | ~isempty(ACK)
  % COLLECT RESPONSE
  tic;
  while ~get(BaphyMANTAConn,'BytesAvailable') & toc<5  pause(0.01); end;  pause(0.1);
  RESP = char(fread(BaphyMANTAConn,get(BaphyMANTAConn,'BytesAvailable'))');
  % REMOVE LINEFEEDS
  RESP = RESP(find(int8(RESP)~=10));
  % GO TO TERMINATOR, AND REMOVE IT
  Pos = find(int8(RESP)==HW.MANTA.MSGterm);
  if ~isempty(Pos) RESP = RESP(1:Pos(1)-1); end
  flushinput(BaphyMANTAConn);
  %   RESP = [ ]; dRESP = [ ]; tic;
  %   while isempty(RESP) & toc < BaphyMANTAConn.TimeOut/1000
  %     RESP = char(jtcp('read',BaphyMANTAConn,'maxnumbytes',2^18));
  %   end
  %   while ~isempty(dRESP) & toc < BaphyMANTAConn.TimeOut/1000
  %     pause(0.02);
  %     dRESP = char(jtcp('read',BaphyMANTAConn,'maxnumbytes',2^18));
  %     RESP = [RESP,dRESP];
  %   end
  %   RESP = RESP(1:end-1); % STRIP TRAILING NEWLINE
  if Verbose fprintf(['MANTA returned : ',RESP,'\n']); end
  
  % NOW CHECK WHETHER THE APPRORIATE ANSWER CAME
  if exist('ACK','var') & ~isempty(ACK)
    switch RESP
      case ACK; if ~isempty(Output) fprintf(Output); end
      otherwise
        % ATTEMPT RECONNECTION AFTER MANTA HAS RECOVERED
        if exist('Reconnect','var') & Reconnect
          fprintf('No or different Response "',RESP,'" received from MANTA.\n'); Connected = 0;
          global globalparams;
          while ~Connected
            fprintf('Press a button to try to reconnect\n'); pause;
            try
              [HW,globalparams] = IOConnectWithManta(HW,globalparams);
              Connected =1; HW.MANTA.RepeatLast = 1;
            end
          end
          [RESP,HW] = IOSendMessageManta(HW,MSG,ACK,Output);
        end
    end
  end
end