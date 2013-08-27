function snr = resp_snr(spdata,stim,basep,a1rv,mf)% ,waveParams,a1rv)

% snr = get_snr(spdata,stim,basep,mf,waveParams)
%
% This function gets the snr using the spike data given in spdata
% The spike data and stims should include all inverse-repeat pairs of TORCs
% the method is valid only using TORC stimuli

% April 20, 2004

% if ~exist('waveParams','var') | isempty(waveParams) 
    invlist = []; 
% else
%     [istorc,invlist] = torctest(waveParams);
% end

[numdata,numsweeps,numrecs] = size(spdata);
[stimfreq,stimtime,numstims] = size(stim);
spdata(find(isnan(spdata)))=0;
snr = Inf;

if ~eq(numrecs,numstims)
    disp('Number of records and stimuli are not equal');
    return;
end

% Response variability as a function of frequency per stimulus(-pair)
% -------------------------------------------------------------------
n = numsweeps*numdata/mf/basep;
tmp = spdata(1:(floor(n/numsweeps)*mf*basep),:,:);
spdata2 = reshape(tmp(:),[basep*mf,numsweeps*floor(n/numsweeps),numrecs]);
n = numsweeps*floor(n/numsweeps);
if n/numsweeps > 1,
    spdata2(:,[1:n/numsweeps:n],:)=[]; %exclude first period of each sweep
end
n = size(spdata2,2);
if ~(size(invlist,1) < 2),
    vrf = 1e6*stimtime^2/basep^2/n*squeeze(std(fft((spdata2(:,:,invlist(1,:))-spdata2(:,:,invlist(2,:)))/2,[],1),0,2)).^2;
else
    vrf = 1e6*stimtime^2/basep^2/n*squeeze(std(fft(spdata2,[],1),0,2)).^2;
end

% Response power as function of frequency
% ---------------------------------------
spikeperiod = squeeze(mean(spdata2,2));

% downsample spike histogram using insteadofbin (in justin.good)
if basep/stimtime ~= 1/mf,
    spikeperiod = insteadofbin(spikeperiod,basep/stimtime,mf);
end
spikeperiod = spikeperiod*1e3/basep*stimtime;

if ~(size(invlist,1)<2), 
    spikeperiod = (spikeperiod(:,invlist(1,:)) - spikeperiod(:,invlist(2,:)))/2; 
end

prf = abs(fft(spikeperiod,[],1)).^2;  

% Variability of the STRF estimate (for TORC stimuli)
% ---------------------------------------------------
%stimpospolarity = find(ismember(invlist(1,:),setdiff(invlist(1,:),[])));
if ~(size(invlist,1) < 2),
    stimpospolarity = invlist(1,:);
else
    stimpospolarity = [1:size(stim,3)];
end
stim2 = stim(:,:,stimpospolarity);

freqindx = round(abs(cat(1,a1rv{:}))'*basep/1000 + 1);
freqindx = freqindx(:,stimpospolarity);

% These are 1/a^2 for each stimulus
as = 2*sum(freqindx>0)./(squeeze(mean(mean(stim2.^2))))'; %sum(stimpospolarity>0):number of ripples

% Estimate of the total power (ps) and error power (pes) of the STRF 
pt = 0; pes = 0;
for rec = 1:length(stimpospolarity)
    pt  = pt + 1/stimtime^2*as(rec)*sum(2*prf(freqindx(:,rec),rec)); % Total power
    pes = pes + 1/stimtime^2*as(rec)*sum(2*vrf(freqindx(:,rec),rec)); % Error power
end

snr = pt/pes - 1;
