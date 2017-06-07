function [SnoozeBits,EarlyBits,HitBits,IndicesLst,IntegrationTimes,LickTimes,OutcomeArray,ToCLst,RefSliceNbLst] = TMG_DissectBehaOutcomes(exptparams,ConsecutiveSnoozeNb)

if nargin<2; ConsecutiveSnoozeNb = []; end

if length(exptparams) == 1
    [SnoozeBits,EarlyBits,HitBits,IndicesLst,IntegrationTimes,LickTimes,OutcomeArray,ToCLst,RefSliceNbLst] = ReturnBehaviorVariables(exptparams,ConsecutiveSnoozeNb);
else % Run over multiple sessions
    SnoozeBits = []; EarlyBits = []; HitBits = []; IndicesLst = []; IntegrationTimes = []; LickTimes = []; OutcomeArray = []; ToCLst = []; RefSliceNbLst = [];
    for SessionNum = 1:length(exptparams)
        [SnoozeBits_SingleSession,EarlyBits_SingleSession,HitBits_SingleSession,IndicesLst_SingleSession,IntegrationTimes_SingleSession,...
            LickTimes_SingleSession,OutcomeArray_SingleSession,ToCLst_SingleSession,RefSliceNbLst_SingleSession] = ...
            ReturnBehaviorVariables(exptparams{SessionNum},ConsecutiveSnoozeNb);
        SnoozeBits = [SnoozeBits SnoozeBits_SingleSession];
        EarlyBits = [EarlyBits EarlyBits_SingleSession];
        HitBits = [HitBits HitBits_SingleSession];
        IndicesLst = [IndicesLst IndicesLst_SingleSession];
        IntegrationTimes = [IntegrationTimes IntegrationTimes_SingleSession];
        LickTimes = [LickTimes LickTimes_SingleSession];
        OutcomeArray = [OutcomeArray OutcomeArray_SingleSession];
        ToCLst = [ToCLst OutcomeArray_SingleSession];
        RefSliceNbLst_SingleSession = [RefSliceNbLst RefSliceNbLst_SingleSession];
    end
end


function [SnoozeBits,EarlyBits,HitBits,IndicesLst,IntegrationTimes,LickTimes,OutcomeArray,ToCLst,RefSliceNbLst] = ReturnBehaviorVariables(exptparams,ConsecutiveSnoozeNb)

o = ReconstructSoundObject(exptparams);
SilenceDuration = exptparams(1).TrialObject(1).ReferenceHandle(1).Duration+exptparams(1).TrialObject(1).ReferenceHandle(1).PreStimSilence+exptparams(1).TrialObject(1).ReferenceHandle(1).PostStimSilence+get(o,'PreStimSilence');
OutcomeArray = {exptparams(1).Performance.Outcome};
SnoozeBits = strcmp(OutcomeArray,'SNOOZE');

if nargin<2 || isempty(ConsecutiveSnoozeNb)
    ExcludeSnoozeBits = logical(ones(1,length(SnoozeBits)));
else
    % Exclude consecutive Snooze
    SnoozeStr = num2str(SnoozeBits);
    SnoozeStr(strfind(SnoozeStr,' ')) = [];
    ExcludeSnooze = strfind(SnoozeStr,repmat('1',1,ConsecutiveSnoozeNb));
    for ii=1:ConsecutiveSnoozeNb; ExcludeSnooze = [ExcludeSnooze ExcludeSnooze+1]; end
    ExcludeSnooze = unique(ExcludeSnooze); ExcludeSnooze( ExcludeSnooze>length(SnoozeStr) ) = [];
    ExcludeSnoozeBits = logical( ones(1,length(SnoozeBits)) );
    ExcludeSnoozeBits(unique(ExcludeSnooze)) = 0;
end
OutcomeArray = {exptparams(1).Performance(ExcludeSnoozeBits).Outcome};
SnoozeBits = strcmp(OutcomeArray,'SNOOZE');
HitBits = strcmp(OutcomeArray,'HIT');
EarlyBits = strcmp(OutcomeArray,'EARLY');
IndicesLst = [exptparams(1).Performance(ExcludeSnoozeBits).TargetIndices];
IntegrationTimes = cell2mat({exptparams(1).Performance(ExcludeSnoozeBits).TarWindow}')';
IntegrationTimes = IntegrationTimes(1,:)-SilenceDuration;
if isfield(exptparams(1).Performance,'ToC')
    ToCLst = [exptparams(1).Performance(ExcludeSnoozeBits).ToC]-SilenceDuration;
    RefSliceNbLst = [exptparams(1).Performance(ExcludeSnoozeBits).RefSliceCounter];
else
    ToCLst = IntegrationTimes;
    RefSliceNbLst = [];
end
LickTimes = [exptparams(1).Performance(ExcludeSnoozeBits).LickTime]-SilenceDuration;
