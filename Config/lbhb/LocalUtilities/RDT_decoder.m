function dp=RDT_decoder(cellid,active,singleunit);

% go to cell db to find active and passive data for this cell
if ~exist('active','var'),
    active=1;
end

if active,
    cellfiledata=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                                'behavior','active');
    activestr='active';
else
    cellfiledata=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                                 'Trial_Mode','RandAndRep');
    if isempty(cellfiledata),
        disp('no passive files for this site');
        dp=nan(4,1);
        return
    end
    if strcmpi(cellfiledata(1).behavior,'passive'),
        uidx=1;
    elseif strcmpi(cellfiledata(end).behavior,'passive'),
        uidx=length(cellfiledata);
    else
        uidx=1;
    end
    cellfiledata=cellfiledata(uidx);
    activestr='passive';
end

options.rasterfs=100;
options.resp_shift=0.0;
if ~exist('singleunit','var'),
    singleunit=0;
end
if singleunit,
    % one unit only
    options.channel=cellfiledata(1).channum;
    options.unit=cellfiledata(1).unit;
else
    % all units at this site
    spikefile=[cellfiledata(1).path cellfiledata(1).respfile];
    bb=basename(spikefile);
    sql=['SELECT channum,unit FROM sCellFile WHERE respfile="',bb,'";'];
    fdata=mysql(sql);
    unitset=[cat(1,fdata.channum).*10+cat(1,fdata.unit)];
    options.channel=floor(unitset/10);
    options.unit=mod(unitset,10);
end

r=[];
RepDur=[];
TargetStartBin=[];
TarStartTime=[];
TrialCount=0;
BigSequenceMatrix=[];
ThisTarget=[];
for fidx=1:length(cellfiledata),
    parmfile=[cellfiledata(fidx).stimpath cellfiledata(fidx).stimfile];
    spikefile=[cellfiledata(fidx).path cellfiledata(fidx).respfile];
    
    % r=response (time X trialcount X cell), only for correct trials
    [tr,params]=load_RDT_by_trial(parmfile,spikefile,options); 
    
    if isempty(r),
        
    elseif size(tr,1)>size(r,1),
        tr=tr(1:size(r,1),:,:);
    elseif size(r,1)>size(tr,1),
        r=r(1:size(tr,1),:,:);
    end
    r=cat(2,r,tr);
    
    TargetStartBin=cat(1,TargetStartBin,...
                       params.TargetStartBin(params.CorrectTrials));
    TrialCount=TrialCount+length(params.CorrectTrials);
    ThisTarget=cat(1,ThisTarget,params.ThisTarget(params.CorrectTrials));
    BigSequenceMatrix=cat(3,BigSequenceMatrix,...
                          params.BigSequenceMatrix(:,:,params.CorrectTrials));
end
params.SampleStarts=cat(2,params.SampleStarts,size(r,1));
TargetStartBin(TargetStartBin<0)=length(params.SampleStarts);
TarStartTime=params.SampleStarts(TargetStartBin);
RepDur=diff(params.SampleStarts(1:2));
[p,thresh]=RepDecoder(r,RepDur,TarStartTime);

singleTrial=squeeze(BigSequenceMatrix(1,2,:)==-1);
trialcat=zeros(size(ThisTarget));
trialcat(ThisTarget==params.TargetIdx(1) & singleTrial)=1;
trialcat(ThisTarget==params.TargetIdx(1) & ~singleTrial)=2;
trialcat(ThisTarget==params.TargetIdx(2) & singleTrial)=3;
trialcat(ThisTarget==params.TargetIdx(2) & ~singleTrial)=4;


tt=(-RepDur.*2+(1:RepDur*6))./params.rasterfs;
if active,
    mtar=zeros(RepDur*6,TrialCount);
    resp=zeros(RepDur*6,TrialCount);
    ttbins=(-RepDur.*2+(1:RepDur*6));
    for trialidx=1:TrialCount,
        mtar(:,trialidx)=p(TarStartTime(trialidx)+ttbins,trialidx);
        resp(:,trialidx)=double(mtar(:,trialidx)>thresh);
    end
else
    ffr=find(trialcat==0);
    fft=find(trialcat>0);
    NewTrialCount=length(fft);
    mtar=zeros(RepDur*6,NewTrialCount);
    resp=zeros(RepDur*6,NewTrialCount);
    midr=RepDur*3;
    TarStartTime=RepDur.*4;
    ttbins=1:midr;
    for trialidx=1:NewTrialCount,
        mtar(1:midr,trialidx)=p(TarStartTime+ttbins,ffr(trialidx));
        mtar(midr+(1:midr),trialidx)=p(TarStartTime+ttbins,fft(trialidx));
    end
    TrialCount=NewTrialCount;
    trialcat=trialcat(fft);
