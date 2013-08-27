saveundo

% cnm set in callback
pg = str2num(get(e6,'string'));
sbp = ['h' num2str(mod(cnm-1,4)+2)];
cnms = (1:4) + (pg-1)*4;

if ~exist('TO'), TO = 0;end, if ~exist('FROM'), FROM = 0;end

if TO,

%  spk{cnm,1} = union(spk{cnm,1},St);
%  spk{cnm,2} = union(spk{cnm,2},St2);
%  
%  if ~isempty(find(cnms==cnm)),
%   eval(['subplot(' sbp ')'])
%   % Concatinate spike times and waveforms of both files inorder to select the ones to be displayed in class figures
%   % stcat=[st;st2];
%   
%   % spikecat= [spiketemp';spiketemp2']';
%   temps = spiketemp(:,find(ismember(st,spk{cnm,1})));
%   temps2= spiketemp2(:,find(ismember(st2,spk{cnm,2})));
%   if ~isempty(temps) | ~isempty(temps2), 
%    plot(ts,temps(:,1:min(nspk,size(temps,2)))) % why plotting temp as opposed to spk{cnm}??? because temp is the waveform and spk{cnm} has the spike times
%    hold on 
%    plot (ts,temps2(:,1:min(nspk,size(temps2,2))))
%    
%    
% %    plot(ts,temps(:,1:min(nspk,size(temps,2))),'r') % why plotting temp as opposed to spk{cnm}??? because temp is the waveform and spk{cnm} has the spike times
% %    hold on 
% %    plot (ts,temps2(:,1:min(nspk,size(temps2,2))),'y')
%    
%    
% %    [clha,clhb] = legend(['1st  ' num2str(size(temps,2))],['2nd  ' num2str(size(temps2,2))], 4);
%    [clha,clhb] = legend(['1st: ' num2str(size(temps,2)) '         2nd: ' num2str(size(temps2,2))], 4);
%    if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
%    eval(['set(' sbp ',''ylim'',yaxis)'])
%    eval(['set(' sbp ',''xlim'',xaxis)'])
%   else, 
%    cla reset,
%   end
%  end
%  if DEL, %Set DEL in callback (get(c1,'value') or menu)
%   Ws = Ws(:,find(~ismember(Wt,St)));
%   Wt = setdiff(Wt,St);
%   St = Wt; Ss = Ws; hood = 0;
%   
%   Ws2 = Ws2(:,find(~ismember(Wt2,St2)));
%   Wt2 = setdiff(Wt2,St2);
%   St2 = Wt2; Ss2 = Ws2; hood2 = 0; meska
%  end
%  TO = 0;
spk{cnm,1} = union(spk{cnm,1},St);
 if ~ONEFILE, spk{cnm,2} = union(spk{cnm,2},St2); end

  if ONEFILE
       if ~isempty(find(cnms==cnm)),
        eval(['subplot(' sbp ')'])
        temps = spiketemp(:,find(ismember(st,spk{cnm,1})));
        if ~isempty(temps)
              plot(ts,temps(:,1:min(nspk,size(temps,2))))
             [clha,clhb] = legend(num2str(size(temps,2)),4);
             if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end 
              eval(['set(' sbp ',''ylim'',yaxis)']) 
              eval(['set(' sbp ',''xlim'',xaxis)'])
         else
            cla reset,
        end      
      end
      if DEL, %Set DEL in callback (get(c1,'value') or menu)
          Ws = Ws(:,find(~ismember(Wt,St)));
          Wt = setdiff(Wt,St);
          St = Wt; Ss = Ws; hood = 0;meska
      end
  else 
      if ~isempty(find(cnms==cnm)),
        eval(['subplot(' sbp ')'])
        temps2= spiketemp2(:,find(ismember(st2,spk{cnm,2}))); 
        temps = spiketemp(:,find(ismember(st,spk{cnm,1})));
          if ~isempty(temps) 
              plot(ts,temps(:,1:min(nspk,size(temps,2)))) % why plotting temp as opposed to spk{cnm}??? because temp is the waveform and spk{cnm} has the spike times
              if ~isempty(temps2)
                  hold on 
                  plot (ts,temps2(:,1:min(nspk,size(temps2,2))))
                  hold off
              end
                      
              [clha,clhb] = legend(['1st: ' num2str(size(temps,2)) '         2nd: ' num2str(size(temps2,2))], 4);
              if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
              eval(['set(' sbp ',''ylim'',yaxis)'])
              eval(['set(' sbp ',''xlim'',xaxis)'])
              
          elseif ~isempty(temps2)
              plot (ts,temps2(:,1:min(nspk,size(temps2,2))))
              [clha,clhb] = legend(['1st: ' num2str(size(temps,2)) '         2nd: ' num2str(size(temps2,2))], 4);
              if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
              eval(['set(' sbp ',''ylim'',yaxis)'])
              eval(['set(' sbp ',''xlim'',xaxis)'])
          else, 
              cla reset,
          end
      end
      if DEL, %Set DEL in callback (get(c1,'value') or menu)
          Ws = Ws(:,find(~ismember(Wt,St)));
          Wt = setdiff(Wt,St);
          St = Wt; Ss = Ws; hood = 0;
          
          Ws2 = Ws2(:,find(~ismember(Wt2,St2)));
          Wt2 = setdiff(Wt2,St2);
          St2 = Wt2; Ss2 = Ws2; hood2 = 0; meska
      end
  end
 TO = 0;
