% function dms_site_sum(siteid,fmt,useidx)
%
% fmt is 'rt' (default) or 'ttl'
%
function dms_site_sum(siteid,fmt,useidx)

if ~exist('fmt','var'),
   fmt='rt';
end

dbopen;

sql=['SELECT * FROM gDataRaw WHERE cellid="',siteid,'" AND not(bad)' ...
     ' ORDER BY id,respfile,parmfile'];
sitedata=mysql(sql);

if length(sitedata)==0,
   disp('no files for this site.');
   return
end

if ~exist('useidx','var'),
   useidx=1:length(sitedata);
end
for ii=useidx,
    mfile=[sitedata(ii).resppath,sitedata(ii).parmfile];
    fprintf('%d. %s\n',ii,mfile);
    tlickdata=dms_count_licks(mfile);
    
    if ii==useidx(1),
       lickdata=tlickdata;
    else
       lickdata.tonetriglick=lickdata.tonetriglick+tlickdata.tonetriglick;
       lickdata.ttlcount=lickdata.ttlcount+tlickdata.ttlcount;
       lickdata.rt=lickdata.rt+tlickdata.rt;
       lickdata.rtcount=lickdata.rtcount+tlickdata.rtcount;
       lickdata.count=lickdata.count+tlickdata.count;
    end
end

figure
pcol={'r','b','k','g','c','r--','b--','k--','g--','c--','r:','b:','k:','g:','c:'};

switch fmt,
   
 case 'ttl',
  tonecount=size(lickdata.tonetriglick,2);
  ttcount=0;
  for jj=1:length(lickdata.targset),
     subplot(length(lickdata.targset)+1,1,jj);
     if sum(sum(lickdata.ttlcount(:,:,jj)))>0,
        flabels={};
        for ii=1:min([tonecount length(pcol)]),
           
           hp=plot(lickdata.ttltime,...
                   smooth(lickdata.tonetriglick(:,ii,jj)./...
                          (lickdata.ttlcount(:,ii,jj)+...
                           (lickdata.ttlcount(:,ii,jj)==0)),3),pcol{ii});
           if lickdata.targset(jj)==ii,
              set(hp,'LineWidth',1.5);
           end
           hold on
           
           xp=max(lickdata.ttltime)+0.1+(ii-1)./tonecount.*0.5;
           plot([xp xp],[0.3 1.1],pcol{ii});
           if ii==1 | ii==round(tonecount/3) | ii==round(tonecount*2/3) | ii==tonecount,
              ht=text(xp,0.25,lickdata.flabels{ii});
              set(ht,'HorizontalAlignment','right','Rotation',90);
           end
        end
        hold off
        axis([0 max(lickdata.ttltime)+0.6 -0.1 1.1]);
        ylabel(['targ=',lickdata.flabels{lickdata.targset(jj)}]);
        %legend(flabels);
        
         
     end
     if jj==1 & exist('mfile','var'),
        ht=title(sprintf('%s: lickrate (%d trials)',siteid,lickdata.count));
        set(ht,'Interpreter','none');
     end
  end
  subplot(length(lickdata.targset)+1,1,length(lickdata.targset)+1);
  for ii=1:length(lickdata.targset),
     targidx=lickdata.targset(ii);
     hp=plot(lickdata.ttltime,...
             smooth(lickdata.tonetriglick(:,targidx,ii)./...
                    (lickdata.ttlcount(:,targidx,ii)+...
                     (lickdata.ttlcount(:,targidx,ii)==0)),3),...
             pcol{targidx});
     set(hp,'LineWidth',1.5);
     hold on
  end
  targidx=lickdata.targset(1);
  xtargidx=[1:(targidx-1) (targidx+1):size(lickdata.ttlcount,2)];
  meanlick=sum(lickdata.tonetriglick(:,xtargidx,1),2)./...
           sum(lickdata.ttlcount(:,:,1),2);
  hp=plot(lickdata.ttltime,smooth(meanlick,3),'k--');
  
  hold off
  xlabel('time after tone (s)');
  
 case 'rt',
  
  for jj=1:length(lickdata.targset),
     subplot(length(lickdata.targset),1,jj);
     
     plot(lickdata.rttime,[lickdata.rt(:,1:2,jj)]);
     title(sprintf('%s: target %s Hz (%d trials)',...
                   siteid,lickdata.flabels{lickdata.targset(jj)},...
                   lickdata.rtcount(jj)));
     xlabel('time after target/trial (s)');
     ylabel('count');
  end
  legend('resp after target','after trial start');
end

  
