function [Parameters, Performance] = PrepareDatabaseData(globalparams, exptparams)
% this script specifies which entries should be sent to the database
%
%

% Nima, 2006

% for the parameters, get the fields of TrialObject, BehaviorObject,
% Reference and Target:
Parameters  = [];
Performance = [];

if isobject(exptparams.TrialObject),
   % Process data from raw baphy world, alternative cass (below) is that
   % the field values have all been converted to structures for saving to
   % baphy parm file
   fields = get(exptparams.TrialObject,'UserDefinableFields');
   Parameters.TrialObject = '______________';
   Parameters.TrialObjectClass = class(exptparams.TrialObject);
   for cnt1 = 1:3:length(fields)
      Parameters.(['Trial_' fields{cnt1}]) = get(exptparams.TrialObject, fields{cnt1});
   end
   fields = get(exptparams.BehaveObject,'UserDefinableFields');
   Parameters.BehaveObject = '______________';
   Parameters.BehaveObjectClass = class(exptparams.BehaveObject);
   for cnt1 = 1:3:length(fields)
      Parameters.(['Behave_' fields{cnt1}]) = get(exptparams.BehaveObject, fields{cnt1});
   end
   RefHandle = get(exptparams.TrialObject,'ReferenceHandle');
   if ~isempty(RefHandle)
      Parameters.Reference = '______________';
      Parameters.ReferenceClass = class(RefHandle);
      fields = get(RefHandle,'UserDefinableFields');
      for cnt1 = 1:3:length(fields)
         Parameters.(['Ref_' fields{cnt1}]) = get(RefHandle, fields{cnt1});
      end
   end
   TarHandle = get(exptparams.TrialObject,'TargetHandle');
   if ~isempty(TarHandle)
      Parameters.Target = '______________';
      Parameters.TargetClass = class(TarHandle);
      fields = get(TarHandle,'UserDefinableFields');
      for cnt1 = 1:3:length(fields)
         Parameters.(['Tar_' fields{cnt1}]) = get(TarHandle, fields{cnt1});
      end
   end
else
   % parameter values already converted to structures
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
   LastPerf = exptparams.Performance(end);
   if isfield(exptparams,'DBfields')
      fields = exptparams.DBfields.Performance;
   else
      fields = fieldnames(LastPerf);
   end
   for cnt1 = 1:length(fields)
      if ischar(LastPerf.(fields{cnt1}))
         Performance.(fields{cnt1}) = strrep(LastPerf.(fields{cnt1}),'<','^<');
         Performance.(fields{cnt1}) = strrep(LastPerf.(fields{cnt1}),'>','^>');
      end
      % also, round the numbers:
      if isnumeric(LastPerf.(fields{cnt1}))
         Performance.(fields{cnt1}) = round(LastPerf.(fields{cnt1})*100)/100;
      end
   end
end

   