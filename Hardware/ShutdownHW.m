function ShutdownHW(HW)
% This function closes and clears all the hardware instruments that are
% open. It does this in two stages, first by loading the HW variable from
% the hardware setup file and closing them one by one, and second by
% finding all the instruments in the memory and closing them.
% The reason the second method is not enough has to do with Java.Sockets in
% matlab, I dont know how to find the open TCPIP sockets in matlab!

% Nima, November 2005
global BAPHYHOME;
if isempty(BAPHYHOME) baphy_set_path;end
%

if (nargin<1) 
    HW=[];
    if exist([BAPHYHOME filesep 'Config' filesep 'BaphyHWSetup.mat'])
        try
            load([BAPHYHOME filesep 'Config' filesep 'BaphyHWSetup.mat']);
        catch
            warning('corrupt config file');
            delete([BAPHYHOME filesep 'Config' filesep 'BaphyHWSetup.mat']);
        end
%     else 
%         return;
    end
end

% If HWSetup exists, open it and close all devices
fclose ('all');

% delete all timers:
IOShutdownTimers;

if ~isempty(HW) && isfield(HW,'aw'),
    % tell alpha-omega to stop acquiring data
    disp('stopping A-O');
    try
        fwrite(HW.aw,'StopAcq');
    catch
        warning('could not shut down A-O');
    end;
end

if strcmpi(IODriver(HW),'NIDAQMX'),
  % is this adequate for resetting???
  HW.params.SHOW_ERR_WARN=0;
  HW=niStop(HW);
  HW=niClearTasks(HW);
  
  
elseif ~isempty(HW) && isfield(HW.params,'HWSetup') && (HW.params.HWSetup)
    devices = fieldnames(HW);
    for cnt1 = 1:length(devices)
        if ~isempty(HW.(devices{cnt1})) & isobject(HW.(devices{cnt1}))
            try stop(HW.(devices{cnt1} ));catch end;
            try delete(HW.(devices{cnt1}));catch end;
            try clear HW.(devices{cnt1});catch end;
        end
    end
end

if exist([BAPHYHOME filesep 'Config' filesep 'BaphyHWSetup.mat'],'file'),
    delete([BAPHYHOME filesep 'Config' filesep 'BaphyHWSetup.mat']);
end

% perform a clean up, to make sure no object (ni, serial, Gpip) is in memory:
devices = instrfindall;     % this matlab command find the open devices
if ~isempty(devices)
  Types = get(devices,'Type');
  devices = devices(~strcmp(Types,'tcpip')); % DO NOT DELETE TCPIP OBJECT
  for cnt1 = 1:length(devices)
    delete(devices(cnt1));
  end
end
clear HW;
