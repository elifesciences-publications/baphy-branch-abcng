function [a,err]=init(a)

% initiates the connection  between the parent computer and alpha omega
% module by sending the peerinfo string
% a - awtcpip object
% err - =0 if init successful
%       =1 if init failed

if ~isa(a,'awtcpip')
    error('The input must belong to awtcpip class');
end

err=0;
%%%%%%%remove this later for Matlab 7
if strcmpi(a.socket,'')
    a=fopen(a);
end
%%%%%%%%


%%%%%add this for Matlab 7
% %if strcmpi(get(a,'Closed'),'on')|strcmpi(get(a,'Connected'),'off')
%     if nargout<1
%         error('Socket is closed - please provide an output variable');
%     end
%     valid=0;
%     while ~valid
%         a=fopen(a);
%         disp('Waiting to connect to alphaomega')
%         pause(0.1)
%         % read command from a server - should read STATUS=7
%         command = fread(a);
%         if ~isempty(strfind(command,'STATUS='))
%             statusvalue=str2num(command(findstr(command,'=')+1:end));
%             switch statusvalue
%                 case 200
%                     a=fclose(a);
%                     disp('ATTENTION: The acquisition is running!!')
%                     disp('Please stop the acquisition on alphaomega system')
%                     str=input('Try Reconnecting? [Return,y|n]','s');
%                     if strcmpi(str,'n')
%                         err=1;
%                         valid=1;
%                     else
%                         valid=0;
%                     end
%                 case 7
%                     valid=1;
%                 otherwise
%                     a=fclose(a);
%                     disp(['Some Error occured while connecting to alphaomega! Status value = ' num2str(statusvlue)])
%                     str=input('Try Reconnecting? [Return,y|n]','s');
%                     if strcmpi(str,'n')
%                         err=1;
%                         valid=1;
%                     else
%                         valid=0;
%                     end
%             end
%         else
%             a=fclose(a);
%             disp('Some Error occured while connecting to alphaomega!')
%             str=input('Try Reconnecting? [Return,y|n]','s');
%             if strcmpi(str,'n')
%                 err=1;
%                 valid=1;
%             else
%                 valid=0;
%             end
%         end
%     end
% end
% if ~err
%%%%%%
    disp('Connected!')
    % read command from a server - should read a=PEER_INFO
    command = fread(a);
    % reply to server with peerinfo command
    fwrite(a,getCmdString('peerinfo'));
    % pause till the server replies
    pause(0.2)
    tic
    valid=0;
    while ~available(a.ipstream)& ~(valid)
        if toc>30
            warning('timeout occured while waiting for channel info during init');
            valid=1;
        end
    end
    % read the info for all the channels
    for i=1:32
        command = fread(a);
    end
    % read a command from the server - should read STATUS=0
    command = fread(a);
    %%%%%add this for Matlab 7.0
    %end
    %%%%%