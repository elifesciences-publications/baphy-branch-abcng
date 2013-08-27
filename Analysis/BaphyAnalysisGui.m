function varargout = BaphyAnalysisGui(varargin)
% BAPHYANALYSISGUI M-file for BaphyAnalysisGui.fig
%      BAPHYANALYSISGUI, by itself, creates a new BAPHYANALYSISGUI or raises the existing
%      singleton*.
%
%      H = BAPHYANALYSISGUI returns the handle to a new BAPHYANALYSISGUI or the handle to
%      the existing singleton*.
%
%      BAPHYANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAPHYANALYSISGUI.M with the given input arguments.
%
%      BAPHYANALYSISGUI('Property','Value',...) creates a new BAPHYANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BaphyAnalysisGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BaphyAnalysisGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BaphyAnalysisGui

% Last Modified by GUIDE v2.5 30-Oct-2009 13:58:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BaphyAnalysisGui_OpeningFcn, ...
    'gui_OutputFcn',  @BaphyAnalysisGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
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


% --- Executes just before BaphyAnalysisGui is made visible.
function BaphyAnalysisGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BaphyAnalysisGui (see VARARGIN)

% Choose default command line output for BaphyAnalysisGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BaphyAnalysisGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BaphyAnalysisGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% Browse directory button:
if ~isfield(handles,'pathname'), pathname = [];else pathname = handles.pathname;end
[filename, pathname] = uigetfile({'*.m','baphy files (*.m)';'*.*','All Files (*.*)'},'Pick parameter file',...
    [pathname filesep]);
if ~isequal(filename,0) && ~isequal(pathname,0)
    [pathname,filename]=fileparts([pathname filename]);
    indx=findstr(filename,'.');
    if ~isempty(indx)
        filename=filename(1:indx(1)-1);
    end
    handles.pathname=pathname;
    handles.filename=filename;
    set(handles.text2,'string',filename);
end
% load the parameter file here:
if (filename)
    LoadMFile([pathname filesep filename]);
    % if its a RefTar module, create the objects:
    if strcmpi(globalparams.Module,'Reference Target')
        
        % create the behavior object:
        BehaveObject = feval(exptparams.BehaveObjectClass);
        set(handles.text4,'string',exptparams.BehaveObjectClass);
        fields = get(BehaveObject,'UserDefinableFields');
        BehaveObject = ObjectSetFields(BehaveObject, fields, exptparams.BehaveObject);
        TrialObject = feval(exptparams.TrialObjectClass);
        fields = get(TrialObject, 'UserDefinableFields');
        TrialObject = ObjectSetFields(TrialObject, fields, exptparams.TrialObject);
        
        % also, generate the reference and target objects:
        RefObject = feval(exptparams.TrialObject.ReferenceClass);
        fields = get(RefObject,'UserDefinableFields');
        RefObject = ObjectSetFields(RefObject, fields, ...
                                    exptparams.TrialObject.ReferenceHandle);
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
    handles.exptparams = exptparams;
    handles.globalparams = globalparams;
    handles.exptevents = exptevents;
    guidata(gcbo,handles);
end
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% setting the parameters of the behavior object:
if ~isfield(handles,'exptparams'), return;end
BehaveObject = handles.exptparams.BehaveObject;
UserInput = 0;
fields = get(BehaveObject, 'UserDefinableFields');
if ~isempty(fields)
    for cnt1 = 1:3:length(fields)-1;
        param(1+(cnt1-1)/3).text = fields{cnt1};
        param(1+(cnt1-1)/3).style = fields{cnt1+1};
        param(1+(cnt1-1)/3).default = get(BehaveObject, fields{cnt1});
    end
    UserInput = ParameterGUI (param,'Behavior Parameters','bold','center');
    if ~isnumeric(UserInput) % user did not press cancle, so change them:
        for cnt1 = 1:length(param);
            BehaveObject = set(BehaveObject, fields{1+(cnt1-1)*3}, UserInput{cnt1});
        end
        % now, save it as last values and update the object in handles:
        handles.exptparams.BehaveObject = BehaveObject;
        guidata(gcbo,handles);
    end
else
    warndlg(sprintf('%s mode does not have any parameters!',class(BehaveObject)));
end




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% Performance Analysis
% LoadMFile([handles.pathname filesep handles.filename]);
exptevents = handles.exptevents;
exptparams = handles.exptparams;
globalparams = handles.globalparams;
HW.params = handles.globalparams.HWparams;
evpfile=[];
if exist([handles.pathname filesep 'tmp'] , 'dir'),
    evpfile = [handles.pathname filesep 'tmp' filesep handles.filename '.evp'];
    if ~exist(evpfile,'file'), evpfile=[];end
end
if isempty(evpfile)
    evpfile = [handles.pathname filesep handles.filename '.evp'];
    if ~exist(evpfile,'file'), error('evp file not found');end
end
% now, for each trial, create the stimulus event and read the evp data.
% Then, call the BehaviorDisplay method of the behavior object with the
% appropriate data (lick and stim events)
% first, the mfile:
[spikecount, auxcount, TotalTrial, spikefs, auxfs] = evpgetinfo(evpfile);
include = get(handles.edit1,'string'); 
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
        %exptparams=rmfield(exptparams,'UniqueTargets');
        exptparams = PerformanceAnalysis(handles.exptparams.BehaveObject, HW, StimEvents, ...
            globalparams, exptparams, ThisTrial, Lick);
        if ~mod(cnt1,exptparams.TrialBlock) || get(handles.checkbox1,'Value')
            exptparams = BehaviorDisplay(handles.exptparams.BehaveObject, HW, StimEvents, globalparams, ...
                exptparams, ThisTrial, Lick, []);
        end
    end
end
exptparams.TotalTrials = ThisTrial;
exptparams = BehaviorDisplay(handles.exptparams.BehaveObject, HW, StimEvents, globalparams, ...
    exptparams, ThisTrial, [], []);
disp('DONE!');

function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


function o = ObjectSetFields ( o,fields,values)
for cnt1 = 1:3:length(fields)
    try % since objects are changing,
        o = set(o,fields{cnt1},values.(fields{cnt1}));
    catch
        warning(['property ' fields{cnt1} ' can not be found, using default']);
    end
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1





function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


