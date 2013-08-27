function varargout = BaphyRefTarGui(varargin)
%BAPHYREFTARGUI M-file for BaphyRefTarGui.fig
%      BAPHYREFTARGUI, by itself, creates a new BAPHYREFTARGUI or raises the existing
%      singleton*.
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BaphyRefTarGui_OpeningFcn, ...
    'gui_OutputFcn',  @BaphyRefTarGui_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before BaphyRefTarGui is made visible.
function BaphyRefTarGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This is the initialization function.
% we do the following:
% 1. store the figure handle and display global params on gui
% 2. load the list of sound objects into reference and target popups
% 3. load the list of trial objects into popup
% 4. load the list of behavior objects into popups
%
% Choose default command line output for BaphyRefTarGui

set([handles.pushbutton1,handles.pushbutton2],'Enable','off');
handles.output = hObject;

% 1. Update handles structure
guidata(hObject, handles);
moveguiPlusRemote(hObject,'center');
global BAPHYHOME BAPHY_CONFIG_PATH
handles.exptparams.FigureHandle = handles.figure1;
figure(handles.figure1);
handles.exptparams = GUIUpdateStatus(varargin{1},handles.exptparams);
if ~isempty(varargin)
    handles.globalparams = varargin{1};
end

% 2. now load the items of the gui from file and show them:
% getting the list of soundobjects from the directory:
SoundObjList = cat(1,dir([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'SoundObjects/@*']),...
  dir([BAPHYHOME filesep 'SoundObjects' filesep '@*']));
temp = cell(1,length(SoundObjList));
[temp{:}] = deal(SoundObjList.name);
temp = strrep(temp,'@','');
[B,I,J] = unique(temp,'first');
temp={temp{sort(I)}};
set(handles.popupmenu3,'String',temp);
set(handles.popupmenu4,'String',sort({temp{:}, 'None'}));

% 3. getting the list of trial objects from the directory:
TrialObjList = cat(1,dir([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'TrialObjects/@*']),...
  dir([BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'TrialObjects' filesep '@*']));
temp = cell(1,length(TrialObjList));
[temp{:}] = deal(TrialObjList.name);
temp = strrep(temp,'@','');
[B,I,J] = unique(temp,'first');
temp={temp{sort(I)}};
set(handles.popupmenu8,'String',temp);

% 4. getting the list of behavior control scripts from file:
BehaveObjList = cat(1,dir([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'BehaviorObjects/@*']),...
  dir([BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'BehaviorObjects' filesep '@*']));
temp = cell(1,length(BehaveObjList));
[temp{:}] = deal(BehaveObjList.name);
temp = strrep(temp,'@','');
[B,I,J] = unique(temp,'first');
temp={temp{sort(I)}};
set(handles.popupmenu7,'String',temp);

% now load the default for each user from last experiment:
if exist([BAPHYHOME filesep 'Config' filesep 'BaphyRefTarGuiSettings.mat']);
    ferret = handles.globalparams.Ferret;
    handles = load_settings(handles, ferret);
end
% now display the userdefinable fields for reference and target:
handles = popupmenu3_Callback(handles.popupmenu3, eventdata, handles);
handles = popupmenu4_Callback(handles.popupmenu4, eventdata, handles);
% also, load the parameters of behaviour control:
handles = popupmenu7_Callback(handles.popupmenu7, eventdata, handles);
% and the user definable fields of trial object:
handles = popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
guidata(hObject,handles);
set([handles.pushbutton1,handles.pushbutton2],'Enable','on');

uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BaphyRefTarGui_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1}= handles.output;
if isempty(handles.output)
    delete(handles.figure1);
end

