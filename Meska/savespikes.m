function savespikes(source,destin,st,spiketemp,spk,sorter,sflag,comments,extras,abaflag,xaxis,sortparameters);
% savespikes(source,destin,st,spiketemp,spk,sorter,sflag,comments,extras,abaflag,xaxis,sortparameter);
%
% source - m-file name
% destin - output file (minus .spk.mat extension)
% st - N x 1 vector: time of all superthreshold events?
% spiketemp - U x N matrix with waveform for each eventtimes entry
% spk - cellarray of vectors with subset of eventtimes for each unit
% sorter - string name of sort person
% sflag - 1 if primary
% comments - any other note
% extras : critical things to inlcude in extras:
%    .exptevents;
%    .StimTagNames;
%    .trialstartidx;
%    .tolerance;
%    .chanNum --- A STRING!!;
%    .npoint; -- samples in last trial??
%    .expData = tagid;
%    .expData = set(.expData,'AcqSamplingFreq',sampfreq)
% abaflag - should always be 0?
% xaxis - offsets of spike window, such that U=xaxis(2)-xaxis(1)+1;
%

if ~exist('xaxis','var') || isempty(xaxis)    xaxis = [1 size(spiketemp,1)]; end
if ~exist('sortparameters') sortparameters = []; end
if ~isfield(sortparameters,'SaveSorter') sortparameters.SaveSorter = 0; end

eData=extras.expData;
chanNum=extras.chanNum;
npoint=extras.npoint;

sortinfo= cell(extras.numChannels,1);
chanNum= str2num(chanNum);

% only add .spk.mat if it's not there yet
savfile=strrep(destin,'.spk.mat','');
savfile = [savfile '.spk.mat'];

fprintf('savespikes.m: Saving spike data to: %s...\n',savfile)

rate = get(eData, 'AcqSamplingFreq');
seplocs = findstr(filesep,source);
fname = [source(seplocs(end-1)+1:end) '.evp'];

% backward compatibility with old system of saving spikes already unwound
% into "correct" order
if ~isfield(extras,'trialstartidx') | isempty(extras.trialstartidx),
    baphy_fmt=0;
else
    baphy_fmt=1;
end

if baphy_fmt,
    nrec=length(extras.trialstartidx);
    tts=[extras.trialstartidx;extras.trialstartidx(end)+npoint+1];
    nsweep=1;
    stonset=0;
    npoint=diff(tts);
    stdur=npoint./rate;
    delay=0;
    ngensweep=nrec;
else
    tList=extras.torcList;
    nrec = get(tList.tag,'index');
    nsweep = get(eData,'Repetitions');
    stonset = get(tList.tag, 'Onset');
    stdur = get(tList.tag, 'Duration');
    delay = get(tList.tag,'Delay');
    ddur = stonset+stdur+delay;
    if ~abaflag
        clear npoint;
        npoint = ddur*rate;
    else
        npoint= round(npoint);
    end
    
    ngensweep = nsweep * nrec;
end

