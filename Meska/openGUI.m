function varargout = openGUI(varargin)
% OPENGUI M-file for openGUI.fig
%      OPENGUI, by itself, creates a new OPENGUI or raises the existing
%      singleton*.
%
%      H = OPENGUI returns the handle to a new OPENGUI or the handle to
%      the existing singleton*.
%
%      OPENGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPENGUI.M with the given input arguments.
%
%      OPENGUI('Property','Value',...) creates a new OPENGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before openGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to openGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help openGUI

% Last Modified by GUIDE v2.5 20-Jan-2006 16:47:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @openGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @openGUI_OutputFcn, ...
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


% --- Executes just before openGUI is made visible.
function openGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to openGUI (see VARARGIN)

global OPEN_path

if isempty(OPEN_path),
    OPEN_path=pwd;
end
handles.dirname=OPEN_path;

% Choose default command line output for openGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes openGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = openGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global OPEN_path
OPEN_path=handles.dirname;

% Get default command line output from handles structure
for ii=1:length(handles.output),
    varargout{ii} = handles.output{ii};
end

close(handles.figure1);
drawnow;


% --- Executes on button press in txtFile1.
function txtFile1_Callback(hObject, eventdata, handles)
% hObject    handle to txtFile1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pathname,filename]=fileparts(get(handles.txtFile1,'String'));
handles.dirname=pathname;
handles.filename1=filename;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtFile1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFile1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in buttBrowse1.
function buttBrowse1_Callback(hObject, eventdata, handles)
% hObject    handle to buttBrowse1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(findstr('GLNX',computer)),
   files=uipickfiles('num',1,'Prompt','Pick evp file',...
                     'FilterSpec',[handles.dirname filesep '*.evp']);
   [filename,pathname]=basename(files{1});
else
   [filename,pathname] = uigetfile(...
      {'*.evp','evp files (*.evp)';'*.*','All Files (*.*)'},...
      'Pick evp file',[handles.dirname filesep]);
end

if ~isequal(filename,0) & ~isequal(pathname,0)
    set(handles.txtFile1, 'String', fullfile(pathname,filename));
    handles.dirname=pathname;
end

txtFile1_Callback(hObject, eventdata, handles);


function txtFile2_Callback(hObject, eventdata, handles)
% hObject    handle to txtFile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFile2 as text
%        str2double(get(hObject,'String')) returns contents of txtFile2 as a double

[pathname,filename]=fileparts(get(handles.txtFile2,'String'));
handles.dirname=pathname;
handles.filename2=filename;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtFile2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttBrowse2.
function buttBrowse2_Callback(hObject, eventdata, handles)
% hObject    handle to buttBrowse2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(findstr('GLNX',computer)),
   files=uipickfiles('num',1,'Prompt','Pick evp file',...
                     'FilterSpec',[handles.dirname filesep '*.evp']);
   [filename,pathname]=basename(files{1});
else
   [filename, pathname] = uigetfile({'*.evp','evp files (*.evp)';'*.*','All Files (*.*)'},'Pick evp file',...
                                    [handles.dirname filesep]);
end

if ~isequal(filename,0) & ~isequal(pathname,0)
    set(handles.txtFile2, 'String', fullfile(pathname,filename));
    handles.dirname=pathname;
end

txtFile2_Callback(hObject, eventdata, handles);


% --- Executes on button press in buttOK.
function buttOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkTwoFiles,'Value'),
    handles.output={get(handles.txtFile1,'String'),...
                    get(handles.txtFile2,'String'),...
                    get(handles.popChannel,'Value')};
else
    % make sure second file is empty
    handles.output={get(handles.txtFile1,'String'),...
                    [],...
                    get(handles.popChannel,'Value')};
end

guidata(hObject, handles);

uiresume;



% --- Executes on button press in buttCancel.
function buttCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output={[] [] 0};
guidata(hObject, handles);

uiresume;



% --- Executes on button press in checkTwoFiles.
function checkTwoFiles_Callback(hObject, eventdata, handles)
% hObject    handle to checkTwoFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkTwoFiles

if get(hObject,'Value'),
    h_active(handles.txtFile2);
    h_active(handles.buttBrowse2);
else
    h_inactive(handles.txtFile2);
    h_inactive(handles.buttBrowse2);
end



% --- Executes on selection change in popChannel.
function popChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popChannel


% --- Executes during object creation, after setting all properties.
function popChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


