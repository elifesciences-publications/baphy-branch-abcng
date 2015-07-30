%%Generic MATLAB GUI functions
function varargout = pupil_online(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pupil_online_OpeningFcn, ...
                   'gui_OutputFcn',  @pupil_online_OutputFcn, ...
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

function pupil_online_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = pupil_online_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%Set some globals -- Hacked from MANTA M_Defaults.m
global MG
MG=struct();
MG.Stim=struct();
MG.Stim.COMterm = 124; % '|'
MG.Stim.MSGterm = 33; % '!' 
MG.Stim.Port = 33331; %  Port to connect to 33331 rather than MANTA 33330
MG.recording=0;
MG.frames_written=0;
% hard-coding remote (baphy) host for now.
%MG.Stim.Host = 'localhost';
MG.Stim.Host = '10.147.70.6';  % weasel.ohsu.edu
I = ver('instrument');
if ~isempty(I)
  MG.Stim.Package = 'ICT'; % Instrument Control Toolbox
else 
  error(['Instrument Control Toolbox needs to be installed, since there is no free package that supports Callback functions at this point.']);
  MG.Stim.Package = 'jTCP'; % Java TCP by Kevin Bartlett (http://www.mathworks.com/matlabcentral/fileexchange/24524-tcpip-communications-in-matlab)
  I = which('jtcp');
  if isempty(I) 
    MG.Stim.Pacakge = 'None';
    fprintf(['WARNING : NO TCPIP SUITE FOUND!\n'...
      '\tNeither the instrument control toolbox, nor the open source tcpip suite jTCP have been detected.\n '...
      '\tPlease install either of those two, in order to connect to a controller/stimulator\n']); 
  end
end

%Camera Interface
function video_file_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function preview_video_Callback(hObject, eventdata, handles)

global MG

if isfield(MG, 'cam')
    closepreview(MG.cam)
    %rmfield(handles, 'rect')
end
MG.cam = videoinput('winvideo', 1);
MG.cam.ReturnedColorSpace = 'RGB';
res = MG.cam.VideoResolution;
nbands = MG.cam.NumberOfBands;
himage = image(zeros(res(2), res(1), nbands), 'Parent', handles.preview_ax);
preview(MG.cam, himage);
guidata(hObject, handles)

function set_roi_Callback(hObject, eventdata, handles)

global MG

if isfield(MG, 'cam')
    MG.im = getsnapshot(MG.cam);
else
    disp('Pupil_Online: Error - No active camera.')
end
figure
imshow(MG.im)
r = imrect;
MG.roi = getPosition(r);
close
axes(handles.preview_ax)
if isfield(handles, 'rect')
    set(handles.rect, 'Position', MG.roi);
else
    handles.rect = rectangle('Position', MG.roi, ...
                             'Linewidth', 1, ...
                             'EdgeColor', 'b');
end
guidata(hObject, handles)

%Communication with Baphy
function connect_Callback(hObject, eventdata, handles)
global MG
MG.hObject = hObject;
MG.handles = handles;
State = get(hObject,'Value');
set(handles.status_msg, 'String', ['Connect: ',num2str(State)]);
if State M_startTCPIP; else M_stopTCPIP; end


% --- Executes on button press in checkRunning.
function checkRunning_Callback(hObject, eventdata, handles)
% hObject    handle to checkRunning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: get(hObject,'Value') returns toggle state of checkRunning
