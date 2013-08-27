function [summary1, summary2, reffreqvec, reflengthvec,timevec,lickcell,skipflag] = broadAttn_behav_ana(fn)
%behavior performance analysis
%fn   full file name

summary1 = [];
summary2 = [];
reffreqvec = [];
reflengthvec = [];
timevec = [];
lickcell = [];
skipflag = 0;

p0='M:\daq\';
if nargin==0
    [fn,p]=uigetfile([p0 '*.m']);
else
    [p,fn,ex]=fileparts(fn);
    fn=[fn ex];
    p=[p '\'];
end

evpfile=[p fn(1:end-2) '.evp'];
if ~exist(evpfile)
    evpfile=[p '\tmp\' fn(1:end-2) '.evp'];
    if ~exist(evpfile)
        disp(['evp file ',fn(1:end-2),'.evp not found, skip this file!']);
        skipflag = 1;
        return; end
end

LoadMfile([p fn]); %load parameters: exptparams, globalparams and exptevents
para.fname=fn;
exptype=exptparams.BehaveObjectClass;  %passive or task
TrialObj=exptparams.TrialObject;
Performance=exptparams.Performance;
BehavObj=exptparams.BehaveObject;

%%
% Lick time lines
pretrailtime = TrialObj.PreTrialSilence;
refStruct = TrialObj.ReferenceHandle;
prestimtime = refStruct.PreStimSilence;
toneDur = refStruct.ToneDur;
gapDur = refStruct.GapDur;
refbustcount = refStruct.BurstCnt;
rewardtime = BehavObj.ResponseWindow;
timevec = (pretrailtime + prestimtime) + [0,refbustcount*(toneDur+gapDur),max(refbustcount)*(toneDur+gapDur) + rewardtime];

[spikecount, auxcount, TotalTrial, spikefs, auxfs] = evpgetinfo(evpfile);
TotalTrial=exptparams.TotalTrials;
if TotalTrial<=1
    disp(['Too little trials, discard this session:' fn]);
    skpflag = 2;
    return;
end

RefLick=[];TarLick=[]; Freq=[];
Freq = zeros(TotalTrial, 6);
for cnt1 = 1:TotalTrial
    [ref,tar]=get_trialEvent(exptevents,cnt1);
    refnum(cnt1)=length(ref);
        [rS,STrialIdx,LICK,ATrialIdx]=evpread(evpfile, [], 1,cnt1);
        LICK=LICK';
        [value, posi] = find(LICK == 1);
        if isempty(posi)
            Freq(cnt1,6) = NaN;
        else
            Freq(cnt1,6) = posi(1) / auxfs;
        end
    %     for i=1:refnum(cnt1)
    %         t0=round(ref(i).StartTime*auxfs);  %samples
    %         RefLick=[RefLick; cnt1 i LICK(round([-200:1600]*auxfs/1000)+t0)];
    %     end
    temp=strread(ref(1).Note,'%s','delimiter',',');
    twofreq = temp{2};
    twofreq = ceil(str2num(twofreq(2:end-1)));
    Freq(cnt1,1) = twofreq(1);
    Freq(cnt1,2) = twofreq(2);
    reflen = temp{4};
    Freq(cnt1,3) = str2num(reflen(2:end));
    
    %     if ~isempty(tar)
    %         t0=round(tar.StartTime*auxfs);  %samples
    %         TarLick=[TarLick; cnt1 i+1 LICK(round([-200:1600]*auxfs/1000)+t0)];
    %
    %         temp=strread(tar.Note,'%s','delimiter',',');
    %         Freq(cnt1,2)=str2num(temp{2});
    %     else
    %         Freq(cnt1,2)=NaN;
    %     end
    performindex = Performance(cnt1).ThisTrial;
    falsealarmrate = Performance(cnt1).FalseAlarm;
    if strcmp(performindex, 'Ineffective')
        Freq(cnt1,4)=1;
    elseif strcmp(performindex, 'Hit')
        Freq(cnt1,4)=2;
    else
        Freq(cnt1,4)=3;
    end
    Freq(cnt1,5)=falsealarmrate;
end

%%
%omit last several trials of miss
lastperindex = Freq(cnt1,4);
while (lastperindex == 3) && (cnt1 > 0)
    Freq(cnt1,4) = 4;
    cnt1 = cnt1 - 1;
    lastperindex = Freq(cnt1,4);
end

%%
%summarize trail performance with different frequency
reffreqvec = unique(Freq(:,1));
reflengthvec = unique(Freq(:,3));
summary1 = zeros(3,length(reffreqvec)*length(reflengthvec));
summary2 = zeros(3,length(reffreqvec));
lickcell = cell(1,length(reffreqvec)*length(reflengthvec));
for i = 1 : length(reffreqvec)
    for j = 1 : length(reflengthvec)
        [posi, value] = find(Freq(:,1) == reffreqvec(i) & Freq(:,3) == reflengthvec(j));
        if isempty(posi)
            lickcell((i - 1)*length(reflengthvec) + j) = [];
            continue
        end
        partmatrix = Freq(posi,:);
        lickvectmp = partmatrix(:,6)';
        [posi, value] = find(lickvectmp ~= NaN);
        if ~isempty(posi)
            lickcell{(i - 1)*length(reflengthvec) + j} = lickvectmp(value);
        else
            lickcell((i - 1)*length(reflengthvec) + j) = [];
        end
        for k = 1 : 3
            [p1, v1] = find(partmatrix(:,4) == k);
            summary1(k, (i - 1)*length(reflengthvec) + j) = length(p1);
        end
    end
    summary2(:,i) = sum(summary1(:, (i - 1)*length(reflengthvec)+1 : (i - 1)*length(reflengthvec) + length(reflengthvec)),2);    
end

% figure(2);
% 
% plot(mean(RefLick(:,3:end)),'b'); % total ref
% hold on;
% tarfreq=unique(Freq(:,2));
% cc={'r-','m-','g-','r:','m:','g:'};
% for i=1:length(tarfreq)
%     plot(mean(TarLick(Freq(:,2)==tarfreq(i),3:end)),cc{i});
% end
% legend([{'ref'};cellstr(num2str(tarfreq))]);
% line([200 200],[0 1]);
% title(strrep(fn,'_','-'));
% set(gca,'xtick',0:200:1800,'xticklabel',[-200:200:1600]);
% xlabel('Time from onset (ms)');
% ylabel('Average lick rate');

%%============================
function [ref,tar]=get_trialEvent(events,trial);
Trials=[events.Trial];
events=events(find(Trials==trial));

ref=[];tar=[];
for i=1:length(events)
    if strfind(lower(events(i).Note),'stim')==1 & isempty(strfind(lower(events(i).Note),'torc'))
        if strfind(lower(events(i).Note),'reference') | strfind(lower(events(i).Note),'sham')
            ref=[ref;events(i)];
        elseif strfind(lower(events(i).Note),'target')
            tar=[tar;events(i)];
        elseif strfind(lower(events(i).Note),'off')
            tar=[];   %the trial was stopped before target
        else
            disp(events(i).Note);
        end
    end
end

