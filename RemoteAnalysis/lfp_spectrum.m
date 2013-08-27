% function results=lfp_spectrum(mfile,channel,h,tag_masks,fs[=200]);
% 
% h - handle of figure where plot should be displayed(default, new figure)
%
% returns:
% results.spect = freq X file matrix ... spectrum for each file;
%   .freq = frequency associrated with each entry in results.spect
%   .r= raw lfp data (time X rep X stimulus)
%   .tags = label for each different stimulus in r. ie, same length as size(r,3)
%
function results=lfp_spectrum(mfile,channel,h,tag_masks,rasterfs);

if ~exist('channel','var'),
    channel=1;
end
if ~exist('tag_masks','var'),
    tag_masks={'Reference','TORC'}
end
if ~exist('rasterfs','var'),
    rasterfs=400;
end

if iscell(mfile) && ...
        (~isempty(strfind(mfile{1},'DMS')) || ~isempty(strfind(mfile{2},'DMS'))),
   % use for DMS:
   DMSset=1;
   PreStimSilence=0.25;
   PostStimSilence=0.3;
   UseDur=0.5;
else
   DMSset=0;
   PreStimSilence=0.4;
   PostStimSilence=0.4;
   UseDur=1;
end

fprintf('Analyzing channel %d (fs=%d)\n',channel,rasterfs);

if ~iscell(mfile),
    mfile={mfile};
end
mfilecount=length(mfile);

