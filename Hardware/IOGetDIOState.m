function ioState = IOGetDIOState(HW,LineName)
% function ioState = IOGetDIOState(HW,LineName)
% 
% This function returns the current state of the digital outputs.
%
% SVD, 2005-12-15
%

global PUMPSTATE0 LIGHTSWITCH0 TOUCHSTATE0
if isempty(LIGHTSWITCH0),
    LIGHTSWITCH0=0;
end
if isempty(PUMPSTATE0),
    PUMPSTATE0=0;
end
if isempty(TOUCHSTATE0),
    TOUCHSTATE0=0;
end

switch HW.params.HWSetup
    case 0
        
        switch LineName,
            case 'Pump',
                ioState=PUMPSTATE0;
            case 'Light'
                ioState=LIGHTSWITCH0;
            case 'Touch'
                ioState=TOUCHSTATE0;
            otherwise,
                warning(['Line ',LineName,' does not exist']);
                ioState=-1;
        end

    otherwise
        
        % should work for all rigs. Requires initializing with appropriate
        % naming scheme
        lineidxOUT=min(find(strcmp(HW.DIO.Line.LineName,LineName)));
        lineidxIN=min(find(strcmp(HW.DIO.Line.LineName,LineName)));
        if ~isempty(lineidxOUT)
          ioState=getvalue(HW.DIO.Line(lineidxON));
        elseif ~isempty(lineidxIN)
          ioState=getvalue(HW.DIO.Line(lineidxIN));          
        else
          %warning([LineName, ' DIO channel not defined.']);
          ioState=-1;
        end        
        
end



