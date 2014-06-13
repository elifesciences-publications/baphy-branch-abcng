% function raster_plot(mfile,r,tags,h,options);
% 
% mfile - baphy parm file for this experiment.
% r - time X rep X stimulus id
% tags - cell array of stimulus ids, length should match size(r,3)
% h - handle of axes in a figue (eg, output of "gca" or
% "subplot(1,1,1)") where plot should be displayed (default if not
% provided or left empty [] is a single subplot on a new figure)
%
% valid options fields
%    .rasterfs [=1000]
%    .sigthreshold [=4]
%    .datause [='Both'] % ie, all data, targets and references
%
function raster_plot(mfile,r,tags,h,options);

global ES_LINE  ES_SHADE

if ~exist('options','var'),
   options=[];
end
if ~isfield(options,'channel'),
    options.channel=1;
end
if ~isfield(options,'unit'),
    options.unit=1;
end
if ~exist('h','var') || isempty(h),
    figure;
    h=gca;
    drawnow;
end
if ~exist('options','var'),
    options=[];
end
if ~isfield(options,'rasterfs'),
    options.rasterfs=1000;
end
if ~isfield(options,'sigthreshold'),
    options.sigthreshold=4;
end
if ~isfield(options,'datause'),
    options.datause='Reference';
end
if ~isfield(options,'psth'),
    options.psth=0;
end
if ~isfield(options,'psthfs'),
    options.psthfs=20;
end
if ~isfield(options,'lfp'),
    options.lfp=0;
end
if ~isfield(options,'lick'),
    options.lick=0;
end
if ~isfield(options,'usesorted'),
    options.usesorted=0;
end
if ~isfield(options,'compact'),
    options.compact=0;
end
options.raster=getparm(options,'raster',1);
if options.lfp,
    % must calculate average ("psth"), since lfp doesn't give rasters
   options.psth=1;
   options.raster=0;
elseif ~options.psth,
   options.raster=1;
end

tic;

if options.lick
    disp('Loading licks...');
    toptions=options;
    toptions.lfp=2;
    lickfs=20;
    toptions.rasterfs=lickfs;
    toptions.usesorted=0;
    [lick,ltags]=raster_load(mfile,options.channel,options.unit,toptions);
end

rasterfs=options.rasterfs;
sigthreshold=options.sigthreshold;
datause=options.datause;

LoadMFile(mfile);
MidStimMarker=[];  % only plot if a discrim trial
if ~isempty(strfind(upper(datause),'LICK')),
    PreStimSilence=0.4;
    PostStimSilence=0.3;
    StimDuration=0.1;
