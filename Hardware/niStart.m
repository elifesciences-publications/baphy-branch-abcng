% function HW=niStart(HW)
%
% Start all NI Tasks defined in HW.AO, HW.AI and HW.DIO.  Sets DIO outputs to
% InitState before starting Analog tasks in order to prevent accidental
% triggering.
%
% created SVD 2012-05-29
%
function HW=niStart(HW)

global NI_SHOW_ERR_WARN

if NI_SHOW_ERR_WARN,
    disp('Starting NIDAQMX tasks');
end

for ii=1:length(HW.DIO),
  S = DAQmxStartTask(HW.DIO(ii).Ptr);
  if S NI_MSG(S); end
 
  if ~isempty(HW.DIO(ii).InitState),
    % make sure DO channels are set to appropriate initial state before
    % starting Analog channels
    SamplesWritten = libpointer('int32Ptr',false);
    WriteArray = libpointer('uint8PtrPtr',HW.DIO(ii).InitState);  % POINTER to array
    S = DAQmxWriteDigitalLines(HW.DIO(ii).Ptr,1,1,10,NI_decode('DAQmx_Val_GroupByScanNumber'),WriteArray,SamplesWritten,[]);
    if S NI_MSG(S); end
    if get(SamplesWritten,'value')<1,
      disp('warning: 1 sample not written during DO init!');
    end
  end
end

for ii=1%:length(HW.AI), %15/12-YB: starts only 1 AI acquisition bc the 2nd one is started in CanStart beforehand for @RewardEyeFixation
  S = DAQmxStartTask(HW.AI(ii).Ptr);
  if S NI_MSG(S); end
end
% can skip AO start since this has to have been started during load sound?
%for ii=1:length(HW.AO),
%  S = DAQmxStartTask(HW.AO(ii).Ptr);
%  if S NI_MSG(S); end
%end