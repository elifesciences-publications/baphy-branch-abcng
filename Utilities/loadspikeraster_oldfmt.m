% function r=loadspikeraster(spkfile,chanNum[=1],unitNum[=1],samplerate[=1000],
%                            window[=[0 0]],psthonly[=0]);
%
% load spike raster from sorted spike file
%   spike raster stored in NSL standard format:
%
%   time X sweep(rep) X rec(different stim)
% this routine reshapes raster into time*rec X rep
% (or if psthonly==1, averages to get a time*rec X 1 vector)
%
% inputs:
%   requires spikefile generated using meska
%   samplerate in Hz
%   window: clip out seconds window(1)-window(2) from each trial
%           (for data with onset & delay times)
%
% returns:
%   r is time X nsweeps X nrec matrix
% 
% created SVD 8/12/05
%
function r=loadspikeraster_oldfmt(spkfile,chanNum,unitNum,samplerate,window,psthonly);

if iscell(spkfile)
    % the user has passed the name of the mfile, parse it here:
    mfile = spkfile{2};
    spkfile = spkfile{1};
else
    mfile = [];
end
if ~exist('chanNum','var'),
   chanNum=1;
end
if ~exist('unitNum','var'),
   unitNum=1;
end
if ~exist('samplerate','var'),
   samplerate=1000;
end
if ~exist('window','var'),
   window=[0 0];
elseif length(window)==1,
   window(2)=0;
end
if ~exist('psthonly','var'),
   psthonly=0;
end

fprintf('loading %s chan=%d unit=%d samplerate=%d Hz\n',...
        basename(spkfile),chanNum,unitNum,samplerate);

% newf==0: old format
% newf==1: new format
newf=isempty(who('Ncl','-FILE',spkfile));
%newf = ~isempty(findstr(spkfile,'_'));

spikeinfop = load(spkfile);

mf=samplerate;          % output samples per sec
mfOld=spikeinfop.rate;  % input samples per sec

if mfOld<100,
   mfOld=mfOld.*1000;
end

if ~newf
    if chanNum>1,
       error([mfilename,': chanNum>channels!']);
    end
    units = spikeinfop.Ncl;
    if unitNum>units,
       error([mfilename,': unitNum>units!']);
    end
    rawSpikes = spikeinfop.unitSpikes{unitNum}(1:2,:);
elseif length(spikeinfop.sortinfo)<16,
   if isempty(spikeinfop.sortinfo{chanNum}),
      error([mfilename,': chanNum>channels!']);
   end
   
   units= spikeinfop.sortinfo{chanNum,end}(end).Ncl;
   if unitNum>units,
      error([mfilename,': unitNum>units!']);
   end
   rawSpikes = spikeinfop.sortinfo{chanNum,end}(unitNum).unitSpikes;
   
else
   if isempty(spikeinfop.sortinfo{chanNum}),
      error([mfilename,': chanNum>channels!']);
   end
   
   units= spikeinfop.sortinfo{chanNum}{1}(1).Ncl;
   if unitNum>units,
      error([mfilename,': unitNum>units!']);
   end
   rawSpikes = spikeinfop.sortinfo{chanNum}{1}(unitNum).unitSpikes;
end

% remove spikes that fall outside of the requested time window (for
% dealing with onset delays)


%~isempty(mfile) && 
if ~isfield(spikeinfop,'stonset') && sum(window)>0 || ...
      (isfield(spikeinfop,'fname') && ~isempty(strfind(spikeinfop.fname,'_clk')))
   if isempty(mfile)
      
      % guess mfile name:
      disp('guessing mfile from celldb');
      [pp,bb,ee]=fileparts(spkfile);
      [pp1,pp2]=fileparts(pp);
      [pp3,bb1,bb2]=fileparts(bb);
      sql=['SELECT * FROM gDataRaw where parmfile like "',bb1,'%"'];
      rawdata=mysql(sql);
      if length(rawdata)>0,
         mfile=[rawdata(1).resppath rawdata(1).parmfile];
         if onseil==1,
            mfile=strrep(mfile,'/auto/data/',...
                         [getenv('HOME'),'/data/'])
         end
         if ~exist(mfile,'file'),
            mfile=[];
         end
      else
         mfile=[];
      end
      
      if isempty(mfile),
         error('Need to read some params from the mfile. Please also pass the mfilename');
      end
   end
   [StStim,StimParam] = loadtorc(mfile);
   spikeinfop.stonset = StimParam.stonset/1000;   
   spikeinfop.stdur = StimParam.stdur/1000;
   if isfield(StimParam,'ClickStart')
       spikeinfop.ClickStart = StimParam.ClickStart;
   end
%    
%    tt=basename(spikeinfop.fname);
%    tt=strsep(tt,'.');
%    tt=tt{1};
%    dd=ls(['/afs/glue.umd.edu/department/isr/labs/nsl/projects/daqsc/*/*/',...
%            tt,'.m']);
%    if length(dd)>1,
%       ff=min(findstr('.m',dd));
%       dd=dd(1:ff+1);
%    else
%       error('can''t find m-file');
%    end
%    
%    [bb,pp]=basename(dd);
%    addpath(pp);
%    stmtlist = ([ 'torcList = ' tt '(''reference'');']);eval(stmtlist);
%    rmpath(pp);
%    torcListtag= torcList.tag;
%    spikeinfop.stonset = get(torcListtag, 'Onset');
%    spikeinfop.stdur = get(torcListtag, 'Duration');
end

if window(1),
   window(1)=spikeinfop.stonset;
end
if window(2);
   window(2)=spikeinfop.stonset+spikeinfop.stdur;
end
if isfield(spikeinfop,'ClickStart')
    window(2) = spikeinfop.stonset + (spikeinfop.stdur*spikeinfop.ClickStart);
end
cellid=basename(spkfile);
if strcmp(cellid(1:3),'c02') | strcmp(cellid(1:3),'c03') | ...
      strcmpi(cellid(1),'J') | strcmpi(cellid(1),'o'),
   disp('old file: shifting responses forward 20 ms');
   rawSpikes(2,:)=rawSpikes(2,:)+mfOld.*0.02;
   rawSpikes=rawSpikes(:,find(rawSpikes(2,:)>0));
end

npoint=spikeinfop.npoint;

if window(2)>0,
   rawSpikes=rawSpikes(:,find(rawSpikes(2,:)<window(2)*mfOld));
   npoint=window(2)*mfOld;
end
if window(1)>0,
   rawSpikes=rawSpikes(:,find(rawSpikes(2,:)>window(1)*mfOld));
   rawSpikes(2,:)=rawSpikes(2,:)-window(1)*mfOld;
   npoint=npoint-window(1)*mfOld;
end

% rescale times to be in units of bin
rawSpikes(2,:) = max(floor(min(rawSpikes(2,:),spikeinfop.npoint)*mf/mfOld),1);

r = sparse(rawSpikes(2,:),rawSpikes(1,:),1,...
           round(npoint/mfOld*mf),...
           spikeinfop.nsweep*spikeinfop.nrec);
r= reshape(full(r),[size(r,1) spikeinfop.nsweep spikeinfop.nrec]);

if psthonly==-1,
   % do nothing?
   
elseif psthonly,
   % time/trial all in one long vector
   r=(mean(r,2));
   r=r(:);
else
   % time/record X rep
   r=permute(r,[1 3 2]);
   r=reshape(r,size(r,1)*spikeinfop.nrec, spikeinfop.nsweep);
end
