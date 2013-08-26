% function timestamp=iotimestamp(DAQ)
%
% HW - DAQ structure. [] for testmode
%
% returns timestamp of event (from DAQ.AI clock??)
% 
% created SVD 2005-10-20
%
function timestamp=iotimestamp(HW)

switch HW.params.HWSetup
    case 0
        % ie, test mode
        timestamp=clock;
    otherwise
        tt=get(HW.AI,'SamplesAcquired')/HW.params.fsAI;
        e=get(HW.AI,'EventLog');
        timestamp=e(1).Data.AbsTime;
        timestamp(6)=timestamp(6)+tt;
end 