lcol={'--','-','-.'};
scol={'b','g','r'};
fns=mfile;
rout=cell(mfilecount,1);
sout=cell(mfilecount,1);
rspect=[];
rspecterr=[];
for midx=1:mfilecount,
    
    LoadMFile(mfile{midx});
    includeprestim=[PreStimSilence PostStimSilence];
    
    disp('Loading LFP...');
    
    %figure out if there's behavior in this data set
    rbad=[];
    if 0 & isfield(exptparams,'BehaveObjectClass') & strcmp(exptparams.BehaveObjectClass,'PunishTarget'),
        pmat=[cat(1,exptparams.Performance(1:end-1).Hit) cat(1,exptparams.Performance(1:end-1).Sham)];
        goodtrials=find(sum(pmat,2)>0)';
        badtrials=find(sum(pmat,2)==0)';
        fprintf('%d "good" trials, %d "bad" trials\n',length(goodtrials),length(badtrials));
        if isempty(rout{midx}),
            [r, tags]=loadevpraster(mfile{midx},channel,rasterfs,4,1,tag_masks,1,goodtrials);
            [rbad, tags]=loadevpraster(mfile{midx},channel,rasterfs,4,1,tag_masks,1,badtrials);
        else
            r=rout{midx};
        end
    else
        tic;
        if isempty(rout{midx}),
            [r, tags]=loadevpraster(mfile{midx},channel,rasterfs,4,includeprestim,tag_masks,1);
            
            if DMSset, %isfield(exptparams,'refstd') && exptparams.refstd>0,
               StimDur=UseDur;
               postbins=floor(PostStimSilence.*rasterfs);
               keepbins=[1:round((PreStimSilence+StimDur).*rasterfs) ...
                         size(r,1)+((-postbins+1):0)];
               for ii=1:size(r(:,:),2),
                  tr=r(:,ii);
                  lastbin=max(find(~isnan(tr)));
                  if ~isempty(lastbin),
                     tr((end-postbins+1):end)=tr((lastbin-postbins+1):lastbin);
                     tr((lastbin-postbins+1):(end-postbins))=nan;
                     r(:,ii)=tr;
                  end
               end
               r=r(keepbins,:,:);
            end
        else
            r=rout{midx};
        end
        toc
    end
    
    if isempty(r),
        return
    end
    tic;
    disp('Computing spectrum...');
    
    if length(includeprestim)<=1,
       [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PreStim*'],1);
       % currently doesn't execute because used fixed Pre- and PostStimSilence
       if length(eventtime)>0,
          PreStimSilence=eventtimeoff(1)-eventtime(1);
          [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PostStim*'],1);
          PostStimSilence=eventtimeoff(1)-eventtime(1);
       else
          PreStimSilence=0.4;
          PostStimSilence=0.8;
       end
    end
    StimDur=size(r,1)./rasterfs-PreStimSilence-PostStimSilence;
    
    starttime=PreStimSilence; %0.25;
    stoptime=UseDur+PreStimSilence; % 1.25;
    ss=round(starttime.*rasterfs)+1;
    ee=round(stoptime.*rasterfs);
    fprintf('PreStimSilence: %.2f  StimDur: %.2f  PostStimSilence: %.2f\n',...
            PreStimSilence, StimDur, PostStimSilence);
    
    fprintf('restricting spectrum to %.2f - %.2f sec window after stim onset\n',...
        ss/rasterfs-PreStimSilence,ee/rasterfs-PreStimSilence);
    
    if ~exist('h','var') | isempty(h),
        h=figure;
    else
        sfigure(h);
    end
    if midx==1,
        clf;
    end
    
    subplot(3,1,1);
    %plot((1:length(r))./rasterfs,r(:,:));
    hold on
    %plot((1:(ee+rasterfs.*0.5))./rasterfs,...
    %     nanmean(r(1:(ee+rasterfs.*0.5),:)'),lcol{midx});
    %keyboard
    plot((1:size(r,1))./rasterfs-PreStimSilence,...
         squeeze(nanmean(r(:,:,:),2)),lcol{midx});
    if midx==mfilecount,
        plot([ss ss]./rasterfs-PreStimSilence,[min(nanmean(r(:,:)')) max(nanmean(r(:,:)'))],'k--');
        plot([ee ee]./rasterfs-PreStimSilence,[min(nanmean(r(:,:)')) max(nanmean(r(:,:)'))],'k--');
        plot(PreStimSilence,[min(nanmean(r(:,:)')) max(nanmean(r(:,:)'))],'b--');
    end
    hold off
    xlabel('time (sec)');
    ylabel('avg LFP');
    
    subplot(3,1,2);
    
    for jj=1:size(r,3),
       tr=r(ss:ee,:,jj);
       tr=tr(:,sum(isnan(tr))==0);
       
       params.Fs=rasterfs;
       params.err=[1 0.01];
       params.trialave=1;
       [fr,ll,fre]=mtspectrumc(tr,params);
       if ~isempty(rbad),
          trbad=rbad(ss:ee,:);
          trbad=trbad(:,sum(isnan(trbad))==0);
          frbad=mtspectrumc(trbad,params);
       end
       
       ff=min(find(ll>=0));
       if jj==1,
          if midx>1,
             hold on
          end
          semilogy(ll(ff:end),(fr(ff:end)),scol{midx},'LineWidth',1.5);
          hold on
          if ~isempty(rbad),
             semilogy(ll(ff:end),(frbad(ff:end)),['r' lcol{midx}]);
          end
          semilogy(ll(ff:end),fre(:,ff:end)','k:');
          hold off
          xlabel('temporal frequency (Hz)');
          ylabel('power');
       end
       
       fns{midx}=basename(fns{midx});
       rout{midx}=r;
       rspect(:,jj,midx)=fr;
       rspecterr(:,jj*2+(-1:0),midx)=fre';
       rfreq=ll;
       
       repcount=size(r,2);
       stimcount=size(r,3);
       
       tr=r(:,sum(isnan(r(:,:,jj)))==0,jj);
       
       if 1,
          samplecount=size(tr,2);
          for repidx=1:samplecount,
             [tss,tff,ttt]=specgram(tr(:,repidx),rasterfs./8,rasterfs,...
                                    rasterfs./8,round(rasterfs./8)-10);
             if repidx==1,
                tsg=abs(tss)./samplecount;
             elseif ~isnan(tss(1)),
                tsg=tsg+abs(tss)./samplecount;
             end
          end
          size(tsg)
          sout{midx}(:,:,jj)=tsg;
       else
          
          samplecount=sum(sum(isnan(r(:,:)),1)==0);
          for repidx=1:repcount,
             for stimidx=1:stimcount,
                [tss,tff,ttt]=specgram(r(ss:ee,repidx,stimidx),rasterfs./8,rasterfs,rasterfs./8,rasterfs./8-5);
                %[tss,tff,ttt]=specgram(r(1:(ee+rasterfs.*0.5),repidx,stimidx),rasterfs./8,rasterfs,rasterfs./8,rasterfs./8-5);
                if isempty(sout{midx}) & ~isnan(tss(1)),
                   sout{midx}=abs(tss)./samplecount;
                elseif ~isnan(tss(1)),
                   sout{midx}=sout{midx}+abs(tss)./samplecount;
                end
             end
          end
       end
    end
end

% create tidy labels
set(h,'Name',sprintf('%s-LFP',basename(mfile{1})));
subplot(3,1,1);
hl=legend(fns);
set(hl,'Interpreter','None');

% plot the spectrogram
subplot(3,1,3);
dd=log(sout{2}(1:end,:,1))-log(sout{1}(1:end,:,1));
dd(isnan(dd))=0;
imagesc(ttt-PreStimSilence,tff(1:end),dd,[-max(abs(dd(:))) max(abs(dd(:)))]);
axis xy;
colorbar
xlabel('time (sec)');
ylabel('frequency (Hz)');
title('spectrogram: log(during) minus log(pre)');
drawnow

siteid=basename(mfile{1});

results.siteid=siteid(1:7);
results.StimDuration=StimDur;
results.PreStimSilence=PreStimSilence;
results.PostStimSilence=PostStimSilence;
results.spect=rspect;
results.specterr=rspecterr;
results.freq=rfreq;
results.rawlfp=rout;
results.tags=tags;
results.fs=rasterfs;
results.startwin=starttime;
results.stopwin=stoptime;
results.specgram=sout;
results.sgtime=ttt;
results.sgfreq=tff;

disp('lfp_spectrum complete');

