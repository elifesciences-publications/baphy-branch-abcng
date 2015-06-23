% [snr,z,tau,repcount]=resp_snr2(r,fs);
function [snr,z,tau,repcount]=resp_snr2(r,fs);

if 0,
    spkfile='/auto/data/daq/Lemon/lemon059/sorted/lemon059c03_p_VOC.spk.mat';
    options=struct('rasterfs',200,'unit',1,'channel',4,...
                   'tag_masks',{{'Reference'}},'includeprestim',1,...
                   'includeincorrect',1);
    r=loadspikeraster(spkfile,options);
end
    
verbose=0;

if ~exist('fs','var'),
    fs=200;
end

reps_per_stim=squeeze(sum(~isnan(r(1,:,:)),2));
nonzeroreps=find(reps_per_stim>0);
r=r(:,:,nonzeroreps);

reps_per_stim=squeeze(sum(~isnan(r(1,:,:)),2));
min_reps_per_stim=min(reps_per_stim);
r=r(:,1:min_reps_per_stim,:);
    
reps_per_stim=squeeze(sum(~isnan(r(1,:,:)),2));
stimidx=find(reps_per_stim==max(reps_per_stim));
stimcount=length(stimidx);
if verbose, fprintf('stimcount=%d\n',stimcount); end
r=r(:,:,stimidx);

%trialsetxc=trialset(:,stimidx);
nn=sum(isnan(r(:,:)),2);
mnn=max(find(nn==0));
if mnn<size(r,1),
    fprintf('truncating at bin %d to correct for variable-len trials\n',mnn);
    r=r(1:mnn,:,:);
end


tau=1000./[fs fs./2 fs./4 fs./8 fs./16 fs./32 fs./64];
tlen=length(tau);
snr=zeros(1,tlen);
z=zeros(1,tlen);
repcount=size(r,2);
mr=round(repcount./2);

if repcount<2,
    fprintf('Fewer than two reps. Cancelling.\n');
    return
end

if verbose,
    sfigure(1);
    clf
    plot((1:size(r,1))./fs,squeeze(nanmean(r,2)));
    hold on
    plot((1:size(r,1))./fs,nanmean(nanmean(r,2),3),'k','LineWidth',2);
    hold off
end
    
tr=r;
for tauidx=1:tlen,
    
    rxc=tr-mean(tr(:));
    
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
    snr(tauidx)=mean(s12)./(mean(s11-s12));
    %sin=s12./(s11-s12);
    %sin(isinf(sin))=10;
    %snr=nanmean(sin);
    %snr=mean(e11-e12)./mean(e12);
    %snr=sqrt(abs(snr)).*sign(snr);

    %if snr==0, snr=nanmean(sin); end
    if max(xcin)==0,
        z(tauidx)=0;
    elseif max(xcout)==0
        z(tauidx)=20;
    else
        %z(tauidx)=(mean(xcin)-mean(xcout))./sqrt((var(xcin)+var(xcout))./cc);
        z(tauidx)=mean(xcin)./sqrt(var(xcin)./cc);
    end
    
    [A,B,C]=size(tr);
    if (A./2)~=round(A./2), A=A-1; tr=tr(1:A,:,:); end
    
    tr=reshape(tr,2,A/2,B,C);
    tr=reshape(mean(tr,1),A/2,B,C);

end



