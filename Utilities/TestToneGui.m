function varargout = TestToneGui(varargin)
% TESTTONEGUI M-file for TestToneGui.fig
%      TESTTONEGUI, by itself, creates a new TESTTONEGUI or raises the existing
%      singleton*.
%
%      H = TESTTONEGUI returns the handle to a new TESTTONEGUI or the handle to
%      the existing singleton*.
%
%      TESTTONEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTTONEGUI.M with the given input arguments.
%
%      TESTTONEGUI('Property','Value',...) creates a new TESTTONEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TestToneGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TestToneGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TestToneGui

% Last Modified by GUIDE v2.5 13-Nov-2012 14:22:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TestToneGui_OpeningFcn, ...
                   'gui_OutputFcn',  @TestToneGui_OutputFcn, ...
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


% --- Executes just before TestToneGui is made visible.
function TestToneGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TestToneGui (see VARARGIN)

% Choose default command line output for TestToneGui
handles.output = hObject;

% Update handles structure
handles.output=handles.figure1;
handles.running=0;
handles.quit=0;

if ~isempty(varargin),
    disp('Setting initial values');
    datavector=varargin{1};
    if length(datavector)>=7,
        set(handles.editFreq,'String',num2str(datavector(2)));
        set(handles.editRate,'String',num2str(datavector(3)));
        set(handles.editLevel,'String',num2str(datavector(4)));
        set(handles.editDuration,'String',num2str(datavector(5)));
        set(handles.editISI,'String',num2str(datavector(6)));
        set(handles.editBandwidth,'String',num2str(datavector(7)));
        
        editFreq_Callback(hObject, eventdata, handles)
        editRate_Callback(hObject, eventdata, handles)
        editLevel_Callback(hObject, eventdata, handles)
        editDuration_Callback(hObject, eventdata, handles)
        editISI_Callback(hObject, eventdata, handles)
        editBandwidth_Callback(hObject, eventdata, handles)
    end
end


guidata(hObject, handles);

% UIWAIT makes TestToneGui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TestToneGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles,'output'),
  varargout{1} = handles.output;
else
  varargout{1}=1;
end


function update_userdata(hObject,handles);

% put important paramters in figure's UserData field for easy access from
% the outside
datavector=[handles.running str2num(get(handles.editFreq,'string'))...
  str2num(get(handles.editRate,'string')) ...
  str2num(get(handles.editLevel,'string')) ...
  str2num(get(handles.editDuration,'string')) ...
  str2num(get(handles.editISI,'string')) ...
  str2num(get(handles.editBandwidth,'string')) ...
  ];
set(handles.figure1,'UserData',datavector);


% --- Executes on button press in buttStartStop.
function buttStartStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttStartStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.running=1-handles.running;

if handles.running,
  set(handles.buttStartStop,'String','Stop');
  
  freq=str2num(get(handles.editFreq,'String'));
  rate=str2num(get(handles.editRate,'String'));
  level=str2num(get(handles.editLevel,'String'));
  attendb=80-level;
  %fprintf('Starting tones at %.0fHz carrier / %.0f Hz AM (-%.0f dB)\n',...
  %  freq,rate,attendb);
  
else
  set(handles.buttStartStop,'String','Start');
  %disp('Stopping');
  
end

guidata(hObject, handles);
update_userdata(hObject,handles);
uiresume;


% --- Executes on button press in buttQuit.
function buttQuit_Callback(hObject, eventdata, handles)
% hObject    handle to buttQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.running,
  buttStartStop_Callback(hObject, eventdata, handles);
end

handles.quit = 1;
handles.output = [];
guidata(hObject, handles);
close(handles.figure1);
disp('TestToneGui done.');

%uiresume;

% --- Executes on slider movement.
function sliderFreq_Callback(hObject, eventdata, handles)
% hObject    handle to sliderFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