%% SAVE AND LOAD SETTINGS 
% These functions read the settings from the configuration file based on the ferret
function varargout = load_settings(handles,ferret);
global BAPHYHOME;
try
    load ([BAPHYHOME filesep 'Config' filesep 'BaphyRefTarGuiSettings.mat']);
    if nargin<2, ferret = 'Test';end
    if ~isfield(ferrets,ferret) settings = []; else settings=ferrets.(ferret); end
    if ~isempty(settings)
        set(handles.checkbox1,'value',settings.ContinuousTraining);
        set(handles.edit13,'String',settings.Repetition);
        set(handles.edit17,'String',settings.TrialBlock);
        setString(handles.popupmenu8,settings.TrialObject);
        setString(handles.popupmenu7,settings.BehaviorControl);
        setString(handles.popupmenu3,settings.ReferenceIndex);
        setString(handles.popupmenu4,settings.TargetIndex);
    end
catch
    delete([BAPHYHOME filesep 'Config' filesep 'BaphyRefTarGuiSettings.mat']);
end
if nargout>0 varargout{1}=handles; end

function save_settings (handles, ferret)
% this function save the current setting for the specified user
% user is a cell array, with indices from 1 to number of users
% in each cell array, a structure named "settings" holds all the menu items
% for that user. When this function is called, it first loads the uesr
% array, update the corresponding one and save it back.
global BAPHYHOME;
if exist([BAPHYHOME filesep 'Config' filesep 'BaphyRefTarGuiSettings.mat']);
   load([BAPHYHOME filesep 'Config' filesep 'BaphyRefTarGuiSettings.mat']);
end
settings.ContinuousTraining = get(handles.checkbox1,'value');
settings.Repetition      = str2num(get(handles.edit13,'String'));
settings.TrialBlock      = str2num(get(handles.edit17,'String'));
settings.ReferenceIndex  = getString(handles.popupmenu3);
settings.TargetIndex     = getString(handles.popupmenu4);
settings.BehaviorControl = getString(handles.popupmenu7);
settings.TrialObject     = getString(handles.popupmenu8);

% now put it in the correct cell
ferrets.(ferret)=settings;
save ([BAPHYHOME filesep 'Config' filesep 'BaphyRefTarGuiSettings.mat'],'ferrets');

function setString(h,String)
Strings = get(h,'String');  Value = find(strcmp(Strings,String));
if ~isempty(Value) set(h,'Value',Value); end

function String = getString(h)
Strings = get(h,'String'); String = Strings{get(h,'Value')};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% REFERENCE POPUP 
function varargout = popupmenu3_Callback(hObject, eventdata, handles)

% get the userdefinable fields and display the options for the user
refpos = BaphyRefTarGuiItems('ReferencePosition');
refObject = getString(handles.popupmenu3);
SavedObject = feval(refObject);
% LOAD SETTING OF CURRENT SOUND OBJECT
ferret_index = BaphyMainGuiItems('FerretId',handles.globalparams);
SavedObject = ObjLoadSaveDefaults(SavedObject,'r',1+2*(ferret_index-1)); % index one means read last values for reference
DefaultFields = get(SavedObject, 'UserDefinableFields');
RefHandles = [];
RefHandlesText = [];
if isfield(handles,'RefHandles')
  for cnt1=1:length(handles.RefHandles)
    delete(handles.RefHandles(cnt1));
    delete(handles.RefHandlesText(cnt1));
  end
end
for cnt1 = 1:length(DefaultFields)/3
  % length(DefaultFields) should be always a multiple of 3, because it
  % had the field name, its style and it  default value.
  CurrentField = DefaultFields((cnt1-1)*3+1:cnt1*3);
  % now if the CurrentField is edit, get its value from the tempObject which has
  % the last values. But if its popupmenu, then load it with defaults
  % from object constructor (UserDefinableFields)"
  switch CurrentField{2}
    case 'popupmenu'; % if its a popupmenu, find the 'value' of the saved information
      DivPos = strfind(CurrentField{3},'|');
      if ~strcmp(CurrentField{1},'MTTRates')
      SavePos = strfind(CurrentField{3},get(SavedObject, CurrentField{1}));
      else
        SavePos=[];
      end
      if isempty(SavePos) SavePos=1; end
      DefaultValue = find(DivPos>SavePos,1);
      if isempty(DefaultValue), DefaultValue = length(DivPos)+1;end
      DefaultString = CurrentField{3};
    otherwise % mostly edit
      DefaultString = num2str(get(SavedObject, CurrentField{1}));
  end
  RefHandlesText(cnt1)=uicontrol('style','text','string',CurrentField{1},'FontWeight','bold',...
    'HorizontalAlignment','right','position',[refpos-[100 18*(cnt1-1)+3] 90 18]);
  RefHandles(cnt1) = uicontrol('Style',CurrentField{2},'String',DefaultString,'BackgroundColor',[1 1 1],'position',...
    [refpos-[0 18*(cnt1-1)] 130 18],'HorizontalAlignment','center');
  if strcmpi(CurrentField{2},'popupmenu'), set(RefHandles(cnt1),'Value',DefaultValue);end
