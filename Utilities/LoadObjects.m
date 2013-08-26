function varargout = LoadObjects (mfilename)
% function varargout = LoadObjects (mfilename)
%
% function LoadObjects load the behavior, trial, reference and target
% objects from the mfile.
% mfilename: the name of the m file
% varargout{1}: TrialObject if exist
% varargout{2}: Reference object if exist
% varargout{3}: Target object if exist
% varargout{4}: Behavior object if exist


% Nima, aug 2006

LoadMFile(mfilename);
TrialObject = [];
BehaveObject = [];
RefObject = [];
TarObject = [];
% BehaviorObject:
if isfield(exptparams,'BehaveObjectClass')
    BehaveObject = feval(exptparams.BehaveObjectClass);
    fields = get(BehaveObject,'UserDefinableFields');
    BehaveObject = ObjectSetFields(BehaveObject, fields, exptparams.BehaveObject);
end
if isfield(exptparams,'TrialObject')
    TrialObject = feval(exptparams.TrialObjectClass);
    fields = get(TrialObject, 'UserDefinableFields');
    TrialObject = ObjectSetFields(TrialObject, fields, exptparams.TrialObject);
    if isfield(exptparams.TrialObject,'ReferenceClass')
        % also, generate the reference and target objects:
        RefObject = feval(exptparams.TrialObject.ReferenceClass);
        fields = get(RefObject,'UserDefinableFields');
        RefObject = ObjectSetFields(RefObject, fields, exptparams.TrialObject.ReferenceHandle);
    end
    if isfield(exptparams.TrialObject,'TargetClass') && ~strcmpi(exptparams.TrialObject.TargetClass,'none')
        TarObject = feval(exptparams.TrialObject.TargetClass);
        fields = get(TarObject, 'UserDefinableFields');
        TarObject = ObjectSetFields(TarObject, fields, exptparams.TrialObject.TargetHandle);
    end
    if ~isempty(RefObject), TrialObject = set(TrialObject,'ReferenceHandle',RefObject);end
    if ~isempty(TarObject), TrialObject = set(TrialObject,'TargetHandle',TarObject);end

end
varargout{1} = TrialObject;
varargout{2} = RefObject;
varargout{3} = TarObject;
varargout{4} = BehaveObject;


%%%
function o = ObjectSetFields ( o,fields,values)
for cnt1 = 1:3:length(fields)
    try % since objects are changing,
        o = set(o,fields{cnt1},values.(fields{cnt1}));
    catch
        warning(['property ' fields{cnt1} ' can not be found, using default']);
    end
end