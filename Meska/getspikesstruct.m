function spikestruct = getspikesstruct(fname);

% spikestruct = getspikes (fname);
%
% INPUT
% fname   : string containing the experiment and filename,
%           for example '225/30a07.a1-.fea' or 
%                       '/software/daqsc/data/225/30a07.a1-.fea'
% OUTPUT  
% spikestruct: a structure containing most relevant information about the
%              spikes in easy to access form, and all the rest in
%              less-easy to use form.
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

% fprintf(1,'Loading spike data...')

paramfile = [featxtdir sstr '.par'];
spikefile = [featxtdir sstr '.spk'];

% if ~exist(paramfile) | ~exist(spikefile)
% 	createtextfiles(fname, featxtdir, paramfile, spikefile);
% end
if ~exist(paramfile,'file'),error(['Cannot']),end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = paramsfromfile(paramfile);

fea2spikeparam_ver = getparamver(p);

% not needed for now--all spike files are at least version 2.0
%if (fea2spikeparam_ver < 2.0)
%	createtextfiles(fname, featxtdir, paramfile, spikefile);
%	p = paramsfromfile(paramfile);
%end

saf = -1;
hf = -1;
ncomp = -1;

numswp  = getfieldval(p,'num_swps');                % Number of sweeps per record
ddur    = getfieldval(p,'data_dur');                % Maximum data points/sweep
if fea2spikeparam_ver < 3
  numrec  = getfieldval(p,'Number of data records');  % Number of records
else
  numrec  = getfieldval(p,'Records');  % Number of records
end
stonset = getfieldval(p,'stim_onset');              % Stimulus onset
stdur   = getfieldval(p,'stim_duration');           % Stimulus duration
mf      = getfieldval(p,'mult_fact');               % Multiplication factor
if isempty(mf), mf = 1; end
if ~strcmp(ctag,'k2-') & ~strcmp(ctag,'am-') & ~strcmp(ctag,'t1-')...
 & ~strcmp(ctag,'am2'),
	hf = getfieldval(p,'upper_freq');           % Highest freq. in stimulus
	if ~isempty(hf)
		if hf < 2,
			hf = 10000*hf;
		else
			hf = 1000*hf;
		end		
	else
		hf = 0;
	end
	saf = 2*hf;                             % Sampling frequency of stim.
	if ~strcmp(ctag,'prp') & ~strcmp(ctag,'a1-'),  
	    ncomp = getfieldval(p,'num_components'); % # of components in stim.
	    if isempty(ncomp) 
	        ncomp = getfieldval(p,'harmonic_spac'); % harmonic spacing (Hz).
	        if ~isempty(ncomp) 
               ncomp = -ncomp; % ncomp < 0 implies holds -spacing in Hz.
            else
               ncomp = 101;
            end
        end
	end
else
	hf    = [];
	saf   = [];
	ncomp = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fidspike = fopen(spikefile,'r');
if fidspike == -1, pause(1); fidspike = fopen(spikefile);end

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
paramdata = p;
% fprintf(1,'                     ... loaded.\n')

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createtextfiles(fname, featxtdir, paramfile, spikefile);
	fprintf(1,'\n');
	if isunix
		cmdstr = ['~/matlab/spikeutils/fea2spikeparams ',fname,' ',featxtdir];
		%if exist(['/software/coda/users/daqsc/',fname],'file')
			cmdstr = ['(tap esps; ',cmdstr,')']
		%else
		%	cmdstr = ['rsh raga "',cmdstr,'"']
		%end
		[a,b] = unix(cmdstr);
		if a | ~(exist(paramfile) | exist(spikefile))
			error('Could not create create spike & parameter files.')
		end
		fprintf(1,'\n')
	else
		error(['Could not find file ',fname])
	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = paramsfromfile(paramfile);
	fidparam = fopen(paramfile,'r');
	if fidparam == -1, pause(1), fidparam = fopen(paramfile);end
	p = fscanf(fidparam,'%c');
	fclose(fidparam);