end
handles.RefHandles = RefHandles;
handles.RefHandlesText = RefHandlesText;
% this function is called at the begining too, for that case, return them
if nargout >0 varargout{1} = handles;else
  guidata(gcbo,handles);end

%% TARGET POPUP
function varargout = popupmenu4_Callback(hObject, eventdata, handles)
% Target popupmenu
% get the userdefinable fields and display the options for the user
tarpos = BaphyRefTarGuiItems('TargetPosition');
tarObject = get(handles.popupmenu4,'String');
tarindex = get(handles.popupmenu4,'Value');
tarObject = tarObject{tarindex};
if ~strcmp(tarObject,'None')
  tempObject = feval(tarObject);
  % Now load the last settings for this subject and target
  ferret_index = BaphyMainGuiItems('FerretId',handles.globalparams);
  tempObject = ObjLoadSaveDefaults (tempObject, 'r', 2+2*(ferret_index-1)); % index 2 means read the last values of target
  fields = get(tempObject, 'UserDefinableFields');
else fields=[];end
tarHandles = [];
tarHandlesText = [];
% if current handled exist, delete them:
if isfield(handles,'TarHandles')
    for cnt1=1:length(handles.TarHandles)
        delete(handles.TarHandles(cnt1));
        delete(handles.TarHandlesText(cnt1));
    end
end
for cnt1 = 1:length(fields)/3   % length(fields) should be always a multiple of 3, because it
    % had the field name, its style and its
    % default value.
    field = fields((cnt1-1)*3+1:cnt1*3);
    % now if the field is edit, get its value from the tempObject which has
    % the last values. But if its popupmenu, then load it with defaults
    % from object constructod (UserDefinableFields)"
    if strcmp(field{2},'popupmenu')
        % if its a popupmenu, find the 'value' property:
        tmp1 = strfind(field{3},'|');
        tmp2 = strfind(field{3},get(tempObject, field{1}));
        popvalue = find(tmp1>tmp2,1);
        if isempty(popvalue), popvalue = length(tmp1)+1;end
        default = field{3};
    else
        default = get(tempObject, field{1});
        default = num2str(default);
    end
    tarHandlesText(cnt1)=uicontrol('style','text','string',field{1},'FontWeight','bold',...
        'HorizontalAlignment','right','position',[tarpos-[100 18*(cnt1-1)+3] 90 18]);
    tarHandles(cnt1) = uicontrol('Style',field{2},'String',default,'BackgroundColor',[1 1 1],'position',...
        [tarpos-[0 18*(cnt1-1)] 130 18],'HorizontalAlignment','center');
    if strcmpi(field{2},'popupmenu'), set(tarHandles(cnt1),'value',popvalue);end
    if strcmpi(field{2},'checkbox'), set(tarHandles(cnt1),'value',ifstr2num(default));end
end
% delete the temp object:
clear tempObject;
handles.TarHandles = tarHandles;
handles.TarHandlesText = tarHandlesText;
if nargout >0 varargout{1} = handles;else
    guidata(gcbo,handles);end

