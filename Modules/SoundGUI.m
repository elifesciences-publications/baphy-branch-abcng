function varargout = SoundGUI(varargin)
%SOUNDGUI M-file for SoundGUI.fig
%      SOUNDGUI, by itself, creates a new SOUNDGUI or raises the existing
%      singleton*.
%
% hacked from Nima's RefTarGUI.  but designed to contain parameters for
% just one sound object.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SoundGUI_OpeningFcn, ...
    'gui_OutputFcn',  @SoundGUI_OutputFcn, ...
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

% --- Executes just before SoundGUI is made visible.
function SoundGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% load the list of sound objects
%
global BAPHYHOME

% Choose default command line output for SoundGUI
handles.output = hObject;
% 1. Update handles structure
guidata(hObject, handles);
moveguiPlusRemote(hObject,'center');
handles.exptparams.FigureHandle = handles.figure1;

if length(varargin)>0,
    handles.DefValue=varargin{1};
else
    handles.DefValue=1;
end

% 2. now load the items of the gui from file and show them:
% getting the list of soundobjects from the directory:
SoundObjList = dir([BAPHYHOME filesep 'SoundObjects' filesep '@*']);
temp = cell(1,length(SoundObjList));
[temp{:}] = deal(SoundObjList.name);
temp = strrep(temp,'@','');
set(handles.popSound,'String',temp);

if ~isstruct(handles.DefValue),
    sound_idx = handles.DefValue;
else
    sound_idx = find(strcmp(temp,handles.DefValue.descriptor));
end
set(handles.popSound,'Value',sound_idx);

% now display the userdefinable fields for reference and target:
handles = popSound_Callback(handles.popSound, eventdata, handles);

if length(varargin)>1,
    handles.SoundTag=varargin{2};
else
    handles.SoundTag='Stimulus';
end
set(handles.uipanel1,'Title',handles.SoundTag);

guidata(hObject,handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SoundGUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1}= handles.output;
delete(handles.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = popSound_Callback(hObject, eventdata, handles)
% Reference popupmenu:

% get the userdefinable fields and display the options for the user
%refpos = BaphyRefTarGuiItems('ReferencePosition');
refpos=[136 335];
refObject = get(handles.popSound,'String');
refindex = get(handles.popSound,'Value');
if isempty(refindex) refindex = 1; set(handles.popSound,'Value',1); end
refObject = refObject{refindex};
tempObject = feval(refObject);
% now load the settings for this user and object being reference:
tempObject = ObjLoadSaveDefaults(tempObject,'r',1); % index one means read last values for reference
fieldset = get(tempObject, 'UserDefinableFields');

RefHandles = [];
RefHandlesText = [];
if isfield(handles,'RefHandles')
    for cnt1=1:length(handles.RefHandles)
        delete(handles.RefHandles(cnt1));
        delete(handles.RefHandlesText(cnt1));
    end
end

for cnt1 = 1:length(fieldset)/3   % length(fieldset) should be always a multiple of 3, because it
    % had the field name, its style and its
    % default value.
    field = fieldset((cnt1-1)*3+1:cnt1*3);
    % now if the field is edit, get its value from the tempObject which has
    % the last values. But if its popupmenu, then load it with defaults
    % from object constructod (UserDefinableFields)"
    if strcmp(field{2},'popupmenu')
        % if its a popupmenu, find the 'value' property:
        tmp1 = strfind(field{3},'|');
        if isstruct(handles.DefValue) & isfield(handles.DefValue,field{1}),
            tmp2 = strfind(field{3},deblank(getfield(handles.DefValue,field{1})));
        else
            tmp2 = strfind(field{3},get(tempObject, field{1}));
        end
        popvalue = find(tmp1>tmp2,1);
        if isempty(popvalue), 
            popvalue = length(tmp1)+1;
        end
        default = field{3};
    else
        if isstruct(handles.DefValue) & isfield(handles.DefValue,field{1}),
            default=getfield(handles.DefValue,field{1});
            default=num2str(default);
        else
            default = get(tempObject, field{1});
            default = num2str(default);
        end
    end
    RefHandlesText(cnt1)=uicontrol('style','text','string',field{1},'FontWeight','bold',...
        'HorizontalAlignment','right','position',[refpos-[110 18*(cnt1-1)+3] 100 18]);
    RefHandles(cnt1) = uicontrol('Style',field{2},'String',default,'BackgroundColor',[1 1 1],'position',...
        [refpos-[0 18*(cnt1-1)] 200 18],'HorizontalAlignment','center');
    if strcmpi(field{2},'popupmenu'), set(RefHandles(cnt1),'value',popvalue);end
end

% now delete the temporary instance of the object;
clear tempObject;
handles.RefHandles = RefHandles;
handles.RefHandlesText = RefHandlesText;

% this function is called at the begining too, for that case, return them
if nargout>0,
    varargout{1} = handles;
else
    guidata(gcbo,handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function buttOK_Callback(hObject, eventdata, handles)

% OK button
% create an instance of Referencet object and update its fields from
% user data. Then save the object.

% now create the Reference Class:
RefName = get(handles.popSound,'String');
index = get(handles.popSound,'Value');
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
        if isnumeric(get(tempObj, field)), %  & ~isempty(get(tempObj, field))
            value = ifstr2num(value);
        end
        RefObject = set(RefObject, field, value);
    end
end

% save defaults
handles.output = RefObject;
guidata(gcbo, handles);
uiresume;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function buttCancel_Callback(hObject, eventdata, handles)
% Exit button

% now destroy them:
handles.output = [];
guidata(gcbo, handles);
uiresume;


% --- Executes during object creation, after setting all properties.
function popSound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popSound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