lfreq=get(handles.sliderFreq,'value');
set(handles.editFreq,'String',num2str(round(2.^lfreq)));
update_userdata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function sliderFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderLevel_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
level=get(handles.sliderLevel,'value');
set(handles.editLevel,'String',num2str(level));
update_userdata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function sliderLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderRate_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
rate=get(handles.sliderRate,'value');
set(handles.editRate,'String',num2str(rate));
update_userdata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sliderRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFreq as text
%        str2double(get(hObject,'String')) returns contents of editFreq as a double

freq=str2num(get(handles.editFreq,'string'));
lfreq=log2(freq);
smin=get(handles.sliderFreq,'Min');
smax=get(handles.sliderFreq,'Max');

if lfreq<smin,
  set(handles.sliderFreq,'Value',smin);
elseif lfreq>smax,
  set(handles.sliderFreq,'Value',smax);
else
  set(handles.sliderFreq,'Value',lfreq);
end
update_userdata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRate_Callback(hObject, eventdata, handles)
% hObject    handle to editRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRate as text
%        str2double(get(hObject,'String')) returns contents of editRate as a double

rate=str2num(get(handles.editRate,'string'));
smin=get(handles.sliderRate,'Min');
smax=get(handles.sliderRate,'Max');

if rate<smin,
  set(handles.sliderRate,'Value',smin);
elseif rate>smax,
  set(handles.sliderRate,'Value',smax);
else
  set(handles.sliderRate,'Value',rate);
end
update_userdata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editLevel_Callback(hObject, eventdata, handles)
% hObject    handle to editLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLevel as text
%        str2double(get(hObject,'String')) returns contents of editLevel as a double

level=str2num(get(handles.editLevel,'string'));
smin=get(handles.sliderLevel,'Min');
smax=get(handles.sliderLevel,'Max');

if level<smin,
  set(handles.sliderLevel,'Value',smin);
elseif level>smax,
  set(handles.sliderLevel,'Value',smax);
else
  set(handles.sliderLevel,'Value',level);
end
update_userdata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderDuration_Callback(hObject, eventdata, handles)
% hObject    handle to sliderDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Duration=get(handles.sliderDuration,'value');
set(handles.editDuration,'String',num2str(Duration));
update_userdata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sliderDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editDuration_Callback(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDuration as text
%        str2double(get(hObject,'String')) returns contents of editDuration as a double

Duration=str2num(get(handles.editDuration,'string'));
smin=get(handles.sliderDuration,'Min');
smax=get(handles.sliderDuration,'Max');

if Duration<smin,
  set(handles.sliderDuration,'Value',smin);
elseif Duration>smax,
  set(handles.sliderDuration,'Value',smax);
else
  set(handles.sliderDuration,'Value',Duration);
end
update_userdata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderISI_Callback(hObject, eventdata, handles)
% hObject    handle to sliderISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ISI=get(handles.sliderISI,'value');
set(handles.editISI,'String',num2str(ISI));
update_userdata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function sliderISI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editISI_Callback(hObject, eventdata, handles)
% hObject    handle to editISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editISI as text
%        str2double(get(hObject,'String')) returns contents of editISI as a double

ISI=str2num(get(handles.editISI,'string'));
smin=get(handles.sliderISI,'Min');
smax=get(handles.sliderISI,'Max');

if ISI<smin,
  set(handles.sliderISI,'Value',smin);
elseif ISI>smax,
  set(handles.sliderISI,'Value',smax);
else
  set(handles.sliderISI,'Value',ISI);
end
update_userdata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editISI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderBandwidth_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

BW=get(handles.sliderBandwidth,'value');
set(handles.editBandwidth,'String',num2str(BW));
update_userdata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function sliderBandwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editBandwidth_Callback(hObject, eventdata, handles)
% hObject    handle to editBandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBandwidth as text
%        str2double(get(hObject,'String')) returns contents of editBandwidth as a double

BW=str2num(get(handles.editBandwidth,'string'));
smin=get(handles.sliderBandwidth,'Min');
smax=get(handles.sliderBandwidth,'Max');

if BW<smin,
  set(handles.sliderBandwidth,'Value',smin);
elseif BW>smax,
  set(handles.sliderBandwidth,'Value',smax);
else
  set(handles.sliderBandwidth,'Value',BW);
end
update_userdata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editBandwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
