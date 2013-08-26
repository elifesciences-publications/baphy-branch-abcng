function varargout = CalibrationGUI(varargin)
% CALIBRATIONGUI M-file for CalibrationGUI.fig
%      CALIBRATIONGUI, by itself, creates a new CALIBRATIONGUI or raises the existing
%      singleton*.
%
%      H = CALIBRATIONGUI returns the handle to a new CALIBRATIONGUI or the handle to
%      the existing singleton*.
%
%      CALIBRATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATIONGUI.M with the given input arguments.
%
%      CALIBRATIONGUI('Property','Value',...) creates a new CALIBRATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CalibrationGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CalibrationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CalibrationGUI

% Last Modified by GUIDE v2.5 11-Oct-2011 00:16:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CalibrationGUI_OpeningFcn, ...
    'gui_OutputFcn',  @CalibrationGUI_OutputFcn, ...
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


% --- Executes just before CalibrationGUI is made visible.
function CalibrationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CalibrationGUI (see VARARGIN)

% Choose default command line output for CalibrationGUI
handles.output = hObject;
if length(varargin)>0
    handles.globalparams = varargin{1};
    handles.globalparams.Physiology = 'No';
end
RefreshValues(handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CalibrationGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CalibrationGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% Speaker calibration
SpeakerCalibration(handles.globalparams);
RefreshValues(handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MicrophoneCalibration(handles.globalparams);
RefreshValues(handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Strings = get(handles.popupmenu1,'String');
PumpName = Strings{get(handles.popupmenu1,'Value')};
PumpCalibration(handles.globalparams,PumpName);
RefreshValues(handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RefreshValues(handles)
global BAPHYHOME;
paramfname = [BAPHYHOME filesep 'Config' filesep 'HWSetupParams.mat'];
HW = InitializeHW(handles.globalparams);
if strcmpi(IODriver(HW),'NIDAQMX'),
  PumpNames={'Pump'};
else
  PumpNames = HW.DIO.Line.Linename;
  PumpNames = PumpNames(~cellfun(@isempty,strfind(PumpNames,'Pump')));
end
cSelection = get(handles.popupmenu1,'value');
if exist(paramfname,'file')
  load(paramfname);
  MicText  = [num2str(MicVRef,'%1.3f') ' v'];
  if ~exist('PumpMlPerSec','var') PumpMlPerSec=NaN; end
  if ~isstruct(PumpMlPerSec) 
    tmp.Pump = PumpMlPerSec; PumpMlPerSec = tmp;
  end
else
  PumpMlPerSec.Pump=0;
end
cPumpName = PumpNames{cSelection};
if ~isfield(PumpMlPerSec,cPumpName) PumpMlPerSec.(cPumpName) = NaN; end
PumpText = [num2str(PumpMlPerSec.(PumpNames{cSelection}),'%1.3f') ' ml/sec'];
if ~exist('MicText','var'), MicText   = '---';end
if ~exist('PumpText','var'), PumpText = '---';end
if ~exist('PumpLast','var'), PumpLast  = '---';end
if ~exist('MicLast','var'), MicLast  = '---';end
if ~exist('EqzLast','var'), EqzLast  = '---';end
if ~exist('EqualizerCurve','var'), EqualizerCurve  = zeros(1,30);end
set(handles.text3,'String',MicText);
set(handles.text2,'string',PumpText);
set(handles.text5,'string',EqzLast);
set(handles.text6,'string',MicLast);
set(handles.text7,'string',PumpLast);
set(handles.popupmenu1,'string',PumpNames);

figure(handles.figure1);
subplot(handles.axes1);
plot(EqualizerCurve,'linewidth',2,'color','k');
axis tight off;

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% help for speaker
helpstr = 'To calibrate the speaker, insert the speaker into animal''s ear and make sure the';
helpstr = [helpstr ' microphone is on.'];
dlg = helpdlg(helpstr);
uiwait(dlg);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% help for microphone
helpstr = 'To calibrate the microphone, use the built in test tone of the unit. Set the key to -20dB. Change it to 0dB AFTER the microphone calibration is done';
dlg = helpdlg(helpstr);
uiwait(dlg);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% help for pump
helpstr = 'To calibrate the pump, make sure that spout is positioned so that water flows somewhere that it can be measured.';
dlg = helpdlg(helpstr);
uiwait(dlg);


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




% --- Executes on button press in buttFlat.
function buttFlat_Callback(hObject, eventdata, handles)
% hObject    handle to buttFlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

attenuation=get(handles.editFlat,'string');
if isempty(attenuation),
    attenuation=0;
else
    attenuation=str2double(attenuation);
end
SpeakerFlatGain(handles.globalparams,attenuation);
RefreshValues(handles);



function editFlat_Callback(hObject, eventdata, handles)
% hObject    handle to editFlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function editFlat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
RefreshValues(handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