%% BEHAVIOR CONTROL
function handles = popupmenu7_Callback(hObject, eventdata, handles)
% when the user select the Behavior control routine, set the default
% params from the past and if it does not exist load it from the file:
BehaveObject = getString(handles.popupmenu7);
BehaveObject = feval(BehaveObject);
ferret_index = BaphyMainGuiItems('FerretId',handles.globalparams);
BehaveObject = ObjLoadSaveDefaults (BehaveObject,'r',ferret_index); % load the defaults for current user:
handles.BehaveObject = BehaveObject; clear BehaveObject;
if nargout >0 varargout{1} = handles;
else guidata(gcbo,handles);
end

%% PARAMETERS GUI
function pushbutton4_Callback(hObject, eventdata, handles)
% Parameters button, open parameters gui and get the values from the user:
BehaveObject = handles.BehaveObject;
UserInput = 0;
fields = get(BehaveObject, 'UserDefinableFields');
if ~isempty(fields)
    for cnt1 = 1:3:length(fields)-1;
        param(1+(cnt1-1)/3).text = fields{cnt1};
        param(1+(cnt1-1)/3).style = fields{cnt1+1};
        if strcmp(fields{cnt1+1},'popupmenu')
            % if its a popupmenu, find the 'value' property:
            tmp1 = strfind(fields{cnt1+2},'|');
            tmp2 = strfind(fields{cnt1+2},get(BehaveObject, fields{cnt1}));
            popvalue = find(tmp1>tmp2,1);
            if isempty(popvalue), popvalue = length(tmp1)+1;end
            default = fields{cnt1+2};
            default = {fields{cnt1+2}, popvalue};
        else
            default = get(BehaveObject, fields{cnt1});
        end

        param(1+(cnt1-1)/3).default = default;
    end
    UserInput = ParameterGUI (param,'Behavior Parameters','bold','center');
    if ~isnumeric(UserInput) % user did not press cancle, so change them:
        for cnt1 = 1:length(param);
            BehaveObject = set(BehaveObject, fields{1+(cnt1-1)*3}, strtok(UserInput{cnt1}));
        end
        % now, save it as last values and update the object in handles:
        ferret_index = BaphyMainGuiItems('FerretId',handles.globalparams);
        ObjLoadSaveDefaults(BehaveObject,'w', ferret_index);
        handles.BehaveObject = BehaveObject;
        guidata(gcbo,handles);
    end
else
    warndlg(sprintf('%s mode does not have any parameters!',class(BehaveObject)));
end

%% TRIAL OBJECT POPUP
function varargout = popupmenu8_Callback(hObject, eventdata, handles)

TrialObjList = get(handles.popupmenu8,'String');
TrialObject = feval(TrialObjList{get(handles.popupmenu8,'Value')});
ferret_index = BaphyMainGuiItems('FerretId',handles.globalparams);
TrialObject = ObjLoadSaveDefaults (TrialObject,'r',ferret_index);
TrialHandles = [];
fields = get(TrialObject,'UserDefinableFields');
% if it already exists, delete it and recreate it:
if isfield(handles,'TrialHandles'),
    for cnt1=1:length(handles.TrialHandles)
        delete(handles.TrialHandles(cnt1));
        delete(handles.TrialHandlesText(cnt1));
    end
end
trialpos = BaphyRefTarGuiItems ('ModuleparamsPosition');

if length(fields)./3 > 6,
  useparmgui=1;
else
  useparmgui=0;
end

