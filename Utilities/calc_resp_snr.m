function [snr,z,tau,reps]=calc_resp_snr(spkfile,options);

if 0,
    cellid='oni007a-a2';
    sql=['SELECT * FROM sCellFile WHERE runclassid=4',...
         ' AND cellid="',cellid,'"'];
    sql=['SELECT * FROM sCellFile',...
         ' WHERE repcount>10 and area="A1" and runclassid=4',...
         ' AND not(cellid like "j0%")'];
    sql=['SELECT * FROM sCellFile',...
         ' WHERE runclassid=4',...
         ' AND not(cellid like "j0%")'];
    runclassidstr='4,8,35,112'; %112; % 35 or 4
    sql=['SELECT * FROM sCellFile',...
         ' WHERE runclassid in (', runclassidstr, ')' ,...
         ' AND not(cellid like "j0%") AND not(cellid like "m0%")'];
    dbopen;
    vocdata=mysql(sql);
    FORCERELOAD=0;
    for ii=1:length(vocdata),
        fprintf('%d:\n',ii);
        if vocdata(ii).respSNR==0 || FORCERELOAD,
            spkfile=[vocdata(ii).path vocdata(ii).respfile];
            options=struct('channel',vocdata(ii).channum,...
                           'unit',vocdata(ii).unit,...
                           'rasterfs',25);
            trialrange=eval(['[' vocdata(ii).goodtrials ']']);
            if ~isempty(trialrange),
                options.trialrange=trialrange;
            end
            
            [snr,z,tau,reps]=calc_resp_snr(spkfile,options);
        end
    end
end
dbopen;

bb=basename(spkfile);
options.channel=getparm(options,'channel',1);
options.unit=getparm(options,'unit',1);
options.rasterfs=getparm(options,'rasterfs',100);
options.verbose=getparm(options,'verbose',0);
% don't include prestim silence b/c we want to test for selectivity
options.includeprestim=getparm(options,'includeprestim',0);;

rasterfs=options.rasterfs;

sql=['SELECT * FROM sCellFile where respfile="',bb,'"',...
     ' AND channum=',num2str(options.channel),...
     ' AND unit=',num2str(options.unit)];

cfd=mysql(sql);
if isempty(cfd),
    error('entry not found in sCellFile');
end
rawid=cfd(1).rawid;
cellid=cfd(1).cellid;

%parms=dbReadData(rawid);

%PreStimBins=round(rasterfs.*parms.Ref_PreStimSilence);
%PostStimBins=round(rasterfs.*parms.Ref_PostStimSilence);


[r,tags,trialset]=loadspikeraster(spkfile,options);

reps_per_stim=squeeze(sum(~isnan(r(1,:,:)),2));
nonzeroreps=find(reps_per_stim>0);
r=r(:,:,nonzeroreps);

reps_per_stim=squeeze(sum(~isnan(r(1,:,:)),2));
min_reps_per_stim=min(reps_per_stim);
r=r(:,1:min_reps_per_stim,:);

snr=0;
reps=min_reps_per_stim;
z=0;
tau=0;
if min_reps_per_stim<2,
    fprintf('%s/%s: less than two reps. cancelling.\n',cellid,spkfile);
    return
end

reps_per_stim=squeeze(sum(~isnan(r(1,:,:)),2));
stimidx=find(reps_per_stim==max(reps_per_stim));
stimcount=length(stimidx);
fprintf('stimcount=%d\n',stimcount);
rxc=r(:,:,stimidx);
%trialsetxc=trialset(:,stimidx);
nn=sum(isnan(rxc(:,:)),2);
mnn=max(find(nn==0));
if mnn<size(rxc,1),
    fprintf('truncating at bin %d to correct for variable-len trials\n',mnn);
    rxc=rxc(1:mnn,:,:);
end

if options.verbose,
    sfigure(1);
    plot((1:size(r,1))./rasterfs,squeeze(nanmean(r,2)));
    hold on
    plot((1:size(r,1))./rasterfs,nanmean(nanmean(r,2),3),'k','LineWidth',2);
    hold off
    title(bb,'Interpreter','none');
