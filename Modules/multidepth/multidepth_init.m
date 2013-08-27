function params=multidepth_init(globalparams);
% function params=multidepth_init(globalparams);
% 
% set up parameters specific to multidepth module for baphy. conforms to baphy
% "initcommand" standard
%
% created SVD 2008-02-29 (leap day!) -- ripped off of dms_init.m
%

% paths should have been set by baphy_set_path.m
global BAPHYHOME
if isfield (globalparams,'Ferret') && ~isempty(globalparams.Ferret),
    pfile=[BAPHYHOME filesep 'Config' filesep 'multidepth.' globalparams.Ferret '.mat'];
else
    pfile=[BAPHYHOME filesep 'Config' filesep 'multidepth.mat'];
end

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS

CELLDB_USER='david';
CELLDB_ANIMAL=lower(globalparams.Ferret);
CELLDB_SITEID=globalparams.SiteID;

% clear the distractor pseudo-randomizer list in case the number of
% distracters has changed since the last dms_run
global idx_set
idx_set=[];

if exist(pfile,'file'),
    disp([mfilename ': Loading saved parameters from ' pfile '...']);
    load(pfile);
else
    params=[];
end

% if site doesn't exist yet, force rawid to be -1 (new)
[rawdata,site,celldata,rcunit,rcchan]=dbgetsite(globalparams.SiteID);
if isempty(site),
    disp('new site, forcing raw file to NEW');
    params.rawid=-1;
end
    
yn='';
while strcmp(yn,'Cancel') || isempty(yn),
    params=mainmenu(params);
    if isempty(params),
        return
    end
    yn=questdlg('Save current params?','DMS','Yes','No','Cancel','Yes');
end

%
% hard-coded params (for now?)
%
params.voltage=5;      % volume scaling -- max=80 dbSPL
params.fs=44000;     % default sound sampling frequency
params.runclass='DEP';

if strcmp(yn,'Yes'),
    save(pfile,'params');
end

%=============================================================
function params=mainmenu(params)

ii=0;

% do these four things for each parameter:
ii=ii+1;
pset(ii).text='Save path ("X"=no save)';
pset(ii).name='outpath';
pset(ii).default=['e:' filesep];

% critical new thing: rawid pointing to existing raw file (or -1 to signal
% create new rawfile)
ii=ii+1; pset(ii).text='Raw data file'; pset(ii).style='rawid'; pset(ii).name='rawid'; pset(ii).default=-1;

to.descriptor='ComplexChord';
ii=ii+1; pset(ii).text='Sound object'; pset(ii).style='sound'; pset(ii).name='ReferenceObject'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Current depth (microns)'; pset(ii).name='depth'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Pre-trial silence (sec)'; pset(ii).name='pretrial_silence'; pset(ii).default=0.5;
ii=ii+1; pset(ii).text='Post-trial silence (sec)'; pset(ii).name='posttrial_silence'; pset(ii).default=0.5;
ii=ii+1; pset(ii).text='Overall attenuation (dB)'; pset(ii).name='ref_atten'; pset(ii).default=15;
ii=ii+1; pset(ii).text='Refs per trial'; pset(ii).name='ref_per_trial'; pset(ii).default=1;
ii=ii+1; pset(ii).text='Inter-trial interval (sec)'; pset(ii).name='isi'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Repetitions per set'; pset(ii).name='N'; pset(ii).default=10;

% set default values to values last entered by user
for ii=1:length(pset),
    if ~isfield(pset,'style') | isempty(pset(ii).style)
        pset(ii).style='edit';
    end
    if isfield(params,pset(ii).name),
        pset(ii).default=getfield(params,pset(ii).name);
    end
end

% call the parameter gui
vv=ParameterGUI(pset,'Mulit-depth parameters');

if length(vv)<length(pset),
    params=[];
else
    for ii=1:length(pset),
        params=setfield(params,pset(ii).name,vv{ii});
    end
end