% now display them on the screen:
for cnt1 = 1:length(fields)/3   % length(fields) should be always a multiple of 3, because it
    % had the field name, its style and its
    % default value.
    field = fields((cnt1-1)*3+1:cnt1*3);
    
    if strcmp(field{2},'popupmenu')
        % if its a popupmenu, find the 'value' property:
        tmp1 = strfind(field{3},'|');
        tmp2 = strfind(field{3},get(TrialObject, field{1}));
        popvalue = find(tmp1>tmp2,1);
        if isempty(popvalue), popvalue = length(tmp1)+1;end
        default = field{3};
    else
        default = num2str(get(TrialObject, field{1}));
    end
    TrialHandlesText(cnt1)=uicontrol('style','text','string',field{1},'FontWeight','bold',...
        'HorizontalAlignment','right','position',[trialpos-[130 18*(cnt1-1)+4] 120 18]);
    TrialHandles(cnt1) = uicontrol('Style',field{2},'String',default,'BackgroundColor',[1 1 1],'position',...
        [trialpos-[0 18*(cnt1-1)] 120 18]);
    if strcmpi(field{2},'popupmenu'), set(TrialHandles(cnt1),'value',popvalue);end
    
    if useparmgui,
      % hide regular fields because there are too many.
      set(TrialHandlesText(cnt1),'Visible','off');
      set(TrialHandles(cnt1),'Visible','off');
    end
end

% save their handles in gui: (trialHandles are module parameters)
handles.TrialObject = TrialObject;
handles.TrialHandles = TrialHandles;
handles.TrialHandlesText = TrialHandlesText;

if useparmgui,
  set(handles.buttonTrialObjectParameters,'Visible','on');
  set(handles.textTrialObjectParameters,'Visible','on');
  update_textTrialObjectParameters(handles)
else
  set(handles.buttonTrialObjectParameters,'Visible','off');
  set(handles.textTrialObjectParameters,'Visible','off');
end

if nargout >0 varargout{1} = handles;else
    guidata(gcbo,handles);end

% TRIAL OBJECT PARAMETER BUTTON (Visible if too many parameters to fit on
% panel)
function buttonTrialObjectParameters_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTrialObjectParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrialObject = handles.TrialObject;
UserInput = 0;
fields = get(TrialObject, 'UserDefinableFields');
for cnt1 = 1:3:length(fields)-1;
  param(1+(cnt1-1)/3).text = fields{cnt1};
  param(1+(cnt1-1)/3).style = fields{cnt1+1};
  if strcmp(fields{cnt1+1},'popupmenu')
    % if its a popupmenu, find the 'value' property:
    tmp1 = strfind(fields{cnt1+2},'|');
    tmp2 = strfind(fields{cnt1+2},get(handles.TrialHandles(1+(cnt1-1)/3), 'value'));
    popvalue = find(tmp1>tmp2,1);
    if isempty(popvalue), popvalue = length(tmp1)+1;end
    default = fields{cnt1+2};
    default = {fields{cnt1+2}, get(handles.TrialHandles(1+(cnt1-1)/3), 'value')};
  else
    default = get(handles.TrialHandles(1+(cnt1-1)/3), 'string');
  end
  
  param(1+(cnt1-1)/3).default = default;
end
UserInput = ParameterGUI (param,'Trial Object Parameters','bold','center');

if ~isnumeric(UserInput) % user did not press cancel, so change them:
  for cnt1 = 1:length(param);
    if strcmp(param(cnt1).style,'popupmenu')
      tmp1 = strfind(param(cnt1).default{1},'|');
      tmp2 = strfind(param(cnt1).default{1},strtrim(UserInput{cnt1}));
      popvalue = find(tmp1>tmp2,1);
      if isempty(popvalue), popvalue = length(tmp1)+1;end
      set(handles.TrialHandles(cnt1), 'value', popvalue);
    else
      set(handles.TrialHandles(cnt1), 'string', UserInput{cnt1});
    end
  end
  update_textTrialObjectParameters(handles)
  
  % now, save it as last values and update the object in handles:
  guidata(gcbo,handles);
end

function update_textTrialObjectParameters(handles)

stext={};
fields = get(handles.TrialObject, 'UserDefinableFields');
for cnt1 = 1:3:length(fields)-1;
  if strcmp(fields{cnt1+1},'popupmenu')
     v=get(handles.TrialHandles(1+(cnt1-1)/3), 'value');
     stext{1+(cnt1-1)/3}=[fields{cnt1} ': ' num2str(v)];
  else
     v=get(handles.TrialHandles(1+(cnt1-1)/3), 'string');
     stext{1+(cnt1-1)/3}=[fields{cnt1} ': ' v];
  end
