function varargout = WaterPumpControl(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @WaterPumpControl_OpeningFcn, ...
    'gui_OutputFcn',  @WaterPumpControl_OutputFcn, ...
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

% --- Executes just before WaterPumpControl is made visible.
function WaterPumpControl_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.pumppro = varargin{1};

if varargin{2} == 1
    set(handles.edit1,'String', num2str(handles.pumppro));
end

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = WaterPumpControl_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output

function edit1_Callback(hObject, eventdata, handles)
handles.output= str2num(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
