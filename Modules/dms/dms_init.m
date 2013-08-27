function params=dms_init(globalparams)
% function params=dms_init(globalparams);
% 
% set up parameters specific to dms module for baphy. conforms to baphy
% "initcommand" standard
%
% created SVD 2005-11-02 -- ripped out of dms0.m development
%

% paths should have been set by startup.m
global BAPHYHOME

if isfield (globalparams,'Ferret') && ~isempty(globalparams.Ferret),
    pfile=[BAPHYHOME filesep 'Config' filesep 'dmsparams.' globalparams.Ferret '.mat'];
else
    pfile=[BAPHYHOME filesep 'Config' filesep 'dmsparams.mat'];
end

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

params.cumres=[];
params.totalreward=0;

yn='';

while strcmp(yn,'Cancel') | isempty(yn),
    
    params=mainmenu(params);
    
    if isempty(params),
        return
    end
    
    yn=questdlg('Save current params?','DMS','Yes','No','Cancel','Yes');
end

%
% former soft parameters.  now removed to hard-coded unless they become
% useful again
%
params.targ_atten_frac=0;
params.no_atten_frac=0;
params.rwfrac=1.0;

%
% hard-coded params (for now?)
%
params.voltage=5;      % volume scaling -- max=80 dbSPL
%params.voltage=10.^(-10./20) .*5;      % volume scaling -- max=70 dbSPL

params.volpersec=globalparams.PumpMlPerSec.Pump;   % SVD recalibrated 2006-03-30
params.presec=1.0;   % record presec worth of data before trial start
params.fs=80000;     % default sound sampling frequency

% initialize counters
params.res=[];    % record basic performance
params.bstat={};  % record detailed behavior
params.bfs=50;    % behavior sampling frequency
params.ttlsec=1.0;
%params.tonecount=length(params.freqs);
params.tonecount=1;
params.tonetriglick=zeros(params.bfs*params.ttlsec,params.tonecount,2);
params.ttlcount=zeros(params.bfs*params.ttlsec,params.tonecount,2);
params.setcount=0;
params.tstring={};
for ii=1:params.tonecount
    params.tstring{ii}=sprintf('%2d',ii);
end
params.jitter_db=0;

if strcmp(params.ReferenceObject.descriptor,'AMNoise') ||...
        strcmp(params.ReferenceObject.descriptor,'AMTone'),
    params.runclass='AMD';
else
    params.runclass='DMS';
end

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

%to generate tone list:
%round(exp(linspace(log(500),log(10000),3)))
% old (10): [500 700 975 1350 1900 2650 3700 5150 7200 10000]
% atten: [0.95 0.95 0.95 0.95 0.9 0.85 0.8 0.75 0.7 0.7]
to.descriptor='ComplexChord';
ii=ii+1; pset(ii).text='Reference object'; pset(ii).style='sound'; pset(ii).name='ReferenceObject'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Target object'; pset(ii).style='sound'; pset(ii).name='TargetObject'; pset(ii).default=to;
ii=ii+1; pset(ii).text='Swap reference target'; pset(ii).style='popupmenu'; pset(ii).name='SwapRefTar';pset(ii).default={'No|Yes|Random',1};
ii=ii+1; pset(ii).text='Pre-trial silence (sec)'; pset(ii).name='nolicksilence'; pset(ii).default=0.5;
ii=ii+1; pset(ii).text='Reference mean (sec)';  pset(ii).name='refmean'; pset(ii).default=0.5;pset(ii).tooltip='This is the average length of the references';
ii=ii+1; pset(ii).text='Reference stdev (sec)';  pset(ii).name='refstd'; pset(ii).default=0.0;
ii=ii+1; pset(ii).text='References count weights';  pset(ii).name='refweights'; pset(ii).default=[.5 .5];
ii=ii+1; pset(ii).text='Trial len minimum (sec)'; pset(ii).name='nolick'; pset(ii).default=0.3;
ii=ii+1; pset(ii).text='Average extra variable trial len (sec)'; pset(ii).name='nolickstd'; pset(ii).default=0.15;
ii=ii+1; pset(ii).text='Reference atten. start (dB below 80)'; pset(ii).name='dist_atten'; pset(ii).default=[15];
ii=ii+1; pset(ii).text='Reference atten. final (dB below 80)'; pset(ii).name='dist_atten_final'; pset(ii).default=[15];
ii=ii+1; pset(ii).text='Target atten. (dB below 80)'; pset(ii).name='targ_atten'; pset(ii).default=15;
ii=ii+1; pset(ii).text='Repeat single reference'; pset(ii).style='checkbox'; pset(ii).name='single_dist'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Reference after target'; pset(ii).style='checkbox'; pset(ii).name='ref_after_target'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Target rep count'; pset(ii).name='targ_rep_count'; pset(ii).default=1;
ii=ii+1; pset(ii).text='Trials between target switch'; pset(ii).name='blocksize'; pset(ii).default=100;
ii=ii+1; pset(ii).text='Response win start (sec)'; pset(ii).name='startwin'; pset(ii).default=0.1;
ii=ii+1; pset(ii).text='Response win duration (sec)'; pset(ii).name='respwin'; pset(ii).default=0.9;
ii=ii+1; pset(ii).text='"PRE-ward" duration (sec)'; pset(ii).name='startrwdur'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Reward delay jitter (sec)'; pset(ii).name='rwjitter'; pset(ii).default=0.0;
ii=ii+1; pset(ii).text='Reward duration (sec)'; pset(ii).name='rwdur'; pset(ii).default=0.75;
ii=ii+1; pset(ii).text='Punish sound atten. (dB below 80)'; pset(ii).name='punishvol'; pset(ii).default=25;
ii=ii+1; pset(ii).text='Punish timeout (sec)'; pset(ii).name='timeout'; pset(ii).default=2.0;
ii=ii+1; pset(ii).text='Inter-trial interval (sec)'; pset(ii).name='isi'; pset(ii).default=0.2;
ii=ii+1; pset(ii).text='Number of cue trials'; pset(ii).name='cuecount'; pset(ii).default=3;
ii=ii+1; pset(ii).text='Trials in each set'; pset(ii).name='N'; pset(ii).default=20;
ii=ii+1; pset(ii).text='Overlay ref/tar'; pset(ii).style='checkbox'; pset(ii).name='overlay_reftar'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Use catch stim'; pset(ii).style='checkbox'; pset(ii).name='use_catch'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Use lick'; pset(ii).style='checkbox'; pset(ii).name='use_lick'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Enable light'; pset(ii).style='checkbox'; pset(ii).name='use_light'; pset(ii).default=1;
ii=ii+1; pset(ii).text='Cycle missed targets'; pset(ii).style='checkbox'; pset(ii).name='cycle_miss'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Skip non-targets'; pset(ii).style='checkbox'; pset(ii).name='skip_targets'; pset(ii).default=0;
ii=ii+1; pset(ii).text='Simu-lick'; pset(ii).style='popupmenu'; pset(ii).name='simulate_touch'; pset(ii).default={'No|Yes|Yes-Always correct',1};
%ii=ii+1; pset(ii).text='Use old DMS'; pset(ii).style='checkbox'; pset(ii).name='use_dms_old'; pset(ii).default=1;

