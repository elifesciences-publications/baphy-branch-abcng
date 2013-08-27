% function HW=niClearTasks(HW)
%
% Housekeeping function to clear all tasks in HW.AO, HW.AI and HW.DIO.  And
% resets all the devices in HW.Devices.  Also deletes the entries from HW
% for good measure.
%
% created SVD 2012-05-29
%
function HW=niClearTasks(HW)

global NI_MASTER_TASK_LIST NI_SHOW_ERR_WARN

if isempty(NI_SHOW_ERR_WARN),
    NI_SHOW_ERR_WARN=0;
end

if isfield(HW,'params') && HW.params.HWSetup==0,
    % test mode, no daq
    return;
end

if ~isempty(NI_MASTER_TASK_LIST),
    if NI_SHOW_ERR_WARN
      disp('Clearing master task list');
    end
  for ii=1:length(NI_MASTER_TASK_LIST)
    S = DAQmxClearTask(NI_MASTER_TASK_LIST(ii));
    if S NI_MSG(S); end
  end
  NI_MASTER_TASK_LIST=[];
end

if NI_SHOW_ERR_WARN
    disp('Clearing tasks in HW (redundant??)');
end

if isfield(HW,'AI')
  for iD=1:length(HW.AI)
    S = DAQmxClearTask(HW.AI(iD).Ptr);
    if S NI_MSG(S); end
  end
end
if isfield(HW,'AO')
  for iD=1:length(HW.AO),
    S= DAQmxClearTask(HW.AO(iD).Ptr);
    if S NI_MSG(S); end
  end
end
if isfield(HW,'DIO')
  for iD=1:length(HW.DIO)
    S = DAQmxClearTask(HW.DIO(iD).Ptr);
    if S NI_MSG(S); end
  end
end
if isfield(HW,'Devices')
  for iD = 1:length(HW.Devices)
    niResetDevice(HW.Devices{iD});
  end
end

% clear all the tasks/devices
HW.DIO=[];
HW.AI=[];
HW.AO=[];
HW.Devices={};
