function ll=iolight(HW,lightswitch)

persistent lightswitch0

    if HW.params.HWSetup==0,  % ie, TEST MODE
        
       if exist('lightswitch','var'),
            lightswitch0=lightswitch;
        end
        if nargout>0,
            ll=lightswitch0;
        end
        
    else
        
        % real mode : training rig (and SPR???)
        if exist('lightswitch','var'),
            % 0=off, 1=on, others=??
            putvalue(HW.DIO.Line(1),lightswitch);
            lightswitch0=lightswitch;
        end
        if nargout>0,
            ll=lightswitch0;
        end
    end