end
[~,catidx]=sort(trialcat);

ravg=cat(1,max(mtar(1:RepDur*3,:)),max(mtar(RepDur.*3+1:end,:)));

mmtar=zeros(size(mtar,1),4);
resprate=zeros(size(mtar,1),4);
dp=zeros(4,1);
for tc=1:4,
    ff=find(trialcat==tc);
    mmtar(:,tc)=mean(mtar(:,ff),2);
    resprate(:,tc)=mean(resp(:,ff),2);
    mm=mean(ravg(:,ff),2);
    ee=std(ravg(:,ff),0,2);%./sqrt(length(ff));
    dp(tc)=diff(mm)./sqrt(mean(ee.^2));
end

figure;
subplot(2,2,1);
tmtar=mtar;
hthresh=thresh+std(mtar(:));
tmtar(tmtar>hthresh)=hthresh;
lthresh=thresh-std(mtar(:));
tmtar(tmtar<lthresh)=lthresh;
tmtar=(tmtar-lthresh)./(hthresh-lthresh);

imagesc(tt,1:size(mtar,2),tmtar(:,catidx)');
hold on,
aa=axis;
for tc=1:3,
    plot(aa(1:2),[1 1].*sum(trialcat<=tc)+0.5,'k--');
end
plot(mean(aa(1:2)).*[1 1],aa(3:4),'k--');
hold off
colormap(1-gray);
colorbar
if singleunit
    title(sprintf('cell: %s - %s',cellid, activestr));
else
    siteid=strsep(cellid,'-');
    title(sprintf('site: %s - %s',siteid{1}, activestr));
end

subplot(2,2,2);
imagesc(p');
hold on
plot(TarStartTime,1:TrialCount,'rx');
hold off

subplot(2,2,3);
plot(tt(:),resprate);
%plot(tt(:),mmtar);
hold on,
aa=axis;
plot(mean(aa(1:2)).*[1 1],aa(3:4),'k--');
%plot(tt([1 end]),[1 1].*thresh,'k--');
hold off
ylabel('response rate');

legend('tar1solo','tar1olap','tar2solo','tar2olap');

subplot(2,2,4);
bar(dp);
xlabel('tar1solo - tar1olap - tar2solo -tar2olap');
ylabel('D prime');
%plot(tt(:),resprate);
%legend('tar1solo','tar1olap','tar2solo','tar2olap');

return

if 0,
    cellids={...
        'oys022b-a1',... % 4
        'oys022c-a1',... % 2
        'oys023a-a1',... % 3
        'oys024c-a1',... % 3
        'oys025b-a1',... % 3
        'oys027b-c1',... % 2
        'oys027c-c1',... % 2
        'oys029a-a1',... % 2
        'oys029b-a1',... % 1
        'oys029c-c1',... % 2
        'oys030a-a1',... % 2
        'oys030b-a1',... % 2
        'oys031b-a1',... % 2
        'oys031c-b1',... % 1
        'oys032a-a1',... % 1
        'oys032b-a1',... % 1
        'oys033a-a1',... % 3
        'oys033b-a1',... % 4
        'oys033c-a1',... % 3
        'oys034b-a1',... % 3
        'oys034c-a1',... % 3
        'oys034d-a1',... % 2
    }
    close all
    
    dpsum=zeros(4,length(cellids),2);
    for ii=1:length(cellids),
        for active=0:1,
            dpsum(:,ii,active+1)=RDT_decoder(cellids{ii},active);
        end
    end
    
    ff=find(~isnan(dpsum(1,:,1)));
    dpsolo=cat(1,squeeze(dpsum(1,ff,:)),squeeze(dpsum(3,ff,:)));
    dpolap=cat(1,squeeze(dpsum(2,ff,:)),squeeze(dpsum(4,ff,:)));
    figure;
    subplot(2,1,1);
    plot(dpsolo(:,1),dpsolo(:,2),'.');
    hold on
    plot([0 1],[0 1],'k--');
    axis square equal
    
    subplot(2,1,2);
    plot(dpolap(:,1),dpolap(:,2),'.');
    hold on
    plot([0 1],[0 1],'k--');
    axis square equal
    
     
end
