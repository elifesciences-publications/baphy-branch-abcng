function [evpdata,nrec,nsweep,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata] = getevpdata(fname,datatype);
% [evpdata,nrec,nsweep,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata] = getevpdata(fname,datatype);
%
% INPUT
% fname   : string containing the experiment and filename,
%           for example '225/30a07.a1-.fea' or 
%                       '/software/daqsc/data/225/30a07.a1-.par'
% OUTPUT  
% evpdata  : 3-D matrix containing evoked potential data
% ddur     : stimulus duration (ms)
% stonset  : stimulus onset (ms)
% stdur    : stimulus duration (ms)
% hf       : highest frequency in stimulus
% saf      : sampling freq of waveform
% ncomp    : number of components in stimulus
% mf       : multiplication factor
% paramdata: a (proprietary) data structure containing all 
%             parameters & their values
%
% BYPRODUCTS & REQUIREMENTS
% Reads in 2 text files in subdirectories of the 'featxt' directory:
%
%  parameter file (e.g. 225/30a07.a1-.par)
%  evoked potential file (e.g. 225/30a07.a1-.evp)
%
% In addition, the function file 'getfieldval.m' is required.

fname = strrep(strrep(strrep(fname,'.fea','.evp'),'.spk','.evp'),'.par','.evp');
[featxtdir,sstr,ctag] = spikefile(fname);

paramfile = [featxtdir sstr '.par'];
evpotfile = [featxtdir sstr '.evp'];

if ~exist(paramfile) | ~exist(evpotfile)
	error(['Cannot find ',paramfile,' or ',evpotfile'.'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = paramsfromfile(paramfile);

fea2spikeparam_ver = getparamver(p);

saf = -1;
hf = -1;
ncomp = -1;

nsweep  = getfieldval(p,'num_swps');                % Number of sweeps per record
ddur    = getfieldval(p,'data_dur');                % Maximum data/sweep
if fea2spikeparam_ver < 3
  nrec  = getfieldval(p,'Number of data records');  % Number of records
else
  nrec  = getfieldval(p,'Records');  % Number of records
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

if datatype > 0
	datapersweep = ddur * mf;
	switch datatype
	  case 3,
		fprintf(1,'Allocating memory\n')
		% evpdata = zeros(datapersweep,nsweep,nrec); % too big, gives error:
		            % Product of dimensions is greater than maximum integer.
		evpdatas = cell(1,nrec);
		for rec = 1:nrec
		  %disp(['Record ',num2str(rec),'/',num2str(nrec)])
		  evpdatas{rec} = zeros(datapersweep,nsweep);
		end
	  case 2,
		fprintf(1,'Allocating memory\n')
		evpdatasum = zeros(datapersweep,nrec);
	  case 1,
		evpdatasumsum = zeros(datapersweep,1);
	end
	
	fidevpot = fopen(evpotfile,'r');
	if fidevpot == -1, pause(1); fidevpot = fopen(evpotfile);end
	fprintf(1,'Loading evoked potential data...\n')
	for rec = 1:nrec
	  disp(['Record ',num2str(rec),'/',num2str(nrec)])
	  for sweep = 1:nsweep
		[evp1,readcount] = fread(fidevpot,datapersweep,'int16');
		if readcount ~= datapersweep,error('Not enough data in file'),end
		switch datatype
		  case 3,
			evpdatas{rec}(:,sweep) = evp1;
		  case 2,
			evpdatasum(:,rec) = evpdatasum(:,rec) + evp1;
		  case 1,
			evpdatasumsum =evpdatasumsum + evp1;
		end
	  end
	end
	switch datatype
	  case 3,
		evpdata = evpdatas;
	  case 2,
		evpdata = evpdatasum/nsweep;
	  case 1,
		evpdata = evpdatasumsum/(nsweep*nrec);
	end
	fprintf(1,'                             ...evoked potential data loaded\n')
	fclose (fidevpot);
else
	evpdata = [];
end

paramdata = p;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = paramsfromfile(paramfile);
	fidparam = fopen(paramfile,'r');
	if fidparam == -1, pause(1), fidparam = fopen(paramfile);end
	p = fscanf(fidparam,'%c');
	fclose(fidparam);
