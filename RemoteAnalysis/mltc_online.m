% function mltc_online(mfile,channel,unit[1],h,options);
% 
% h - handle of figure where plot should be displayed(default, new figure)
%
% valid options fields
%    .rasterfs [=1000]
%    .sigthreshold [=4]
%    .datause [='Both'] % ie, all data, targets and references
%
function mltc_online(mfile,channel,unit,h,options);

if ~exist('channel','var'),
    channel=1;
end
if ~exist('unit','var'),
    unit=1;
end
if ~exist('h','var'),
    h=figure;
    drawnow;
else
   axes(h);
end
if ~exist('options','var'),
    options=[];
end
options.channel=channel;
options.unit=unit;
options.PreStimSilence=0;
options.PostStimSilence=0.06;  %60 ms


fprintf('mltc_online: Analyzing channel %d\n',channel);
[r,tags]=raster_load(mfile,channel,unit,options);

%if ~isempty(findstr(mfile,'spk.mat')),
%   [r,tags,trialset,exptevents]=loadspikeraster(mfile,options);
%else
%   [r,tags,mfiletrialset,exptevents]=loadevpraster(mfile,options);
%end
r=squeeze(mean(r,2))';  %average acorss repetitions

for i=1:length(tags)
    [tem,smat(i,1),smat(i,2)]=strread(tags{i},'%s%f%f','delimiter',',');
end
freq=unique(smat(:,1));
dbL=unique(smat(:,2));
for i=1:length(dbL)
    for j=1:length(freq)
        rmat(i,j,:)=r(find(smat(:,1)==freq(j) & smat(:,2)==dbL(i)),:);
    end
end
rwin1=[10 60];  %onset
rwin2=[10 size(rmat,3)-60];  %while stimuli duration
rwin3=[-49 0]+size(rmat,3);  %offset

TuningCurve_ML(rmat,freq,dbL,1,1,channel,rwin1);
TuningCurve_ML(rmat,freq,dbL+min(dbL)-5,1,1,channel,rwin2);
TuningCurve_ML(rmat,freq,dbL+min(dbL)*2-10,1,1,channel,rwin3);
axis tight;
set(gca,'fontsize',6,'clim',[-1 1]*5);
set(gca,'xtick',freq(1:3:end));
set(gca,'ytick',dbL(:),'xscale','log');
title(sprintf('%s, ch=%d',mfile,channel));

%=============================================
function [TC,q10]=TuningCurve_ML(rmat,freq,db,bsz,sm,channel,rwin);
%rmat     response matrix intensity x frequency
%sm       smooth (1-yes, 0-no)
%freq     frequency (log scale)
%db       intensity (dB)
%bsz      bin size
%
%pby @ 7-29-2010
if nargin<5, sm=1; end
if nargin<7, rwin=[10 60]; end
if nargin<4 && ~isstruct(rmat)
    bsz=10;    
    if nargin<3
        db=[1:size(rmat,1)]*5;
        if nargin<2
            freq=1:size(rmat,2); end
    end
end
if isstruct(rmat) && isfield(rmat,'tc')  %onset tuning
    db=rmat.dbL;
    freq=rmat.freq;
    rmat=rmat.tc{1}; end
bas=sum(rmat(:,:,1:round(10/bsz)),3);   %baseline taken from first 10 mesec
basline=[mean(bas(:)) std(bas(:))];  %mean and standard deviation of basline
if basline(2)==0
    bas=mean(rmat(:,:,round(rwin(1)/bsz)+1:round(rwin(2)/bsz)),3);
    basline(2)=std(bas(:)); end

if sm==1
    rmat=smooth3(rmat,'gaussian',3); end
rmat=sum(rmat(:,:,round(rwin(1)/bsz)+1:round(rwin(2)/bsz)),3)/round(rwin(2)/10-rwin(1)/10);  %onset response from 50 msec window
rmat=(rmat-basline(1))/basline(2);  %normalized
if ~ishold, hold on; end

[cc,hh]=contourf(freq,db,rmat,[-4 -2 -1 0 1 2 4]);   %contour plot: threshold defined as 2*sd

set(hh,'ButtonDownFcn',['AX = gca; cFIG = ',n2s(100000+channel),'; figure(cFIG); '...
    'NAX = copyobj(AX,cFIG); set(NAX,''Position'',[0.1,0.1,0.85,0.85]); axis on;']);

  c=0;
  try
c=contourc(freq,db,rmat,[-2 2]); %computing contour line with hight=2*sd and -2*sd
  catch
    disp('***Contour was not computable***')
  end
  
n=1;CL=[];  %extracting all contour lines
while n<size(c,2)
    CL=[CL;n+1 n+c(2,n) c(2,n) c(1,n)];
    n=c(2,n)+n+1;
end
if isempty(CL)  %not tuned
    TC=[]; q10=[];
    return; end
CL=CL(CL(:,4)==2,:);           %threshold line (excitory)
CL=sortrows(CL,3);     %sort rows base on the length of the line
TC=c(:,CL(end,1):CL(end,2))';        %Tuning Curve- the longest contour line
if size(TC,1)<5  %not responding
    TC=[]; q10=[]; return; end

mindb=find(TC(:,2)==min(TC(:,2)));
if length(mindb)<2 && min(TC(:,2))==min(db) && size(CL,1)>1  %find another half of tuning - the 2nd longest line
    TC2=c(:,CL(end-1,1):CL(end-1,2))';
    TC=[TC;NaN NaN;TC2]; end

if ~ishold, hold on; end
p=plot(TC(:,1),TC(:,2),'m');
set(p,'linewidth',2);   %highlight the tunning curve

%computing Q_10
cf=TC(TC(:,2)==min(TC(:,2)),:);  %CF and threshod
cf=mean(cf,1);    %if cutoff at lowest dB level, take average of the freq as CF.
db10=cf(2)+10;  %10 db above theshold
if db10>max(TC(:,2))
    q10=[NaN NaN NaN cf];   %no q10 computation
else
    try,
        tem=find(TC(:,2)<=db10);
        tem=sortrows([tem(:) TC(tem,1:2)],[2 -3]);
        
        LF=interp1(TC(tem(1,1)+[-1:1],2),TC(tem(1,1)+[-1:1],1),db10);
        HF=interp1(TC(tem(end,1)+[-1:1],2),TC(tem(end,1)+[-1:1],1),db10);
        l=line([LF HF],[1 1]*db10); set(l,'linewidth',2);
        q10=cf(1)/abs(HF-LF);  %Q_10 dB
        text(max([LF HF]),db10+2,num2str(q10,'Q\\_10dB=%4.3f'),'fontsize',6);
        q10=[q10 LF HF cf];
    catch, q10=[NaN NaN NaN cf];
    end
end
addgrid(0,cf(1),'w');
addgrid(1,cf(2),'w');
text(cf(1),cf(2)-2,num2str(cf+[0 -max(db)],'BF=%3.1f Hz, Th=%3.1f dB'),'fontsize',6);
xlabel('Frequency');
ylabel('Intensity (dB)');



