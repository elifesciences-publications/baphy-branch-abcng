function [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname,unitNum,edata, tlist, chanNum);
% [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] =
%                                              getspikes(fname,unitNum,mfReq);
% [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] =
%                                              getspikes(fname,unitNum);
% [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] =
%                                              getspikes(fname);
% or
%
% nUnit = getspikes(fname,[]);
%
% INPUT
% fname   : string containing the experiment and filename,
%           for example '225/30a07.a1-.fea' or 
%                       '/software/daqsc/data/225/30a07.a1-.fea'
% unitNum : which unit to return the spike data for. If not specified, 1
%           is assumed, but a warning is displayed if there are more.
%           If [], then only nUnit is returned, and no other data--this
%           is the preferred method of finding nUnit. If 0
%           then this is the same as not specifying.
% mfReq   : the requested mf (see below), since for sorted spikes the mf
%           available 20, but typically only mf = 5 or mf = 1 is
%           sufficient. The default is 5.
%
% OUTPUT  
% spdata   : 3-D matrix containing spike data
% ddur     : stimulus duration (ms)
% stonset  : stimulus onset (ms)
% stdur    : stimulus duration (ms)
% hf       : highest frequency in stimulus
% saf      : sampling freq of waveform
% ncomp    : number of components in stimulus
% mf       : multiplication factor ( = sampling frequency in ms)
% paramdata: a (proprietary) data structure containing all 
%             parameters & their values
% nUnit    : number of units found in recording
%
% BYPRODUCTS & REQUIREMENTS
% Reads in 2 text files in subdirectories of the 'featxt' directory:
%
%  parameter file (e.g. 225/30a07.a1-.par)
%  spikes file    (e.g. 225/30a07.a1-.spk)
%
% On a unix system, the 'featxt' directory will be created if it 
% does not exist.
%
% If the files do not exist, and this is running on a unix system,
% the shell script '~/matlab/spikeutils/fea2spikeparams' will create them.
%
% In addition, the function file 'getfieldval.m' is required.

[featxtdir,sstr,ctag] = spikefile(fname);
%featxtdir

% fprintf(1,'Loading spike data...')
chanNum= str2num(chanNum);
profile = fullfile(featxtdir, [sstr,'.m']);
spkfile = fullfile(featxtdir, [sstr,'.spk']);

spikematfileloaded = 0;

if ~exist(spkfile)
	%createtextfiles(fname, featxtdir, parfile, spkfile);
	matspkfile = [spkfile, '.mat'];
		if exist(matspkfile,'file')
			[tmppath,tmpname,tmpext]=fileparts(matspkfile);
			holdpath = pwd;
			cd(tmppath)
			spikeinfo = load([tmpname,tmpext]);
			cd(holdpath)
			spikematfileloaded = 1;
		end
	
	if ~spikematfileloaded
		[uifile,uipath]=uigetfile('*.m', ['Please find ',profile])
		if ~uifile, error('Get file cancelled'), end
		[featxtdir,sstr,ctag] = spikefile(fullfile(uipath,uifile));
		profile = fullfile(featxtdir, [sstr,'.m']);
		spkfile = fullfile(featxtdir, [sstr,'.spk']);
		if ~exist(profile) | ~exist(spkfile)
			error('Can''t find spike or parameter file')
		end
	end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('unitNum'), unitNum = 0; end

if ~spikematfileloaded
  nUnitFound = 1;
else
    if strcmpi(lower(class(spikeinfo.sortinfo{1})),'struct')
        nUnitFound = spikeinfo.sortinfo{1}(1).Ncl;%Changed to account for unit numbers
    else
        nUnitFound = spikeinfo.sortinfo{chanNum}{1}(1).Ncl;
    end
  if ~isempty(unitNum)
	if (unitNum==0) & nUnitFound > 1
		warning(['There are multiple units (',num2str(nUnitFound),...
			  ') for this recording'])
	end
	if (unitNum==0); unitNum = 1;end
  end
end

if isempty(unitNum) %this signals that only nUnit is returned, nothing else
  spdata = nUnitFound;
  return
else
  nUnit = nUnitFound;
end

fea2spikeparam_ver = get(edata,'Version');

% not needed for now--all spike files are at least version 2.0
%if (fea2spikeparam_ver < 2.0)
%	createtextfiles(fname, featxtdir, parfile, spkfile);
%	p = paramsfromfile(parfile);
%end

saf = -1;
hf = -1;
ncomp = -1;

numswp  = get(edata,'Repetitions');                % Number of sweeps per record
numrec  = get(tlist.tag,'index');  % Number of records
stonset = get(tlist.tag, 'Onset');
stdur = get(tlist.tag, 'Duration');
rate = get(edata, 'AcqSamplingFreq');
delay = get(tlist.tag,'Delay');
ddur = stonset+stdur+delay;

if ~strcmp(ctag,'k2-') & ~strcmp(ctag,'am-') & ~strcmp(ctag,'t1-')...
 & ~strcmp(ctag,'am2'),
    thandle = tlist.handle(1);
	hf = get(thandle,'Upper frequency component');        % Highest freq. in stimulus
	if isempty(hf)
		hf = 0;
	end
	saf = get(edata,'StimSamplingFreq');                             % Sampling frequency of stim.
