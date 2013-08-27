% function dms_ag(siteid);
%
% audiogram analysis.
%
% extended dms behavior analysis
%
function dms_ag(siteid);

sql=['SELECT * FROM gDataRaw WHERE cellid="',siteid,'" AND not(bad)'];
sitedata=mysql(sql);

% assume current version of dms
bstatidx=1;

resptime=[];
triallen=[];
targatten=[];
target_id=[];
berror=[];

for fileidx=1:length(sitedata),
    mfile=[sitedata(fileidx).resppath,sitedata(fileidx).respfile];
    fprintf('file %d: %s\n',fileidx,mfile);
    clear exptparams exptevents globalparams
    LoadMFile(mfile);
    tonecount=length(exptparams.freqs);
    count=length(exptparams.bstat);

    t_resptime=zeros(count,1);
    t_triallen=zeros(count,1);
    t_targatten=zeros(count,1);
    t_target_id=zeros(count,1);
    
    targlatency=exptparams.res(:,1);
    targlat2=targlatency;
    t_berror=exptparams.res(:,2);
    tstring=exptparams.tstring;
    altoutcomes=zeros(count,tonecount+1);
    altmaybes=zeros(count,tonecount+1);
    for trialidx=1:count,
        targidx=exptparams.res(trialidx,5);
        t_target_id(trialidx)=targidx;

        tt0=evtimes(exptevents,'TRIALSTART',trialidx);
        ttarg=evtimes(exptevents,['STIM,',tstring{targidx},'*'],trialidx)-tt0;
        [ttones,ttr,tnames]=evtimes(exptevents,['STIM*'],trialidx);
        ttones=ttones-tt0;

        if length(ttarg)==length(ttones),
            cuetrial=1;
        else
            cuetrial=0;
        end

        if length(ttarg)>0,
            targlat2(trialidx)=ttarg(end)-ttones(1);
        end

        if length(ttones)>0,
            firsttargbin=round(ttones(1).*exptparams.bfs);

            touch=exptparams.bstat{trialidx}(firsttargbin:end,bstatidx);

            releasebin=min(find(diff(touch)>0));
            if isempty(releasebin) & (touch(1)==1 | t_berror(trialidx)<=1),
                releasebin=0;
            elseif isempty(releasebin),
                releasebin=inf;
            end
        else
            releasebin=-inf;
        end
        t_resptime(trialidx)=releasebin./exptparams.bfs;
        t_triallen(trialidx)=size(exptparams.bstat{trialidx},1)./exptparams.bfs;

        if ~cuetrial,
            reltime=releasebin./exptparams.bfs;
            for ii=1:length(ttones),
                if ttones(ii)-ttones(1)>=exptparams.nolick,
                    ttn=strsep(tnames{ii},',');

                    tt=ttn{2};
                    tt=double(tt(1))-'A'+1;

                    if tt==targidx,
                        ta=strsep(ttn{3},'-');
                        t_targatten(trialidx)=ta{2};
                    end

                    altmaybes(trialidx,tt)=1;
                    if reltime-ttones(ii)+ttones(1)>exptparams.startwin & ...
                            reltime-ttones(ii)+ttones(1)<=exptparams.startwin+exptparams.respwin;
                        % would've been correct response if this tone were the target
                        altoutcomes(trialidx,tt)=1;
                    end
                end
            end

            if max(ttones)-ttones(1)>exptparams.nolick,
                altmaybes(trialidx,end)=1;
                if reltime>exptparams.nolick+exptparams.nolickstd-exptparams.respwin/2 & ...
                        reltime<=exptparams.nolick+exptparams.nolickstd+exptparams.respwin/2,
                    altoutcomes(trialidx,end)=1;
                end
            end
        end
    end
    
    resptime=cat(1,resptime,t_resptime);
    triallen=cat(1,triallen,t_triallen);
    targatten=cat(1,targatten,t_targatten);
    target_id=cat(1,target_id,t_target_id);
    berror=cat(1,berror,t_berror);
   
end



% display matrix
%  sortrows([target_id targatten berror])

% only want berror==0 (hit) or berror==2 (miss)
% early release is uninformative

figure
clf
trange=unique(target_id);
arange=5:4:55;
windowsize=20;
pcol={'r','b','k','g','c','r--','b--','k--','g--','c--','r:','b:','k:','g:','c:'};
ltext={};
for ii=1:length(trange),
    adata=zeros(size(arange));
    for aa=1:length(arange),
        ff=find(target_id==trange(ii) & ismember(berror,[0 2]) .* ...
            (targatten<=(arange(aa)+windowsize/2)).*...
            (targatten>=(arange(aa)-windowsize/2)));
        adata(aa)=mean(1-berror(ff)./2);
    end
    %adata=adata./mean(adata(1:4));
    plot(arange,adata,pcol{trange(ii)});
    ltext{ii}=num2str(exptparams.freqs(trange(ii)));
    hold on
end
hold off

legend(ltext);
xlabel('attenuation (dB)');
ylabel('fraction detected');
ht=title(['audiogram for site ',siteid]);
set(ht,'Interpreter','none');

disp('done dms_ag');