elseif FROM,
%  % seperate class spikes into the ones corresponding to the two different files
%  spksub1=intersect(spk{cnm,1},st);
%  spksub2=intersect(spk{cnm,2},st2);
%  
%  Wt = union(Wt,spk{cnm,1});
%  Ws = spiketemp(:,find(ismember(st,Wt)));
%  St = Wt; Ss = Ws;
%  hood=0;
%  
%  Wt2 = union(Wt2,spk{cnm,2});
%  Ws2 = spiketemp2(:,find(ismember(st2,Wt2)));
%  St2 = Wt2; Ss2 = Ws2;
%  hood2 = 0; meska
%  
% % Old justin code
% %  Wt = union(Wt,spk{cnm});
% %  Ws = spiketemp(:,find(ismember(st,Wt)));
% %  St = Wt; Ss = Ws; hood = 0; meska
%  if DEL,
%   spk{cnm,1} = [];
%   spk{cnm,2} = [];
%   if ~isempty(find(cnms==cnm)),
%    eval(['subplot(' sbp ')'])
%    cla reset
%   end
%  end
%  FROM = 0;
% seperate class spikes into the ones corresponding to the two different files
 spksub1=intersect(spk{cnm,1},st);
 Wt = union(Wt,spk{cnm,1});
 Ws = spiketemp(:,find(ismember(st,Wt)));
 St = Wt; Ss = Ws;
 hood=0;
 
 if ~ONEFILE
     spksub2=intersect(spk{cnm,2},st2);
     Wt2 = union(Wt2,spk{cnm,2});
     Ws2 = spiketemp2(:,find(ismember(st2,Wt2)));
     St2 = Wt2; Ss2 = Ws2;
     hood2 = 0; 
 end
 
 meska
 
if DEL,
  spk{cnm,1} = [];
  if ~ONEFILE, spk{cnm,2} = []; end;
  if ~isempty(find(cnms==cnm)),
   eval(['subplot(' sbp ')'])
   cla reset
  end
 end

 FROM = 0;

elseif RMC,

%  Ws = Ws(:,find(~ismember(Wt,spk{cnm,1})));
%  Wt = setdiff(Wt,spk{cnm,1});
%  St = Wt; Ss = Ws; 
%  hood = 0
%  
%  Ws2 = Ws2(:,find(~ismember(Wt2,spk{cnm,2})));
%  Wt2 = setdiff(Wt2,spk{cnm,2});
%  St2 = Wt2; Ss2 = Ws2; 
%  
%  hood2 = 0; meska
%  
%  RMC = 0;
 Ws = Ws(:,find(~ismember(Wt,spk{cnm,1})));
 Wt = setdiff(Wt,spk{cnm,1});
 St = Wt; Ss = Ws; 
 hood = 0
 
 if ~ONEFILE
     Ws2 = Ws2(:,find(~ismember(Wt2,spk{cnm,2})));
     Wt2 = setdiff(Wt2,spk{cnm,2});
     St2 = Wt2; Ss2 = Ws2; 
     hood2 = 0;
 end
  
  meska
  RMC = 0;
  
elseif RMW,   

%  spk{cnm,1} = union(setdiff(spk{cnm,1},St));
%  spk{cnm,2} = union(setdiff(spk{cnm,2},St2));
%  if ~isempty(find(cnms==cnm)),
%   eval(['subplot(' sbp ')'])
% %  Concatinate spike times and waveforms of both files inorder to select the ones to be displayed in class figures
% %   stcat= [st;st2];
% %   spikecat= [spiketemp';spiketemp2']';
% %   temp = spikecat(:,find(ismember(stcat,spk{cnm})));
%   temps = spiketemp(:,find(ismember(st,spk{cnm,1})));
%   temps2= spiketemp2(:,find(ismember(st,spk{cnm,2})));
%   if ~isempty(temps) | ~isempty(temps2), 
% %   if ~isempty(temp),
%    plot(ts,temps(:,1:min(nspk,size(temps,2))));
%    hold on
%    plot(ts, temps2(:,1:min(nspk,size(temps,2))));
% %    [clha,clhb] = legend(num2str(size(temps,2)+size(temps2,2)),4);
%    [clha,clhb] = legend(['1st  ' num2str(size(temps,2))],['2nd  ' num2str(size(temps2,2))],4);
%    if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
%    eval(['set(' sbp ',''ylim'',yaxis)'])
%    eval(['set(' sbp ',''xlim'',xaxis)'])
%   else, 
%    cla reset
%   end
%  end 
%  RMW = 0;
 spk{cnm,1} = union(setdiff(spk{cnm,1},St));
 
 if ~ONEFILE spk{cnm,2} = union(setdiff(spk{cnm,2},St2)); end
 
 if ~isempty(find(cnms==cnm)),
  eval(['subplot(' sbp ')'])
  if ONEFILE 
    temps = spiketemp(:,find(ismember(st,spk{cnm,1})));
     if ~isempty(temp),
        plot(ts,temps(:,1:min(nspk,size(temps,2))));
        [clha,clhb] = legend(num2str(size(temps,2)),4);
         if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
        eval(['set(' sbp ',''ylim'',yaxis)'])
        eval(['set(' sbp ',''xlim'',xaxis)'])
    else, 
        cla reset
    end
    
else
    temps2= spiketemp2(:,find(ismember(st,spk{cnm,2})));
    if ~isempty(temps) | ~isempty(temps2), 
        plot(ts,temps(:,1:min(nspk,size(temps,2))));
        hold on
        plot(ts, temps2(:,1:min(nspk,size(temps,2))));
        [clha,clhb] = legend(['1st  ' num2str(size(temps,2))],['2nd  ' num2str(size(temps2,2))],4);
        if ~isempty(clha), set(clha,'xcolor',[1 1 1],'ycolor',[1 1 1]), delete(clhb(2)), end
        eval(['set(' sbp ',''ylim'',yaxis)'])
        eval(['set(' sbp ',''xlim'',xaxis)'])
    else, 
        cla reset
    end
end
  
end 
 RMW = 0;

end
