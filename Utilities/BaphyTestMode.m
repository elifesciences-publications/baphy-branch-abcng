function varargout = BaphyTestMode(varargin)
% BAPHYTESTMODE M-file for BaphyTestMode.fig
%      BAPHYTESTMODE, by itself, creates a new BAPHYTESTMODE or raises the existing
%      singleton*.
%
%      H = BAPHYTESTMODE returns the handle to a new BAPHYTESTMODE or the handle to
%      the existing singleton*.
%
%      BAPHYTESTMODE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAPHYTESTMODE.M with the given input arguments.
%
%      BAPHYTESTMODE('Property','Value',...) creates a new BAPHYTESTMODE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JobMonitor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BaphyTestMode_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BaphyTestMode

% Last Modified by GUIDE v2.5 26-Nov-2012 21:03:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BaphyTestMode_OpeningFcn, ...
                   'gui_OutputFcn',  @BaphyTestMode_OutputFcn, ...
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


% --- Executes just before BaphyTestMode is made visible.
function BaphyTestMode_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BaphyTestMode (see VARARGIN)

global TOUCHSTATE0
global BAPHYHOME

TOUCHSTATE0=0;

% Choose default command line output for BaphyTestMode
handles.output = hObject;
handles.CancelStat = 0;

% UIWAIT makes BaphyTestMode wait for user response (see UIRESUME)
% uiwait(handles.BaphyTestMode);

TestFile=[BAPHYHOME filesep 'Config' filesep 'BaphyTestSettings.mat'];
set(handles.textFilename,'String',TestFile);

% Initialize cancel button readout
set(handles.JobMonitor,'UserData',handles.CancelStat);

waveform=zeros(1000,1);
fs=1000;
axes(handles.axesWaveform);
plot((1:length(waveform))./fs,waveform);


% Initialize values reported in text boxes
JobMonitor_Refresh(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);



function JobMonitor_Refresh(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BaphyTestMode (see VARARGIN)

%handles=guidata(hObject);

global TOUCHSTATE0

set(handles.buttLick,'String',sprintf('Lick=%d',TOUCHSTATE0));
set(handles.JobMonitor,'UserData',handles.CancelStat);

CancelStat=handles.CancelStat;

fprintf('saving Touch %d Cancel %d\n',TOUCHSTATE0,CancelStat);

TestFile=get(handles.textFilename,'String');
save(TestFile,'TOUCHSTATE0','CancelStat');


% Update handles structure
guidata(hObject, handles);


function JobMonitor_PlotWaveform(hObject, eventdata, handles, varargin)

handles=guidata(hObject);
waveform=varargin{1};
if nargin>2,
    fs=varargin{2};
else
    fs=1./length(waveform);
end
ha=handles.axesWaveform;
plot(ha,waveform(:,1),'b');
if size(waveform,2)>1,
    hold(ha,'on');
    plot(ha,waveform(:,2),'r');
    hold(ha,'off');
end
axis(ha,[1 length(waveform) -5 5]);
set(ha,'Xticklabel',[],'Yticklabel',[]);

%hc=get(handles.axesWaveform,'Children');
%set(hc,'Xdata',(1:length(waveform))./fs,'YData',waveform(:,1));

drawnow

% --- Outputs from this function are returned to the command line.
function varargout = BaphyTestMode_OutputFcn(hObject, eventdata, handles, varargin) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% always cancel if cancel pressed.  User can choose to continue if they
% want.
handles.CancelStat = 1;

JobMonitor_Refresh(hObject, eventdata, handles);

guidata(hObject, handles);




% --- Executes on button press in buttLick.
function buttLick_Callback(hObject, eventdata, handles)
% hObject    handle to buttLick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global TOUCHSTATE0

TOUCHSTATE0=1-TOUCHSTATE0;

JobMonitor_Refresh(hObject, eventdata, handles);

if TOUCHSTATE0==1,
   t = timer('TimerFcn',@(Handle,Event)LickStop(hObject, eventdata, handles),'StartDelay',0.1);
   start(t);
end

function LickStop(hObject, eventdata, handles)

global TOUCHSTATE0

TOUCHSTATE0=0;

JobMonitor_Refresh(hObject, eventdata, handles);
