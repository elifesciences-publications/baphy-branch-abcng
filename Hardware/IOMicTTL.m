function TTL=IOMicTTL(HW)
%Read microphone input TTL signal

global MIC_TTL

if isrunning(HW.AI) && ~isempty(MIC_TTL) && ~isempty(MIC_TTL.data),
    dd=MIC_TTL.data;
    %figure(1);
    %clf
    %plot(MIC_TTL.time-MIC_TTL.time(1),dd);
    TTL=dd(end);
else
    TTL=0;

end

