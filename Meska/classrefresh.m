% classrefresh.m
%
% hmm... what does this script do?

pg = str2num(get(e6,'string'));
cnms = (1:4) + (pg-1)*4;

set(t1,'string',['Class ' num2str(cnms(1))])
set(t2,'string',['Class ' num2str(cnms(2))])
set(t3,'string',['Class ' num2str(cnms(3))])
set(t4,'string',['Class ' num2str(cnms(4))])

% if ONEFILE
    set(b14,'callback',['saveundo,','spk{' num2str(cnms(1)) ',1}=[];','subplot(h2),','cla reset'])
    set(b16,'callback',['saveundo,','spk{' num2str(cnms(2)) ',1}=[];','subplot(h3),','cla reset'])
    set(b18,'callback',['saveundo,','spk{' num2str(cnms(3)) ',1}=[];','subplot(h4),','cla reset'])
    set(b20,'callback',['saveundo,','spk{' num2str(cnms(4)) ',1}=[];','subplot(h5),','cla reset'])
% else
%    set(b14,'callback',['saveundo,','spk{' num2str(cnms(1)) ',1}=[];','spk{' num2str(cnms(1)) ',2}=[];','subplot(h2),','cla reset'])
%    set(b16,'callback',['saveundo,','spk{' num2str(cnms(2)) ',1}=[];','spk{' num2str(cnms(1)) ',2}=[];','subplot(h3),','cla reset'])
%    set(b18,'callback',['saveundo,','spk{' num2str(cnms(3)) ',1}=[];','spk{' num2str(cnms(1)) ',2}=[];','subplot(h4),','cla reset'])
%    set(b20,'callback',['saveundo,','spk{' num2str(cnms(4)) ',1}=[];','spk{' num2str(cnms(1)) ',2}=[];','subplot(h5),','cla reset']) 
% end
% 
figure(spkfig)
for abc = 1:4,
 
 sbp = ['h' num2str(abc+1)];
 eval(['subplot(' sbp ')'])
 
 tempf1 = spiketemp(:,find(ismember(st,spk{cnms(abc),1})));
 if ONEFILE
      if ~isempty(tempf1) ,
           plot(ts,tempf1(:,1:min(nspk,size(tempf1,2))))
           [clha,clhb] = legend(num2str(size(tempf1,2)),4);
           if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
                 eval(['set(' sbp ',''ylim'',yaxis)'])
                eval(['set(' sbp ',''xlim'',xaxis)'])
        else,
                 cla reset
        end
        
   else
       tempf2 = spiketemp2(:,find(ismember(st2,spk{cnms(abc),2})));
       if ~isempty(tempf1),plot(ts,tempf1(:,1:min(nspk,size(tempf1,2)))), hold on,end
       if ~isempty(tempf2)
           plot(ts,tempf2(:,1:min(nspk,size(tempf2,2)))) 
           hold off
       end
       %if ~isempty(tempf1) & ~isempty(tempf2)
           [clha,clhb] = legend(['1st: ' num2str(size(tempf1,2)) '         2nd: ' num2str(size(tempf2,2))], 4);
       %end
       if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
            eval(['set(' sbp ',''ylim'',yaxis)'])
            eval(['set(' sbp ',''xlim'',xaxis)'])
       if isempty(tempf1) & isempty(tempf2)
            cla reset
       end
       
 end
clear tempf1 tempf2;
end
  
 

