function varargout = BaphyTuningCurve(varargin)
% BAPHYTUNINGCURVE M-file for BaphyTuningCurve.fig
%      BAPHYTUNINGCURVE, by itself, creates a new BAPHYTUNINGCURVE or raises the existing
%      singleton*.
%
%      H = BAPHYTUNINGCURVE returns the handle to a new BAPHYTUNINGCURVE or the handle to
%      the existing singleton*.
%
%      BAPHYTUNINGCURVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAPHYTUNINGCURVE.M with the given input arguments.
%
%      BAPHYTUNINGCURVE('Property','Value',...) creates a new BAPHYTUNINGCURVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BaphyTuningCurve_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BaphyTuningCurve_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BaphyTuningCurve

% Last Modified by GUIDE v2.5 26-Jun-2006 14:25:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BaphyTuningCurve_OpeningFcn, ...
    'gui_OutputFcn',  @BaphyTuningCurve_OutputFcn, ...
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


% --- Executes just before BaphyTuningCurve is made visible.
function BaphyTuningCurve_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BaphyTuningCurve (see VARARGIN)

% Choose default command line output for BaphyTuningCurve
handles.output = hObject;
if length(varargin)>0
    handles.globalparams = varargin{1};
    handles.globalparams.Physiology = 'No';
end
global TCRunning StopTuningCurve;
TCRunning = 0;
StopTuningCurve = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BaphyTuningCurve wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BaphyTuningCurve_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Start/Stop
global TCRunning StopTuningCurve HW;
if TCRunning
    StopTuningCurve = 1;
    return;
end
set(handles.pushbutton1,'String','Stop');
drawnow;
duration = ifstr2num(get(handles.edit1,'String'));
ISI = ifstr2num(get(handles.edit2,'String'));
loudness = ifstr2num(get(handles.edit3,'String'));
globalparams = handles.globalparams;
globalparams.TuningCurve = 'yes';
HW = InitializeHW(globalparams);
fs = HW.params.fsAO;
waveform = [0 5*ones(1,fs*duration) 0];
IOSetLoudness(HW, 80-loudness);
TCRunning = 1;
StopTuningCurve = 0;
while StopTuningCurve==0
    IOStartSound(HW,waveform);
    set(handles.pushbutton1,'foregroundcolor',[1 0 0]);
    drawnow;
    while isrunning(HW.AO);end
    SoundEnd = clock;
    set(handles.pushbutton1,'foregroundcolor',[0 0 0]);
    drawnow;
    while(etime(clock,SoundEnd)<ISI);end
end
ShutdownHW(HW);
TCRunning = 0;
StopTuningCurve = 0;
set(handles.pushbutton1,'String','Start');

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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global TCRunning StopTuningCurve HW;
if TCRunning
    StopTuningCurve = 1;
    return;
end
TCRunning=1;
if ~isempty(HW)
    ShutdownHW(HW);
end
delete(handles.figure1);




function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