Ncl = 0;
maxunit=0;
for abc = 1:length(spk),
    Ncl = Ncl + 1;
    
    if ~isempty(spk{abc})
        maxunit=Ncl;
        if baphy_fmt,
            unitSpikes{Ncl}=[];
            for trialidx=1:nrec,
                ffidx=find(spk{abc}>=tts(trialidx) & spk{abc}<tts(trialidx+1));
                unitSpikes{Ncl}=[unitSpikes{Ncl},[ones(1,length(ffidx)).*trialidx;(spk{abc}(ffidx)-tts(trialidx)+1)']];
            end
        elseif ~abaflag
            unitSpikes{Ncl}(1,:) = ceil(spk{abc}/npoint);
            unitSpikes{Ncl}(2,:) = mod(spk{abc}-1,npoint)+1;
        else
            for x= 1:length(npoint)
                trialdur(x)= sum(npoint(1:x)*nsweep);
            end
            
            for y= 1:length(spk{abc})
                trialindx= find(trialdur>spk{abc}(y));
                if trialindx(1) == 1
                    unitSpikes{Ncl}(1,y)= (max(trialindx(1)-1,0)*nsweep)+ceil((spk{abc}(y))/npoint(trialindx(1)));
                    unitSpikes{Ncl}(2,y)= mod(spk{abc}(y),npoint(trialindx(1)))+(~mod(spk{abc}(y),npoint(trialindx(1)))*npoint(trialindx(1)));
                else
                    unitSpikes{Ncl}(1,y)= (max(trialindx(1)-1,0)*nsweep)+ceil((spk{abc}(y)-trialdur(max(trialindx(1)-1,0)))/npoint(trialindx(1)));
                    unitSpikes{Ncl}(2,y)= mod((spk{abc}(y)-trialdur(max(trialindx(1)-1,0))),npoint(trialindx(1)))+(~mod((spk{abc}(y)-trialdur(max(trialindx(1)-1,0))),npoint(trialindx(1)))*npoint(trialindx(1)));
                end
            end
        end
        
        Template(:,Ncl) = mean(spiketemp(:,find(ismember(st,spk{abc}))),2);
        
        temp = spiketemp(:,find(ismember(st,spk{abc})));
        env{Ncl} = 1:size(spiketemp,1);
        env{Ncl}(2,:) = Template(:,Ncl) + 3*std(temp,[],2);
        env{Ncl}(3,:) = Template(:,Ncl) - 3*std(temp,[],2);
        
    end
end
Ncl=maxunit;

mfilename = source;

s=struct('sorter',sorter,'primary',sflag, 'comments',comments,...
    'unitSpikes',unitSpikes, 'Template', Template, 'env', env, 'Ncl',Ncl, 'xaxis', xaxis,...
    'sortparameters',sortparameters,'mfilename',mfilename);

if exist(savfile,'file'),
    loadstmt = (['load ' savfile ' sortinfo sortextras;']);
    eval(loadstmt);
    if length(sortinfo)<extras.numChannels,
        sortinfo{extras.numChannels}=[];
    end
    if ~isempty(sortinfo{chanNum})
        if sflag & sortinfo{chanNum}{1}(1).primary
            if sortparameters.SaveSorter == 0
                ButtonName=questdlg([sortinfo{chanNum}{1}(1).sorter ' is saved as primary sorter, do you still want to be the primary sorter?'], ...
                    'Primary Sorter?',  'Yes','No', 'Yes');
                switch ButtonName,
                    case 'Yes',
                        sortinfo{chanNum}{length(sortinfo{chanNum})+1} =sortinfo{chanNum}{1};
                        sortinfo{chanNum}{1} = s;
                    case 'No',
                        sortinfo{chanNum}{length(sortinfo{chanNum})+1} =s;
                end
            else
                sortinfo{chanNum}{length(sortinfo{chanNum})+1} =sortinfo{chanNum}{1};
                sortinfo{chanNum}{1} = s;
            end
        elseif ~sortinfo{chanNum}{1}(1).primary
            sortinfo{chanNum}{length(sortinfo{chanNum})+1} =sortinfo{chanNum}{1};
            sortinfo{chanNum}{1} = s;
        else
            sortinfo{chanNum}{length(sortinfo{chanNum})+1} =s;
        end
    else
        sortinfo{chanNum}{1} = s;
    end
else
    sortinfo{chanNum}{1} = s;
end

% save(savfile,'unitSpikes','paramdata','fname','rate','nrec','nsweep',...
%     'npoint','ngensweep','Ncl','Template','env','xaxis')
% Channel{chanNum}= sortinfo;
extras=rmfield(extras,'expData');
if isfield(extras,'torcList'),
    extras=rmfield(extras,'torcList');
end
if ~exist('sortextras','var'),
    sortextras={};
end

pp=fileparts(savfile);
if ~exist(pp,'dir'),
    mkdir(pp);
end

if baphy_fmt,
    exptevents=extras.exptevents;
    extras=rmfield(extras,'exptevents');
    StimTagNames=extras.StimTagNames;
    trialstartidx=extras.trialstartidx;
    tolerance=extras.tolerance;
    sortextras{chanNum}=extras;
    save(savfile,'fname','rate','nrec','nsweep','npoint', 'sortinfo', ...
        'stonset','stdur','delay','baphy_fmt',...
        'exptevents','StimTagNames','trialstartidx','tolerance','sortextras');
else
    sortextras{chanNum}=extras;
    save(savfile,'fname','rate','nrec','nsweep','npoint', 'sortinfo', ...
        'stonset','stdur','delay','baphy_fmt','sortextras');
end

