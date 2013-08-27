% function timestamp=iosoundstop(HW)
%
% stop action of HW.AO output.
%
% HW - handle of HW card. if [], run in TESTMODE (without HW connection)
%
% returns timestamp of event from HW
%
% created SVD 2005-08-31
%
function timestamp=iosoundstop(HW)

try,
    if HW.params.HWSetup==0,  % ie, TEST MODE
        
        %Snd('Quiet');
        timestamp=clock;
    else
        % real mode
        stop([HW.AO]);                 % stop interfaces
        putvalue(HW.DIO.Line(5),1);        % Trigger Off
        e=get(HW.AO,'EventLog');
        timestamp=e(end).Data.AbsTime;
   end

catch,
    iocleanup(HW);
    error(['error: ',lasterr]);
end
