function M_stopTCPIP
% Kill TCPIP connection
% This file is part of MANTA licensed under the GPL. See MANTA.m for details.
global MG Verbose

try, 
  fclose(MG.Stim.TCPIP); 
  disp('Connection to stimulator terminated.\n');
catch,
    disp('No TCPIP connection to close');
end

% SET STATE IN GUI
%set(MG.Stim.TCPIP,'BackgroundColor',...
%  MG.Colors.TCPIP.(MG.Stim.TCPIP.Status),...
%  'Value',strcmp('open',MG.Stim.TCPIP.Status));