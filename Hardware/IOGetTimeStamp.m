function timestamp = IOGetTimeStamp(HW)
% function timestamp = IOGetTimeStamp(HW)
%
% HW - DAQ structure. HW.params.HWSetup==0 : testmode
%
% returns timestamp of event relative to start of trial (ie, when HW.AI was
% started)
% 
% created SVD 2005-10-20
% SVD 2005-11-20
% made compatible with nima's tic/toc scheme
% SVD 2005-11-22
% reverted back to DAQ clock
% SVD 2012-05-30
% added nidaqmx support
%

switch HW.params.HWSetup
  case 0 % test mode
      NowTime=clock;
      timestamp=etime(NowTime,HW.params.StartClock);
  otherwise
    if strcmpi(IODriver(HW),'NIDAQMX'),
      timestamp=niSamplesAvailable(HW.AI(1))/HW.params.fsAI;
    else
      timestamp=get(HW.AI,'SamplesAcquired')/HW.params.fsAI;
      %timestamp=etime(clock,get(HW.AI,'InitialTriggerTime'));
    end
end