else
	hf    = [];
	saf   = [];
	ncomp = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~spikematfileloaded
	fidspike = fopen(spkfile,'r');
	if fidspike == -1, pause(1); fidspike = fopen(spkfile);end
	
	% Initialization
	
	rec = 1;     % Value of current record
	if fea2spikeparam_ver < 3
	  swp = 0;     % Value of sweep
	else
	  swp = 1;     % Value of sweep
	end
	swdat = [];  % Spike times for individual sweep
	spdata = zeros(ddur*mf,numswp,numrec);
	
	while 1   % While there is data left to read
	  sdat= fgetl(fidspike);		   % Read a line of data (string)
	  if ~isstr(sdat), break, end        % If EOF, end program
	  ndat = str2num(sdat);
	  if fea2spikeparam_ver < 3
		if isempty(ndat)
		  swp=swp+1;
		  if swp > numswp
			swp = 1;
			rec = rec + 1;
		  end
		else
		  nonzerosentries = ndat(find(ndat~=0));
		  spdata(nonzerosentries,swp,rec) =  1;
		  if ~isempty(find(diff(nonzerosentries))) % check for double entries
			duplicates = ndat(find([nonzerosentries 0]==[0 nonzerosentries]));
			for mm=duplicates
			  spdata(mm,swp,rec)=spdata(mm,swp,rec)+1;
			end
		  end
		end
	  else
		if isempty(ndat)
		  swp = 1;
		  rec = rec + 1;
		else
		  swp=swp+1;
		  nonzerosentries = ndat(find(ndat~=0))+stonset*mf;
		  spdata(nonzerosentries,swp,rec) =  1;
		  if ~isempty(find(diff(nonzerosentries))) % check for double entries
			duplicates = ndat(find([nonzerosentries 0]==[0 nonzerosentries]));
			for mm=duplicates
			  spdata(mm,swp,rec)=spdata(mm,swp,rec)+1;
			end
		  end
		end 
	  end
	end
	
	% fprintf(1,'\n')
	fclose (fidspike);
else
    if strcmpi(lower(class(spikeinfo.sortinfo{1})),'struct')
        tempTmpl = spikeinfo.sortinfo{1}(unitNum).Template;
        rawSpikes = spikeinfo.sortinfo{1}(unitNum).unitSpikes;
    else
        tempTmpl = spikeinfo.sortinfo{chanNum}{1}(unitNum).Template;
        rawSpikes = spikeinfo.sortinfo{chanNum}{1}(unitNum).unitSpikes;
    end
    rawSpikes(2,:) = max(floor(min(rawSpikes(2,:),spikeinfo.npoint)/(rate/1000)),1); % rescale times
    spdataSp = sparse(rawSpikes(2,:),rawSpikes(1,:),1,round(spikeinfo.npoint/(rate/1000)),spikeinfo.nsweep*spikeinfo.nrec);
	spdata = reshape(full(spdataSp), [size(spdataSp,1),spikeinfo.nsweep, spikeinfo.nrec]);
end

% rawSpikes = spikeinfo.unitSpikes{unitNum}(1:2,:);
% 	rawSpikes(2,:) = max(floor(min(rawSpikes(2,:),spikeinfo.npoint)*mf/mfOld),1); % rescale times
% for testing of bursts only--remove when done.
if exist('usebursts')
	burstbin = 11;
	burstnum = 3;
	for mm = 1:size(spdata,3)
		for nn = 1:size(spdata,2)
			for pp = 1:size(spdata,1)-burstbin
				if spdata(pp,nn,mm) > 0
					bursttest = (sum(spdata(pp:pp+burstbin,nn,mm)) >= burstnum);
					if bursttest
						spdata(pp,nn,mm) = burstnum;
						spdata(pp+1:pp+burstbin,nn,mm) = 0*[1:burstbin];
					else
						spdata(pp,nn,mm) = 0;
					end
				end
			end
			spdata(pp+1:size(spdata,1),nn,mm) = 0*[pp+1:size(spdata,1)];
		end
	end
end


% fprintf(1,'                     ... loaded.\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Not used any more
% 
% function createtextfiles(fname, featxtdir, parfile, spkfile);
% 	fprintf(1,'\n');
% 	if isunix
% 		cmdstr = ['~/matlab/spikeutils/fea2spikeparams ',fname,' ',featxtdir];
% 		%if exist(['/software/coda/users/daqsc/',fname],'file')
% 			cmdstr = ['(tap esps; ',cmdstr,')']
% 		%else
% 		%	cmdstr = ['rsh raga "',cmdstr,'"']
% 		%end
% 		[a,b] = unix(cmdstr);
% 		if a | ~(exist(parfile) | exist(spkfile))
% 			error('Could not create create spike & parameter files.')
% 		end
% 		fprintf(1,'\n')
% 	else
% 		error(['Could not find file ',fname])
% 	end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function p = paramsfromfile(parfile);
% 	fidparam = fopen(parfile,'r');
% 	if fidparam == -1, pause(1), fidparam = fopen(parfile);end
% 	p = fscanf(fidparam,'%c');
% 	fclose(fidparam);