else
   [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PreStim*']);
    if length(eventtime)>0,
        if isfield(options, 'PreStimSilence'),
            PreStimSilence=options.PreStimSilence;
        else
            PreStimSilence=eventtimeoff(1)-eventtime(1);
            if PreStimSilence==0,
               PreStimSilence=0.1;
            end
        end
        
        xx=eventtimeoff(1);
        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PostStim*']);
        if length(eventtime)==0,
            [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PreStim*'],2);
            xx=eventtimeoff(1);
            [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PostStim*'],2);
        end
        if isfield(options,'Duration'),
           StimDuration.options.Duration,
        else
           StimDuration=eventtime(1)-xx;
        end
        
        if isfield(options, 'PostStimSilence'),
            PostStimSilence=options.PostStimSilence;
        else
            PostStimSilence=eventtimeoff(end)-eventtime(end);
        end
        
        [gaptime,evtrials,gapNote,gaptimeoff]=evtimes(exptevents,['GAP*'],1);
        if length(gaptime)>0,
            MidStimMarker=gaptimeoff;
        elseif length(eventtime)>1 & eventtimeoff(1)-eventtime(1)==0 & ...
                eventtimeoff(2)-eventtime(2)>0,
            disp('Think this is a discrimination task, adding extra division line.');
            MidStimMarker=eventtime(1);
            StimDuration=eventtime(2)-xx;

        end
        
    else
        PreStimSilence=0.1;
        PostStimSilence=0.1;
        StimDuration=1;
    end
end
if isfield(exptparams,'BehaveObject') && ...
      isfield(exptparams.BehaveObject,'ResponseTime') && ...
      exptparams.BehaveObject.ResponseTime>0,
    ResponseTime=exptparams.BehaveObject.ResponseTime;
    PreLickWindow=exptparams.BehaveObject.PreLickWindow;
    PostLickWindow=exptparams.BehaveObject.PostLickWindow;
else
    ResponseTime=0;
    PreLickWindow=0;
    PostLickWindow=0;
end


% if DMS with variable length references, realign PostStim responses
if isfield(exptparams,'refstd') && ...
        ~strcmp(exptparams.TrialObject.TargetHandle.descriptor,'ComplexChord') && ...
      (exptparams.refstd>0 || exptparams.refmean<exptparams.TrialObject.TargetHandle.Duration),
   postbins=floor(PostStimSilence.*rasterfs);
   targetduration=min(0.5, exptparams.TargetObject.Duration);
   keepbins=[1:round((PreStimSilence+targetduration).*rasterfs) ...
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
   StimDuration=targetduration;
end

         
% now for FTC, which is random tone object, sort the raster rows based on
% numeric values in tags
unsortedtags=zeros(length(tags),1);
slabels={};
if isempty(strfind(upper(datause),'LICK')) && ...
        isempty(strfind(upper(datause),'COLLAPSE')) &&  ...
        isempty(strfind(upper(datause),'PER TRIAL')) &&  ...
        isfield(exptparams,'TrialObject') && ...
        isfield(exptparams.TrialObject,'ReferenceHandle') && ...
        (strcmpi(exptparams.TrialObject.ReferenceHandle.descriptor, 'RandomTone') ||...
           strcmpi(exptparams.TrialObject.ReferenceHandle.descriptor, 'Click') || ...
           (strcmpi(exptparams.TrialObject.ReferenceHandle.descriptor, 'NoiseBurst') && ...
               exptparams.TrialObject.ReferenceHandle.SimulCount==1) || ...
           (strcmpi(exptparams.TrialObject.ReferenceHandle.descriptor, 'ComplexChord') && ...
               exptparams.TrialObject.ReferenceHandle.SecondToneAtten==-1 && ...
               sum(exptparams.TrialObject.ReferenceHandle.AM)==0 && ...
               isempty(exptparams.TrialObject.ReferenceHandle.LightSubset))),

    for cnt1=1:length(tags),
        temptags = strrep(strsep(tags{cnt1},',',1),' ','');
        unsortedtags(cnt1) = str2num(temptags{2});
    end

    [sortedtags, index] = sort(unsortedtags); % sort the numeric tags

    tags={tags{index}};
    r=r(:,:,index);
end

% convert from r matrix (output from loadevpraster) to data matrix that's
% easy to plot raster
data    = [];
labels  = [];
singlabels  = {};
keepidx=zeros(size(r,3),1);
unique_suffix={};
suffix_category=zeros(size(r,3),1);
for cnt1 = 1:size(r,3)
   keepidx(cnt1)=sum(sum(~isnan(r(:,:,cnt1))))>0;
   if keepidx(cnt1),
      temptags = strrep(strsep(tags{cnt1},',',1),' ','');
      if length(temptags)==1,
          temptags{2}=temptags{1};
      end
      singlabels{end+1} = temptags{2};
      if length(temptags)>=3,
          tsuf=strtrim(strrep(strrep(temptags{3},'Reference',''),'Target',''));
      else
          tsuf='';
      end
      suffidx=find(strcmp(tsuf,unique_suffix));
      if isempty(suffidx),
          unique_suffix{end+1}=tsuf;
          suffix_category(cnt1)=length(unique_suffix);
      else
          suffix_category(cnt1)=suffidx;
      end
      
      if ~isempty(tsuf),
          labels{end+1}= [temptags{2} ' ' tsuf];
      else
          labels{end+1} = temptags{2};
      end
      
       for cnt2 = 1:size(r,2)
          if sum(~isnan(r(:,cnt2,cnt1)))>0,
             data(end+1,:) = squeeze(r(:,cnt2,cnt1));
             if cnt2>1
                %label duplicate tags with 'D -' prefix
                labels{end+1} = ['D -' temptags{2}];
             end
          end
%          %if isnumeric(labels{end}),
%          %   labels{end}=mat2str(labels{end});
%          %end
       end
   end
end

keepidx=find(keepidx);
r=r(:,:,keepidx);

% [~,ksort]=sort(suffix_category(keepidx));
% r=r(:,:,keepidx(ksort));
% labels=labels(ksort);

% now set anything with D to empty:
empt = strfind(labels,'D -');
newstim=zeros(size(labels));
for cnt1 = 1:length(labels)
    % special code to trim labels:
    if strcmp(labels{cnt1},'Reference'),
        labels{cnt1}='Ref';
    elseif strcmp(labels{cnt1},'Target'),
        labels{cnt1}='Tar';
    elseif strcmp(labels{cnt1},'Distractor'),
        labels{cnt1}='Dis';
    end
   
   if empt{cnt1}==1
      labels{cnt1} = ['EMPTY'];
   else
      newstim(cnt1)=1;
   end
end

% some color info for shading
if isfield(options,'spc'),
   spc=options.spc;
else
   spc={[0 0 1],[1 0 0],[0 1 0],[0 0 0],[1 0 1],[1 1 0],[0 0.9 0.9],[1 ...
                    0 1],[1 1 0],[0 0.9 0.9]};
   spc=ES_LINE;
end
if isfield(options,'ssc'),
   ssc=options.ssc;
else
   %gl=0.9;
   %ssc={[gl gl 1],[1 gl gl],[gl 1 gl],[0.95 0.95 0.95],...
   %     [0.95 0.95 0.95],[0.95 0.95 0.95],[0.95 0.95 0.95]};
   gl=0.85;
   ssc={[gl gl 1],[1 gl gl],[gl 1 gl],[0.95 0.95 0.95],...
        [0.95 0.95 0.95],[0.95 0.95 0.95],[0.95 0.95 0.95],...
        [0.95 0.95 0.95],[0.95 0.95 0.95],[0.95 0.95 0.95]};
   ssc=ES_SHADE;
end

% plot the raster
sfigure(get(h,'Parent'));
set(get(h,'Parent'),'CurrentAxes',h)
axes(h);
cla
if isempty(data),
    title('no data');
    return
elseif options.raster && ~options.psth,
   [di,dj]=find(data>0);
   di=di./size(data,1);
   dj=dj./rasterfs-PreStimSilence;
   if globalparams.NumberOfElectrodes>8 || length(dj)>500,
       plot(dj,di,'k.','markersize',4);
   else
       plot(dj,di,'k.','markersize',8);
   end
   axis ([-PreStimSilence size(data,2)./rasterfs-PreStimSilence 0 1]);
   
elseif options.raster,
   dn=double(isnan(data));
   data(isnan(data))=0;
   
   % bin at 10 ms
   bn=10;
   smfilt=ones(1,bn)./bn;
   data2=conv2(data,smfilt,'same');
   data2=data2(:,round(bn/2):bn:end);
   dn2=conv2(dn,smfilt,'same');
   dn2=dn2(:,round(bn/2):bn:end);
   %keyboard
   data2=(0.1-data2)./0.1;
   data2(data2>1)=1;
   data2(data2<0)=0;
   data3=data2;
   data3(dn2>=0.5)=0.7; %1
   data2(dn2>=0.5)=0.7; %0
   data2=cat(3,data3,data2,data2);
   
   ff=find(newstim);
   NStim = length(ff); for iC=1:NStim spc{iC} = hsv2rgb([0.1 + iC/(1.2*NStim),1,1]); ssc{iC} = HF_whiten(spc{iC},0.5); end
   %ff=ff(2:end);
   blankstep=1;
   ff=ff+blankstep*(0:(length(ff)-1));
   
   for di=1:length(ff),
       if di>1,
           data2=[data2(1:(ff(di)-blankstep-1),:,:); ones(blankstep,size(data2,2),size(data2,3));
               data2((ff(di)-blankstep):end,:,:)];
       end
       if di<length(ff),
           muckrange=(ff(di)):(ff(di+1)-blankstep-1);
       else
           muckrange=(ff(di)):size(data2,1);
       end
       timerange=round(PreStimSilence.*rasterfs./10+1):round(size(data2,2)-(PostStimSilence.*rasterfs./10));
       
       for ggidx=1:3,
           td2=data2(muckrange,timerange,ggidx);
           bgidx=find(td2==1);
           td2(td2==1)=ssc{mod(di-1,length(ssc))+1}(ggidx);
           data2(muckrange,timerange,ggidx)=td2;
       end
       
       %boundlevel=(di-0.5)./size(data,1);
       %plot([-PreStimSilence size(data,2)./rasterfs-PreStimSilence],boundlevel.*[1 1],'b');
   end
   
   imagesc(-PreStimSilence:(1./rasterfs):(size(data,2)./rasterfs)-PreStimSilence,...
       (1./size(data,1)):(1./size(data,1)):1,data2);
   
   colormap(gray);
   axis([-PreStimSilence size(data,2)./rasterfs-PreStimSilence 0 1]);
   axis xy
end

% plot psth / average lfp, if requested
fprintf('%s before plot commands: %.1f sec\n',mfilename,toc);


if options.psth && size(r,2)>1,
    pfs=options.psthfs;
    filtlen=round(rasterfs./pfs);
    sampidx=round(filtlen./2):filtlen:size(r,1);
    rpsth=nan.*zeros(length(sampidx),size(r,2),size(r,3));
    smfilt=ones(filtlen,1)./filtlen;
    for jj=1:size(r,3),
        fn=find(sum(~isnan(r(:,:,jj)))>0);
        tr=r(:,fn,jj);
        ntrack=find(isnan(tr));
        tr(ntrack)=nanmean(tr(:));
        %tr=conv2(tr,smfilt,'same');
        tr=rconv2(tr,smfilt);
        tr(ntrack)=nan;
        if size(tr,1)>=max(sampidx),
           rpsth(:,fn,jj)=tr(sampidx,:);
        end
    end
    rvalidcount=squeeze(sum(~isnan(rpsth(:,:,:)),2));
    rvalidcount(rvalidcount==0)=1;
    rpstherr=permute(nanstd(permute(rpsth,[2 1 3])),[2 3 1])./ ...
        sqrt(rvalidcount);
    rpsth=permute(nanmean(permute(rpsth,[2 1 3])),[2 3 1]);
    
    if isfield(options,'psthsubmin') && options.psthsubmin,
       rpsth=rpsth-min(rpsth(:));
    end
    
    snr=abs(rpsth./(rpstherr+(rpstherr==0)));
    outlieridx=find(snr<2 & rpsth>nanmean(rpsth(:)).*2);
    if ~isempty(outlieridx) && ~options.lfp,
        disp('removing outliers in raster_plot');
        %[snr(outlieridx) (snr(outlieridx)./2).^2 rpsth(outlieridx).*rasterfs]
        rpsth(outlieridx)=rpsth(outlieridx).*(snr(outlieridx)./2).^2;
        rpstherr(outlieridx)=rpstherr(outlieridx).*(snr(outlieridx)./2).^2;
    end
    
    ff=find(newstim);
    spsth=zeros(size(rpsth));
    if isfield(options,'psthmax') && options.psthmax>0,
       psthmax=options.psthmax;
    else
       psthmax=max(rpsth(:)+rpstherr(:)).*rasterfs;
    end
    spsth=rpsth./(psthmax./rasterfs).*size(data,1);
    spstherr=rpstherr./(psthmax./rasterfs).*size(data,1);
    
    if options.lick,
        lickpsth=permute(nanmean(permute(lick,[2 1 3])),[2 3 1]);
        if mean(lickpsth(:))>0.99999,
           lickpsth(:)=0;
        end
        if isfield(options,'lickmax'),
           lickmax=options.lickmax;
        else
           lickmax=max(lickpsth(:));
        end
        slickpsth=lickpsth./lickmax.*0.95;
        slickbins=min(size(slickpsth,1),round(size(spsth,1)./pfs.*lickfs));
        slickpsth=slickpsth(1:slickbins,:);
    end
    
    hold on;
    %spc={'b-','r-','g-','k-','c-','m-','y-'};
    aa=axis;
    if options.raster,
        for ii=1:length(ff),
            spcidx=mod(ii-1,length(spc))+1;
            errorshade((1:size(spsth,1))'./pfs-PreStimSilence-1./(pfs.*2),...
                (spsth(:,ii)./size(data,1)-1)./2,...
                (spstherr(:,ii)./size(data,1))./2,...
                spc{spcidx},ssc{spcidx});
        end
        for ii=1:length(ff),
            spcidx=mod(ii-1,length(spc))+1;
            ht=plot((1:size(spsth,1))./pfs-PreStimSilence-1./(pfs.*2),...
                (spsth(:,ii)./size(data,1)-1)./2,...
                'Color',spc{spcidx});
        end
        text(-PreStimSilence-0.05,-0.1,...
            sprintf('%.0f',psthmax),'HorizontalAlignment','right');
        text(-PreStimSilence-0.05,-0.45,...
            sprintf('%.0f',0),'HorizontalAlignment','right');
        if options.lick,
            for ii=1:length(ff),
                spcidx=mod(ii-1,length(spc))+1;
                ht=plot((1:size(slickpsth,1))./lickfs-PreStimSilence-1./(lickfs.*2),...
                    (slickpsth(:,ii)./2-1),...
                    'Color',spc{spcidx});
            end
            text(-PreStimSilence-0.05,-0.6,...
                sprintf('%.2f',lickmax),'HorizontalAlignment','right');
            text(-PreStimSilence-0.05,-0.95,...
                sprintf('%.2f',0),'HorizontalAlignment','right');

            axis([aa(1:2) -1 1]);
            markerbottom=-1;
        else
            axis([aa(1:2) -0.5 1]);
            markerbottom=-0.5;
        end
    else
        for ii=1:length(ff),
            spcidx=mod(ii-1,length(spc))+1;
            errorshade((1:size(spsth,1))'./pfs-1./(pfs.*2)-PreStimSilence,...
                spsth(:,ii)./size(data,1),...
                spstherr(:,ii)./size(data,1),...
                spc{spcidx},ssc{spcidx});
        end
        for ii=1:length(ff),
            spcidx=mod(ii-1,length(spc))+1;
            plot((1:size(spsth,1))./pfs-PreStimSilence-1./(pfs.*2),...
                 spsth(:,ii)./size(data,1),'Color',spc{spcidx});
        end
        text(-PreStimSilence-0.05,0.95,...
            sprintf('%.0f',psthmax),'HorizontalAlignment','right');
        text(-PreStimSilence-0.05,0.05,...
            sprintf('%.0f',0),'HorizontalAlignment','right');
        if options.lick,
               
           for ii=1:length(ff),
                spcidx=mod(ii-1,length(spc))+1;
                ht=plot((1:size(slickpsth,1))./lickfs-PreStimSilence-1./(lickfs.*2),...
                    (slickpsth(:,ii)./0.95./2-0.5),...
                    'Color',spc{spcidx});
            end
            text(-PreStimSilence-0.05,-0.05,...
                sprintf('%.2f',lickmax),'HorizontalAlignment','right');
            text(PreStimSilence-0.05,-0.55,...
                sprintf('%.2f',0),'HorizontalAlignment','right');

            %axis([aa(1:2) -1 1]);
            markerbottom=-0.5;
        else
            %axis([aa(1:2) -0.5 1]);
            markerbottom=0;
        end
    end
else
    markerbottom=0;
end

line([0 0],[markerbottom 1],'linestyle','--','color','g');
line([size(data,2)/rasterfs-(PostStimSilence+PreStimSilence)...
    size(data,2)/rasterfs-(PostStimSilence+PreStimSilence)],...
    [markerbottom 1],'linestyle','--','color','g');
if ResponseTime>0,
    line([1 1].*(StimDuration+ResponseTime),...
        [markerbottom 1],'linestyle','--','color','r');
    line([1 1].*(StimDuration+ResponseTime+PostLickWindow),...
        [markerbottom 1],'linestyle','--','color','r');
end
if ~isempty(MidStimMarker),
    for jj=1:length(MidStimMarker),
        line([MidStimMarker(jj)-PreStimSilence MidStimMarker(jj)-PreStimSilence],...
            [markerbottom 1],'linestyle','--','color','g');
    end
end

if options.raster,
   LabelIndex  = find(~strcmpi(labels,'EMPTY'));
   if length(LabelIndex)>25
      LabelIndex = LabelIndex(round(linspace(1,length(LabelIndex),25)));
   end
   if max(LabelIndex)>1,
      set(gca, 'ytick', LabelIndex/size(data,1));
      set(gca, 'yticklabel', labels(LabelIndex));
   else
      set(gca,'ytick',[]);
      set(gca,'yticklabel',{});
      if length(LabelIndex)>0,
         ylabel(labels{1},'Interpreter','none');
      end
   end
   %set(gca, 'xticklabel',str2num(get(gca,'xticklabel'))/rasterfs);
else
   set(gca, 'ytick',[]);
   axis tight
end

hold off

if options.compact,
   ht=title(sprintf('%s E%d, T%d',...
     basename(mfile),options.channel,exptevents(end).Trial));
   set(ht,'FontSize',6);
   if options.channel>1,
       set(gca,'XTickLabel',[],'YTickLabel',[]);
   else
       set(gca,'FontSize',6);
   end
   
elseif options.usesorted,
    if length(options.unit) == 1
        sortedunit = options.unit;
    else
        sortedunit = options.sortedunit;
    end
   ht=title(sprintf('Unit (%d-%d); %d Trials', ...
       options.channel, sortedunit, exptevents(end).Trial), 'FontSize',8);
else
   ht=title(sprintf('%s E%d, thr=%.1fs, trial %d',...
                    basename(mfile),options.channel,sigthreshold,...
                    exptevents(end).Trial));
end
set(ht,'Interpreter','none');
set(gcf,'Name',sprintf('%s(%d)',basename(mfile),exptevents(end).Trial));

drawnow

fprintf('%s total: %.1f sec\n',mfilename,toc);

