function dbFixData(parmfile)
% this script specifies which entries should be sent to the database
%
% svd -  borrowed from nima's PrepareDatabaseData code, 2011
          
LoadMFile(parmfile);

% for the parameters, get the fields of TrialObject, BehaviorObject,
% Reference and Target:
Parameters  = [];
Performance = [];
fields = exptparams.TrialObject.UserDefinableFields;
Parameters.TrialObject = '______________';
Parameters.TrialObjectClass = exptparams.TrialObjectClass;
for cnt1 = 1:3:length(fields)
    Parameters.(['Trial_' fields{cnt1}]) = exptparams.TrialObject.(fields{cnt1});
end
fields = exptparams.BehaveObject.UserDefinableFields;
Parameters.BehaveObject = '______________';
Parameters.BehaveObjectClass = exptparams.BehaveObjectClass;
for cnt1 = 1:3:length(fields)
    Parameters.(['Behave_' fields{cnt1}]) = exptparams.BehaveObject.(fields{cnt1});
end
RefHandle = exptparams.TrialObject.ReferenceHandle;
if ~isempty(RefHandle)
    Parameters.Reference = '______________';
    Parameters.ReferenceClass = RefHandle.descriptor;
    fields = RefHandle.UserDefinableFields;
    for cnt1 = 1:3:length(fields)
        Parameters.(['Ref_' fields{cnt1}]) = RefHandle.(fields{cnt1});
    end
end
TarHandle = exptparams.TrialObject.TargetHandle;
if ~isempty(TarHandle)
    Parameters.Target = '______________';
    Parameters.TargetClass = TarHandle.descriptor;
    fields = TarHandle.UserDefinableFields;
    for cnt1 = 1:3:length(fields)
        Parameters.(['Tar_' fields{cnt1}]) = TarHandle.(fields{cnt1});
    end
end
fields = fieldnames(Parameters);
for cnt1 = 1:length(fields)
    if ischar(Parameters.(fields{cnt1}))
        Parameters.(fields{cnt1}) = strrep(Parameters.(fields{cnt1}),'<','^<');
        Parameters.(fields{cnt1}) = strrep(Parameters.(fields{cnt1}),'>','^>');
    end
end
% and now, the performance data:
if isfield(exptparams,'Performance')
    Performance = exptparams.Performance(end);
    fields = fieldnames(Performance);
    for cnt1 = 1:length(fields)
        if ischar(Performance.(fields{cnt1}))
            Performance.(fields{cnt1}) = strrep(Performance.(fields{cnt1}),'<','^<');
            Performance.(fields{cnt1}) = strrep(Performance.(fields{cnt1}),'>','^>');
        end
        % also, round the numbers:
        if isnumeric(Performance.(fields{cnt1}))
            Performance.(fields{cnt1}) = round(Performance.(fields{cnt1})*100)/100;
        end
    end
end
        
% don't keep previous data
dbWriteData(globalparams.rawid, Parameters, 0, 0);
dbWriteData(globalparams.rawid, Performance, 1, 0);
