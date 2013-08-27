function [r,timestamp]=iopump(HW,pumpswitch)

persistent pumpswitch0

    if HW.params.HWSetup==0,  % ie, TEST MODE
        
        if exist('pumpswitch','var'),
            pumpswitch0=pumpswitch;
            if pumpswitch0==1,
                t=(0:1/12000:0.25)';
                rewardsound=4*sin(2*pi*4000.*t);
                sound(rewardsound,12000);
                %Snd('Play',rewardsound,12000);
            end
        end
        if nargout>0,
            r=pumpswitch0;
        end
        timestamp=toc;
    else
        % real mode
        if exist('pumpswitch','var'),
            % 0=off, 1=on, others=??
            %putvalue(HW.DIO.Line(8),pumpswitch);
            putvalue(HW.DIO.Line(6),pumpswitch);
            pumpswitch0=pumpswitch;
        end
        if nargout>0,
            r=pumpswitch0;
        end
        timestamp=toc;
    end

