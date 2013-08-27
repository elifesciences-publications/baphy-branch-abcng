% function iocleanup(DAQ);
%
% close DAQ connection to allow for clean reconnect
%
function iocleanup(DAQ);

if ~isempty(DAQ),
    disp('cleaning up DAQ');
    delete(DAQ.AO);
    delete(DAQ.DIO);
    if isfield(DAQ,'AI'),
        delete(DAQ.AI);
    end
    clear DAQ;
end