%ii=ii+1; pset(ii).text='*Tone start (Hz)';  pset(ii).name='freqs'; pset(ii).default=[500 650 900 1200 1600 2100 2800 3800 5000 6700 9000 12000 15500];
%ii=ii+1; pset(ii).text='*Tone dest (Hz)';  pset(ii).name='freqe'; pset(ii).default=[500 650 900 1200 1600 2100 2800 3800 5000 6700 9000 12000 15500];
%ii=ii+1; pset(ii).text='*Reference freq (Hz)';  pset(ii).name='freqref'; pset(ii).default=[0];
%ii=ii+1; pset(ii).text='*Tone modulation freq'; pset(ii).name='modfreq'; pset(ii).default=[0 0 0 0 0 0 0 0 0 0 0 0 0];
%ii=ii+1; pset(ii).text='*Tone attenuation (dB)'; pset(ii).name='toneamp'; pset(ii).default=0;
%ii=ii+1; pset(ii).text='Stim jitter (dB std)'; pset(ii).name='jitter_db'; pset(ii).default=0;
%ii=ii+1; pset(ii).text='Target atten frac'; pset(ii).name='targ_atten_frac'; pset(ii).default=0;
%ii=ii+1; pset(ii).text='Ref no atten frac'; pset(ii).name='no_atten_frac'; pset(ii).default=0;
%ii=ii+1; pset(ii).text='*Tone duration (sec)'; pset(ii).name='dur'; pset(ii).default=0.2;
%ii=ii+1; pset(ii).text='*Gap duration (sec)'; pset(ii).name='gapdur'; pset(ii).default=0.1;
%ii=ii+1; pset(ii).text='*Target index(es)'; pset(ii).name='targidx0'; pset(ii).default=4;
%ii=ii+1; pset(ii).text='*Target chord index(es)'; pset(ii).name='targidx1'; pset(ii).default=[];
%ii=ii+1; pset(ii).text='*Chord atten (dB)'; pset(ii).name='chord_atten'; pset(ii).default=100;
%ii=ii+1; pset(ii).text='Catch index(es)'; pset(ii).name='catchidx'; pset(ii).default=9;
%ii=ii+1; pset(ii).text='Cue tone atten (dB)'; pset(ii).name='cue_atten'; pset(ii).default=100;
%ii=ii+1; pset(ii).text='Reward fraction'; pset(ii).name='rwfrac'; pset(ii).default=1.0;
%to.descriptor='Tone';
%ii=ii+1; pset(ii).text='*Distracter object'; pset(ii).style='sound'; pset(ii).name='ReferenceSound'; pset(ii).default=to;

% set default values to values last entered by user
for ii=1:length(pset),
    if ~isfield(pset,'style') || isempty(pset(ii).style)
        pset(ii).style='edit';
    end
   if strcmp(pset(ii).name,'simulate_touch'),
       ss='No|Yes|Yes-Always correct';
       sss=strsep(ss,'|',0);
       try,
         vv=find(strcmp(sss,strtrim(getfield(params,pset(ii).name))));
         pset(ii).default={ss,vv};
       catch,
           disp('setting simulate_touch to default');
       end
         
   elseif strcmp(pset(ii).name,'SwapRefTar'),
       ss='No|Yes|Random';
       sss=strsep(ss,'|',0);
       try,
           vv=find(strcmp(sss,strtrim(getfield(params,pset(ii).name))));
           pset(ii).default={ss,vv};
       catch
           disp('setting SwapRefTar to default');
       end
   elseif isfield(params,pset(ii).name),
      pset(ii).default=getfield(params,pset(ii).name);
   end

end

% call the parameter gui
vv=ParameterGUI(pset,'DMS parameters');


if length(vv)<length(pset),
    params=[];
else
    for ii=1:length(pset),
        if strcmp(pset(ii).style,'popupmenu'),
            params=setfield(params,pset(ii).name,strtrim(vv{ii}));
        else
            params=setfield(params,pset(ii).name,vv{ii});
        end
    end
    params.ReferenceSound=[];
end

