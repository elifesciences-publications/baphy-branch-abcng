% function
% [r,TrialCategory,TarIdx,DisIdx,exptparams,Trial2Seq]=LoadSNS(parmfile,spikefile,options);
% returns:
% r= Time X Rep X SequenceCount X Cell#
%
function [r,TrialCategory,TarIdx,DisIdx,BigSequenceMatrix,exptparams,Trial2Seq]=LoadSNS(parmfile,spikefile,options);

LoadMFile(parmfile);

if ~exist('options','var'),
    options=struct;
end
options.tag_masks={'SPECIAL-TRIAL'};
options.psth=-1;
options.rasterfs=getparm(options,'rasterfs',100);
options.lfp=getparm(options,'lfp',0);
options.meansub=getparm(options,'meansub',0);
if ~isfield(options,'channel'),
    bb=basename(spikefile);
    sql=['SELECT channum,unit FROM sCellFile WHERE respfile="',bb,'";'];
    fdata=mysql(sql);
    unitset=[cat(1,fdata.channum).*10+cat(1,fdata.unit)];
    if options.lfp>0,
        cc=unique(floor(unitset/10));
        options.channel=cc;
        options.unit=ones(size(cc));
    else
        options.channel=floor(unitset/10);
        options.unit=mod(unitset,10);
    end
end

[tr,tags,trialset,exptevents,sortextras]=loadsiteraster(spikefile,[],[],options);

SequenceIdx=exptparams.TrialObject.SequenceIdx;
TrialCount=exptevents(end).Trial;
TrialDuration=exptparams.TrialObject.PreTrialSilence+exptparams.TrialObject.PostTrialSilence+...
    exptparams.TrialObject.SamplesPerTrial*exptparams.TrialObject.ReferenceHandle.Duration;
TrialBins=round(TrialDuration*options.rasterfs);
tr=tr(1:TrialBins,:,:,:);

zerocheck=nansum(nansum(tr,1),3);
nzmax=max(find(zerocheck>0));
if nzmax<TrialCount,
    fprintf('All-zero trials at end, truncating from %d to %d trials\n',...
            TrialCount,nzmax);
    TrialCount=nzmax;
    tr=tr(:,1:nzmax,:);
end

if TrialCount<length(SequenceIdx),
    SequenceIdx=SequenceIdx(1:TrialCount);
end
Sequences={exptparams.TrialObject.Sequences{SequenceIdx}};
BigCat=exptparams.TrialObject.SequenceCategories(SequenceIdx);

% 1 FixTarOnlySeq
% 2 FixTarVarDisSeq
% 3 FixTarFixDisSeq
% 4 VarDisOnlySeq
% 5 FixDisOnlySeq
% 6 VarTarVarDisSeq

UniqueSequences={};
UniqueSeqIdx=zeros(TrialCount,1);
TrialCategory=[];
TarIdx=[];
DisIdx=[];
BigSequenceMatrix=[];
for xx=1:6, % for each sequence cat
    us={};
    ff=find(BigCat==xx);
    uid=zeros(length(ff),1);
    ut=[];
    ud=[];
    for ii=1:length(ff),
        match=0; jj=0;
        while ~match && jj<length(us),
            jj=jj+1;
            if sum(sum(abs(Sequences{ff(ii)}-us{jj})))==0,
                match=jj;
            end
        end
        if ~match,
            us={us{:} Sequences{ff(ii)}};
            if size(us{end},2)==2,
                BigSequenceMatrix=cat(3,BigSequenceMatrix,us{end});
            else
                BigSequenceMatrix=cat(3,BigSequenceMatrix,...
                                      [us{end} zeros(size(us{end}))]);
            end
            switch xx,
              case {1,2},
                ut=cat(1,ut,us{end}(1,1));
                ud=cat(1,ud,0);
              case 3,
                ut=cat(1,ut,us{end}(1,1));
                ud=cat(1,ud,us{end}(1,2));
              case {4,6},
                ut=cat(1,ut,0);
                ud=cat(1,ud,0);
              case 5,
                ut=cat(1,ut,0);
                ud=cat(1,ud,us{end}(1,1));
            end
            match=length(us);
        end
        uid(ii)=match;
    end
    CountSoFar=length(UniqueSequences);
    UniqueSequences=cat(2,UniqueSequences,us);
    UniqueSeqIdx(ff)=uid+CountSoFar;
    TrialCategory=cat(1,TrialCategory,ones(length(us),1)*xx);
    TarIdx=cat(1,TarIdx,ut);
    DisIdx=cat(1,DisIdx,ud);
end

UCount=length(UniqueSequences);
% r= Time X Rep X SequenceCount X Cell#
r=ones(size(tr,1),1,UCount,size(tr,3)).*nan;
for ii=1:UCount,
    ff=find(UniqueSeqIdx==ii);
    dr=permute(tr(:,ff,:),[1 2 4 3]);
    if size(dr,2)>size(r,2),
        r=cat(2,r,ones(size(r,1),size(dr,2)-size(r,2),size(r,3),size(r,4)).*nan);
    end
    r(:,1:size(dr,2),ii,:)=dr;
end
Trial2Seq=UniqueSeqIdx;

