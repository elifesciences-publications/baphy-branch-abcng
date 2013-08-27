function exptparams=replicate_behavior_analysis(parmfile,savetodb)

%baphy_set_path
if ~exist('savetodb','var'),
    savetodb=0;
end

%parmfile='/auto/data/daq/Portabello/training2012/Portabello_2012_11_20_TSP_5.m';
[pathname,basename]=fileparts(parmfile);

LoadMFile(parmfile);
% if its a RefTar module, create the objects:
if strcmpi(globalparams.Module,'Reference Target')
    
    % create the behavior object:
    BehaveObject = feval(exptparams.BehaveObjectClass);
    fields = get(BehaveObject,'UserDefinableFields');
    BehaveObject = ObjectSetFields(BehaveObject, fields, exptparams.BehaveObject);
    % also, generate the reference and target objects:
    RefObject = feval(exptparams.TrialObject.ReferenceClass);
    fields = get(RefObject,'UserDefinableFields');
    RefObject = ObjectSetFields(RefObject, fields, exptparams.TrialObject.ReferenceHandle);
    TrialObject = feval(exptparams.TrialObjectClass);
    fields = get(TrialObject, 'UserDefinableFields');
    TrialObject = ObjectSetFields(TrialObject, fields, exptparams.TrialObject);
    
    TrialObject = set(TrialObject, 'ReferenceHandle',RefObject);
    if ~strcmpi(exptparams.TrialObject.TargetClass,'none')
        TarObject = feval(exptparams.TrialObject.TargetClass);
        fields = get(TarObject, 'UserDefinableFields');
        TarObject = ObjectSetFields(TarObject, fields, exptparams.TrialObject.TargetHandle);
        TrialObject = set(TrialObject, 'TargetHandle',TarObject);
    end
    exptparams.TrialObject = TrialObject;
    exptparams.BehaveObject = BehaveObject;
end
exptparams = rmfield(exptparams,'Performance');
exptparams.OfflineAnalysis = 1;

HW.params = globalparams.HWparams;
evpfile=[];
if exist([pathname filesep 'tmp'] , 'dir'),
    evpfile = [pathname filesep 'tmp' filesep basename '.evp'];
    if ~exist(evpfile,'file'), evpfile=[];end
end
if isempty(evpfile)
    evpfile = [pathname filesep basename '.evp'];
    if ~exist(evpfile,'file'), error('evp file not found');end
end
% now, for each trial, create the stimulus event and read the evp data.
% Then, call the BehaviorDisplay method of the behavior object with the
% appropriate data (lick and stim events)
% first, the mfile:
[spikecount, auxcount, TotalTrial, spikefs, auxfs] = evpgetinfo(evpfile);
include = ''; 
ThisTrial = 0;
exptparams = rmfield(exptparams,'ResultsFigure');
for cnt1 = 1:TotalTrial
    % Stim events are between TrialStart and Last PostStimSilence events:
    [t1,t2,t3,t4,StimStart] = evtimes(exptevents,'TrialStart',cnt1);
    [t1,t2,t3,t4,StimEnds] = evtimes(exptevents,'PostStimSilence*',cnt1);
    StimEvents = exptevents(StimStart+1:StimEnds(end));
    pas=0; 
    if ~isempty(strfind(StimEvents(end).Note,'Target')) && isempty(strfind(StimEvents(end).Note,include)) ...
            && ~isempty(include)
        pas=1;
    end
    if ~pas
        ThisTrial=ThisTrial+1;
        [rS,STrialIdx,Lick,ATrialIdx]=evpread(evpfile, [], 1,cnt1);
        % why are they sometimes empty??
        if isempty(Lick), warning(['empty ' num2str(cnt1)]);
            Lick = zeros(ceil(1+exptevents(StimEnds(end)).StopTime*auxfs),1);
        end
        exptparams = PerformanceAnalysis(exptparams.BehaveObject, HW, StimEvents, ...
            globalparams, exptparams, ThisTrial, Lick);
        % disabled display per Block
        if ~mod(cnt1,exptparams.TrialBlock)
            exptparams = BehaviorDisplay(exptparams.BehaveObject, HW, StimEvents, globalparams, ...
                exptparams, ThisTrial, Lick, []);
        end
    end
end
exptparams.TotalTrials = ThisTrial;
exptparams = BehaviorDisplay(exptparams.BehaveObject, HW, StimEvents, globalparams, ...
    exptparams, ThisTrial, [], []);
set(gcf,'Name',basename);
drawnow;

if savetodb,
    disp('saving perf data to database');
    [Parameters, Performance] = PrepareDatabaseData ( globalparams, exptparams);
    %dbWriteData(globalparams.rawid, Parameters, 0, 0);  % this is parameter and dont keep previous data
    dbWriteData(globalparams.rawid, Performance, 1, 0); % this is performance and dont keep previous data
    
    SaveBehaviorFigure(globalparams,exptparams);
    
    disp('DONE!');
else
    disp('skipping save to db');
end

function o = ObjectSetFields ( o,fields,values)
for cnt1 = 1:3:length(fields)
    try % since objects are changing,
        o = set(o,fields{cnt1},values.(fields{cnt1}));
    catch
        %warning(['property ' fields{cnt1} ' can not be found, using default']);
    end
end
