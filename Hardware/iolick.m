function r=iolick(HW,lickswitch)

global lickswitch0 LICKSIGN

if isempty(LICKSIGN),
    LICKSIGN=1;
end

if HW.params.HWSetup==0,  % ie, TEST MODE
    if isempty(lickswitch0),
        lickswitch0=0;
    end

    % ie, test mode
    if exist('lickswitch','var'),
        lickswitch0=lickswitch;
    end
elseif HW.params.HWSetup==2,  % training setup
    % real mode
    %r1=lickswitch0
    % 0=no contact, 1=contact, others=??
    lickswitch0=getvalue(HW.DIO.Line(8));
    if LICKSIGN<0,
        lickswitch0=1-lickswitch0;
    end
    %r2=lickswitch0
else
    % not supported in SPRs
    lickswitch0=0;
end

r=lickswitch0;