end
set(handles.textTrialObjectParameters,'string',stext,...
   'HorizontalAlignment','left','FontSize',7);


%% HELP BUTTON
function pushbutton5_Callback(hObject, eventdata, handles)
% Help push button:
BehaveObject = handles.BehaveObject;
HelpText = help(class(BehaveObject));
helpdlg(HelpText,'Behavior Control Help');

%% START BUTTON
function pushbutton1_Callback(hObject, eventdata, handles)
% create an instance of ReferenceTarget object and update its fields from
% user data. Then save the object and call reference target script.

% first, read the TrialObject from handles:
set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
moveguiPlusRemote(handles.figure1,'east');
drawnow;
TrialObject = handles.TrialObject;
% Now, update the general fields based on Gui inputs:
for cnt1 = 1:length(handles.TrialHandles);
    field = get(handles.TrialHandlesText(cnt1), 'String');
    % now get the value:
    tempSt = get(handles.TrialHandles(cnt1),'String');
    tempIn = get(handles.TrialHandles(cnt1),'Value');
    % check to see if its an edit box:
    if tempIn==0
        value = tempSt;
    elseif iscell(tempSt)
        value=tempSt{tempIn};
    else
        value = tempSt(tempIn,:);
    end
    % update the field
    % change it to numeric if default is numeric, and not empty:
    % to do that, create an instance of the object and clear it afterward:
    tempObj = feval(class(TrialObject));
    if isnumeric(get(tempObj, field)) & ~isempty(get(tempObj, field))
        value = ifstr2num(value);
    elseif ischar(value)
        value = strtok(value);
    end
    TrialObject = set(TrialObject, field, value);
end

% now create the Reference Class:
RefName = get(handles.popupmenu3,'String');
index = get(handles.popupmenu3,'Value');
RefName = RefName{index};
RefObject = feval(RefName);
if ~isempty(handles.RefHandles)
    for cnt1 = 1:length(handles.RefHandles)
        field = get(handles.RefHandlesText(cnt1), 'String');
        % now get the value:
        tempSt = get(handles.RefHandles(cnt1),'String');
        tempIn = get(handles.RefHandles(cnt1),'Value');
        % check to see if its a edit box:
        if tempIn==0 value = (tempSt);
        elseif iscell(tempSt) value=tempSt{tempIn};
        else value=tempSt(tempIn,:);end
        % update the field
        % if the default is numeric, change it to numeric:
        tempObj = feval(class(RefObject));
        if isnumeric(get(tempObj, field)) & ~isempty(get(tempObj, field))
            value = ifstr2num(value);
        end
        RefObject = set(RefObject, field, value);
    end
end
% if target is defined, create it
TarName = get(handles.popupmenu4,'String');
index = get(handles.popupmenu4,'Value');
TarName = TarName{index};
% if (get(TrialObject, 'NumberOfTarPerTrial')>0) & ~strcmp(TarName,'None')
if ~strcmp(TarName,'None')
    TarObject = feval(TarName);
    if ~isempty(handles.TarHandles)
        for cnt1 = 1:length(handles.TarHandles)
            field = get(handles.TarHandlesText(cnt1), 'String');
            % now get the value:
            tempSt = get(handles.TarHandles(cnt1),'String');
            tempIn = get(handles.TarHandles(cnt1),'Value');
            % check to see if its a drop box:
            if tempIn==0, value = (tempSt);
            elseif iscell(tempSt), value=tempSt{tempIn};
            else value=tempSt(tempIn,:);end
            % if its a check box, value is the value!
            if strcmpi(get(handles.TarHandles(cnt1),'Style'),'checkbox'),
                value = tempIn;
            end
            % update the field
            % if the default is numeric return numeric:
            tempObj = feval(class(TarObject));
            if isnumeric(get(tempObj, field)) & ~isempty(get(tempObj, field))
                value = ifstr2num(value);
            end
            TarObject = set(TarObject, field, value);
        end
    end