end

trialcount=max(trialset(:));
repcount=size(r,2);

mr=round(repcount./2);

if 1,
    rxc=rxc-mean(rxc(:));
    %for kk=1:size(rxc,3),
    %   rxc(:,:,kk)=rxc(:,:,kk)-mean(mean(rxc(:,:,kk)));
       %for jj=1:size(rxc,2),
          %rxc(:,jj,kk)=rxc(:,jj,kk)-mean(rxc(:,jj,kk));
       %   if std(rxc(:,jj,kk))>0,
             %rxc(:,jj,kk)=rxc(:,jj,kk)./ std(rxc(:,jj,kk));
       %   end
    %   end
    %end
    % use xc across / (axc-xc across)
    s11=zeros(size(rxc,2)*size(rxc,3),1);
    s12=zeros(size(rxc,2)*size(rxc,3),1);
    e11=zeros(size(rxc,2)*size(rxc,3),1);
    e12=zeros(size(rxc,2)*size(rxc,3),1);
    xcin=zeros(size(rxc,2)*size(rxc,3),1);
    xcout=zeros(size(rxc,2)*size(rxc,3),1);
    cc=0;
    osj=floor(size(rxc,2)./2);
    osk=floor(size(rxc,3)./2);
    for kk=1:size(rxc,3),
       for jj=1:size(rxc,2),
          cc=cc+1;
          jj0=mod(jj+osj-1,size(rxc,2))+1;
          kk0=mod(jj+osk-1,size(rxc,3))+1;
          
          s11(cc)=(rxc(:,jj,kk)'*rxc(:,jj,kk)+rxc(:,jj0,kk)'*rxc(:,jj0,kk))./2;
          s12(cc)=rxc(:,jj,kk)'*rxc(:,jj0,kk);
          %sin(cc)=s12./(s11-s12);
          xcin(cc)=s12(cc);
          xcout(cc)=rxc(:,jj,kk)'*rxc(:,jj,kk0);
       end
    end
    snr=mean(s12)./(mean(s11-s12));
    %sin=s12./(s11-s12);
    %sin(isinf(sin))=10;
    %snr=nanmean(sin);
    %snr=mean(e11-e12)./mean(e12);
    %snr=sqrt(abs(snr)).*sign(snr);
    
    %if snr==0, snr=nanmean(sin); end
    if max(xcin)==0,
       z=0;
    elseif max(xcout)==0
       z=20;
    else
       z=mean(xcin)./mean(xcout);
    end
    %if isinf(z), z=20; end
    tauidx=1;
    fprintf('saving to db for cell %s/rawid %d: snr=%.3f Z=%.3f\n',...
            cfd.cellid,rawid,snr,z);
    %keyboard
elseif 1,
    % use xc
    [mXC,eXC]=spike_train_similarity(rxc(:,:,:),1);
    snr=mXC(1);
    if eXC(1)>0,
        z=mXC(1)./eXC(1);
    else
        z=0;
    end
    tauidx=1;
    fprintf('saving to db for cell %s/rawid %d: snr=%.3f Z=%.3f\n',...
            cfd.cellid,rawid,snr,z);
else
    
    % use MSE
    [mME,eME,tau]=spike_distance(rxc(:,:,:),rasterfs);
    snr=(mME(2,:)-mME(1,:))./mME(2,:);
    z=(mME(2,:)-mME(1,:))./sqrt(mean(eME.^2,1));
    tauidx=4;
    if isnan(z(tauidx)),z(:)=0; end
    fprintf('saving to db for cell %s/rawid %d: (tau=%.1f) snr=%.3f Z=%.3f\n',...
            cfd.cellid,rawid,tau(tauidx),snr(tauidx),z(tauidx));
end

sql=['UPDATE sCellFile set repcount=',num2str(reps),',',...
     ' respSNR=',num2str(snr(tauidx),3),',',...
     ' respZ=',num2str(z(tauidx),3),...
     ' WHERE id=',num2str(cfd(1).id)];
mysql(sql);

