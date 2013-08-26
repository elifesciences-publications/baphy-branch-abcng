function bstat=wait_get_bstat(HW,bstat,bstep,tstart,waitsec);

bcount=size(bstat,1);
t=clock;
while etime(clock,t)<waitsec
    if etime(clock,tstart)>(bcount+1)*bstep,
        bstat=[bstat; IOGetDIOState(HW,'Light') IOLickRead(HW) IOGetDIOState(HW,'Pump')];
        bcount=bcount+1;
    else
        pause(bstep/10);
    end
end