else TarObject = [];TarName='None';
end
% Now construct the ReferenceTarget Object:
TrialObject = set(TrialObject, 'ReferenceHandle', RefObject);
TrialObject = set(TrialObject, 'TargetHandle', TarObject);
global BAPHYHOME;
exptparams = handles.exptparams;
exptparams.FigureHandle = handles.figure1;
globalparams = handles.globalparams;
% now obtain experiment parameters:
% pass the object in Object field of exptparams:
exptparams.TrialObject = TrialObject;
exptparams.runclass = get(TrialObject,'RunClass');
% Online STRF
% t1=get(handles.popupmenu1,'String');t2=get(handles.popupmenu1,'Value');
% exptparams.OnlineSTRF = t1{t2};
% Online Raster
% t1=get(handles.popupmenu2,'String');t2=get(handles.popupmenu2,'Value');
% exptparams.OnlineRaster = t1{t2};
exptparams.ContinuousTraining = get(handles.checkbox1,'value');
% Online waveform
t1=get(handles.popupmenu9,'String');t2=get(handles.popupmenu9,'Value');
exptparams.OnlineWaveform = t1{t2};
% Repetition
exptparams.Repetition = ifstr2num(get(handles.edit13,'String'));
% Trial Block
exptparams.TrialBlock = ifstr2num(get(handles.edit17,'String'));
% Now read the Behavior parameters of Behavior:
exptparams.BehaveObject = handles.BehaveObject;
% classes:
exptparams.BehaveObjectClass = class(exptparams.BehaveObject);
exptparams.TrialObjectClass = class(TrialObject);
% if the stimulation exists, add it to the exptparams:
% NOTE: for stimulation, behavior object should generate a field called
% TarStimulation and set it to 0 or 1.
if isfield(get(exptparams.BehaveObject),'TarStimulation')
    exptparams.Stimulation = get(exptparams.BehaveObject,'TarStimulation');
end
if isfield(get(exptparams.TrialObject),'SaveData') && strcmpi(get(exptparams.TrialObject,'SaveData'),'No')
    exptparams.outpath='X';
end
% save the current setting for ReferenceTarget, Reference and Target
% objects:
ferret_index = BaphyMainGuiItems('FerretId',globalparams);
ObjLoadSaveDefaults(TrialObject,'w', ferret_index);
ObjLoadSaveDefaults(RefObject,'w',1+2*(ferret_index-1)); % save in reference profile (1)
if ~isempty(TarObject)
    ObjLoadSaveDefaults(TarObject,'w',2+2*(ferret_index-1)); % save in target profile (2)
end
save_settings(handles,globalparams.Ferret);
handles.output = exptparams;
guidata(gcbo, handles);
uiresume;

%% BACK BUTTON
function pushbutton2_Callback(hObject, eventdata, handles)
global BAPHYHOME;
if isempty(BAPHYHOME) startup;end
% now destroy them:
handles.output = [];
guidata(gcbo, handles);
uiresume;

%% STOP BUTTON
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global StopExperiment;
StopExperiment = 1;

%% CALLBACKS
function edit8_Callback(hObject, eventdata, handles)
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit4_Callback(hObject, eventdata, handles)
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu1_Callback(hObject, eventdata, handles)
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu2_Callback(hObject, eventdata, handles)
function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit6_Callback(hObject, eventdata, handles)
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit7_Callback(hObject, eventdata, handles)
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit1_Callback(hObject, eventdata, handles)
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_Callback(hObject, eventdata, handles)
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit3_Callback(hObject, eventdata, handles)
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit5_Callback(hObject, eventdata, handles)
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit13_Callback(hObject, eventdata, handles)
function edit13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit14_Callback(hObject, eventdata, handles)
function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit15_Callback(hObject, eventdata, handles)
function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit16_Callback(hObject, eventdata, handles)
function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit17_Callback(hObject, eventdata, handles)
function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu9_Callback(hObject, eventdata, handles)
function popupmenu9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function checkbox1_Callback(hObject, eventdata, handles)
