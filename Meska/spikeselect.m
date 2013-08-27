% event indices are passed in (ei)

%ei = hood+(1:min(nspk,size(Ws,2))); 
ei = hood+1:min(hood+nspk,size(Ws,2));


s = Ws(:,ei(ismember(Wt(ei),St)));
u = Ws(:,ei(ismember(Wt(ei),setdiff(Wt,St))));


subplot(h1), hold off
if ~isempty(u),
 plot(ts,u,'y')
 hold on
end
if ~isempty(s),
 plot(ts,s)
end




if isempty(yaxis), 
%  yaxis = 1.1*[min(spkraw),max(spkraw)];
 spk1min=min(spkraw); spk2min = min(spkraw2);
 
if ~ONEFILE
    spk1max=max(spkraw); spk2max = max(spkraw2);	
     yaxis = 1.1*[min(spk1min,spk2min),max(spk1max,spk2max)];
     set(e4,'string',['[',num2str(round(yaxis(1))),',',num2str(round(yaxis(2))),']'])
 else
     yaxis = 1.1*[spk1min,spk1max];   
 end 
end


set(h1,'ylim',yaxis)
set(h1,'xlim',xaxis)
subplot(h1); grid on;


if isempty(u)&isempty(s),
  cla, if exist('wlha'), if ishandle(wlha), delete(wlha), end, end
else 
 subplot(h1)
 [wlha,wlhb] = legend([num2str(length(St)) ' selected'],1);
 if ~isempty(wlha), set(wlha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(wlhb(2)), end
 
end

if ~ONEFILE
    ei2 = hood2+1:min(hood2+nspk,size(Ws2,2));
    s2 = Ws2(:,ei2(ismember(Wt2(ei2),St2)));
    u2 = Ws2(:,ei2(ismember(Wt2(ei2),setdiff(Wt2,St2))));
    subplot(h12), hold off
    if ~isempty(u2),
         plot(ts,u2,'y')
          hold on
    end
    if ~isempty(s2),
        plot(ts,s2)
    end
    set(h12,'ylim',yaxis)
    set(h12,'xlim',xaxis)
    subplot(h12);grid on;
    if isempty(u2)&isempty(s2),
        cla, if exist('wlha2'), if ishandle(wlha2), delete(wlha2), end, end
    else 
        subplot(h12)
        [wlha2,wlhb2] = legend([num2str(length(St2)) ' selected'],1);
         if ~isempty(wlha2), set(wlha2,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(wlhb2(2)), end
   end
end

