function Paw = IOPawRead(HW,globalparams)
% function Paw = IOPawRead (HW,globalparams)
%
% This function reads the paw/barpress signal from the daq card and return it in l
% if global.LickSign is one, the function return one if the DIO is one,
% otherwise, it returns one when the DIO is zero.
%
% SVD, May 2006, ripped off of IOLickRead

global TOUCHSTATE0

if HW.params.HWSetup==0 | ...
    (isfield(HW.params,'simulate_touch') & HW.params.simulate_touch),
    
    % test mode
    if isempty(TOUCHSTATE0),
        TOUCHSTATE0=0;
    end
    Paw = TOUCHSTATE0;
    Paw = rand(1)>.001;
else
    
    % find appropriate digital line based on the name 'Paw' (regardless of 
    % digital channel number) and read value
    touchidx=find(strcmp(HW.DIO.Line.LineName,'Paw'));
    Paw = getvalue(HW.DIO.Line(touchidx));
    TOUCHSTATE0=Paw;
end

if isfield(HW.params,'PawSign') & HW.params.PawSign == -1 % invert the signal
    Paw = ~Paw;
end

