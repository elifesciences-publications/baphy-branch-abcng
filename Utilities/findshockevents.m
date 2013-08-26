%function [shockstart,shocktrials,shocknotes,shockstop]=...
%    findshockevents(exptevents,exptparams);
function [shockstart,shocktrials,shocknotes,shockstop]=...
    findshockevents(exptevents,exptparams)

[shockstart,shocktrials,shocknotes,shockstop]=...
    evtimes(exptevents,'BEHAVIOR,SHOCKON');
if isfield(exptparams,'BehaveObject') &&  ...
      isfield(exptparams.BehaveObject,'TarStimulation') &&  ...
      exptparams.BehaveObject.TarStimulation==1,
    
    [shockstart2,shocktrials2,shocknotes2,shockstop2]=...
        evtimes(exptevents,'STIMULATION,ON');
    if isempty(shockstart2),
        %exptparams(1).BehaveObject(1).TarStimulationOnset = 0;
        %exptparams(1).BehaveObject(1).TarStimulationDur = 1;
        [shockstart2,shocktrials2,shocknotes2,shockstop2]=...
            evtimes(exptevents,'*Target');
    end
    
    for ii=1:length(shockstart2),
        if strcmpi(shocknotes2{ii}(1:4),'Stim'),
            shockstart=cat(1,shockstart,shockstart2(ii));
            shocktrials=cat(1,shocktrials,shocktrials2(ii));
            shocknotes=cat(1,shocknotes,shocknotes2(ii));
            shockstop=cat(1,shockstop,shockstop2(ii));
        end
    end
end
