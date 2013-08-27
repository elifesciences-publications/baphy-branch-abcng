function params=multistim_init(globalparams);
% function params=multistim_init(globalparams);
% 
% set up parameters specific to multiple interleaved stimulus module for baphy. conforms to baphy
% "initcommand" standard
%
% created SVD 2010-04-13 -- ripped off of dms_init.m
%

% paths should have been set by baphy_set_path
global BAPHYHOME

if isfield (globalparams,'Ferret') & ~isempty(globalparams.Ferret),
    pfile=[BAPHYHOME filesep 'Config' filesep 'multistimparams.' globalparams.Ferret '.mat'];
else
    pfile=[BAPHYHOME filesep 'Config' filesep 'multistimparams.mat'];
end

if exist(pfile,'file'),
    disp([mfilename ': Loading saved parameters from ' pfile '...']);
    load(pfile);
else
    params=[];
end

yn='';

while strcmp(yn,'Cancel') || isempty(yn),
    
    params=mainmenu(params);
    
    if isempty(params),
        return
    end
    
    yn=questdlg('Save current params?','Multi-Stim','Yes','No','Cancel','Yes');
end

%
% hard-coded params (for now?)
%
params.voltage=5;      % volume scaling -- max=80 dbSPL
%params.voltage=10.^(-10./20) .*5;      % volume scaling -- max=70 dbSPL

params.volpersec=globalparams.PumpMlPerSec.Pump;   % SVD recalibrated 2006-03-30
params.fs=40000;     % default sound sampling frequency

% initialize counters

if strcmp(yn,'Yes'),
    save(pfile,'params');
end

%=============================================================
function params=mainmenu(params)

ii=0;

% do these four things for each parameter:
ii=ii+1;
pset(ii).text='Outpath ("X"=test, no save)';
pset(ii).name='outpath';
pset(ii).default=['c:' filesep 'data' filesep];

%to generate tone list:
%round(exp(linspace(log(500),log(10000),3)))
% old (10): [500 700 975 1350 1900 2650 3700 5150 7200 10000]
% atten: [0.95 0.95 0.95 0.95 0.9 0.85 0.8 0.75 0.7 0.7]
to.descriptor='ComplexChord';
ii=ii+1; pset(ii).text='Stimulus count'; pset(ii).name='stimcount'; pset(ii).default=1;
ii=ii+1; pset(ii).text='Stimulus #1'; pset(ii).style='sound'; pset(ii).name='Stim1'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Stimulus #2'; pset(ii).style='sound'; pset(ii).name='Stim2'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Stimulus #3'; pset(ii).style='sound'; pset(ii).name='Stim3'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Stimulus #4'; pset(ii).style='sound'; pset(ii).name='Stim4'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Stimulus #5'; pset(ii).style='sound'; pset(ii).name='Stim5'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Sound level (dB)'; pset(ii).name='soundlevel'; pset(ii).default=70;
ii=ii+1; pset(ii).text='Repetition count'; pset(ii).name='repcount'; pset(ii).default=5;
%ii=ii+1; pset(ii).text='Test mode'; pset(ii).style='checkbox'; pset(ii).name='skip_targets'; pset(ii).default=0;

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
vv=ParameterGUI(pset,'Multi-stim parameters');

if length(vv)<length(pset),
    params=[];
else
    for ii=1:length(pset),
        params=setfield(params,pset(ii).name,vv{ii});
    end
    params.runclass={};
    for ii=1:params.stimcount,
        sii=['Stim',num2str(ii)];
        params.runclass{ii}=ReferenceRunClass(params.(sii).descriptor,params.(sii));
    end

end
