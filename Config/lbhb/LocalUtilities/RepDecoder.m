function [pred,thresh]=RepDecoder(r,RepDur,TarStartTime);
    
    TrialCount=size(r,2);
    CellCount=size(r,3);
    p=zeros(size(r));
    tp=nan(size(r,1),TrialCount);
    cfilt=[zeros(RepDur-1,1);ones(RepDur,1)./RepDur];
    for cellidx=1:CellCount,
        for trialidx=1:TrialCount,
            ff=find(~isnan(r(:,trialidx,cellidx)));
            tr=r(ff,trialidx,cellidx);
            tr=tr-mean(tr);
            txc=[zeros(RepDur,1); tr(1:(end-RepDur)).*tr((RepDur+1):end)];
            tp(1:length(txc),trialidx)=txc;
        end
        tp=rconv2(tp,cfilt);
        p(:,:,cellidx)=(tp-nanmean(tp(:)))./nanstd(tp(:));
    end
    s=zeros(size(r(:,:,1)));
    for trialidx=1:TrialCount,
        s((TarStartTime(trialidx)+RepDur):end,trialidx)=1;
    end
    stim=reshape(s,size(s,1).*TrialCount,1);
    resp=reshape(p,size(p,1).*TrialCount,CellCount);
    keepidx=find(~isnan(resp(:,1)));
    stim=stim(keepidx);
    resp=resp(keepidx,:);
    m0=nanmean(stim);
    [H,BRAC]=revrecCore(stim-nanmean(stim),resp);
    
    pred=zeros(size(s,1).*TrialCount,1);
    pred(keepidx)=resp*H+m0;
    pred=reshape(pred,size(s,1),TrialCount);
    
    rp=pred;
    for trialidx=1:TrialCount,
        rp(1:RepDur,trialidx)=nan;
        rp((TarStartTime(trialidx)+RepDur):end,trialidx)=nan;
    end
    rp=sort(rp(~isnan(rp)));
    thresh=rp(round(0.95.*length(rp)));
    
    
    
    
    