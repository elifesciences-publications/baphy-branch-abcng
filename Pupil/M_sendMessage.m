function M_sendMessage(Message)
% This file is part of MANTA licensed under the GPL. See MANTA.m for details.
global MG 
disp([' <---> TCPIP message sent : ',Message,'\n']); 
fwrite(MG.Stim.TCPIP,[Message,MG.Stim.MSGterm]);
