function varargout = JobMonitor(varargin)
% JOBMONITOR M-file for JobMonitor.fig
%      JOBMONITOR, by itself, creates a new JOBMONITOR or raises the existing
%      singleton*.
%
%      H = JOBMONITOR returns the handle to a new JOBMONITOR or the handle to
%      the existing singleton*.
%
%      JOBMONITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JOBMONITOR.M with the given input arguments.
%
%      JOBMONITOR('Property','Value',...) creates a new JOBMONITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JobMonitor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to JobMonitor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help JobMonitor

% Last Modified by GUIDE v2.5 22-Sep-2006 09:57:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JobMonitor_OpeningFcn, ...
                   'gui_OutputFcn',  @JobMonitor_OutputFcn, ...
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


% --- Executes just before JobMonitor is made visible.
function JobMonitor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to JobMonitor (see VARARGIN)

% Choose default command line output for JobMonitor
handles.output = hObject;

% UIWAIT makes JobMonitor wait for user response (see UIRESUME)
% uiwait(handles.JobMonitor);

globalparams=varargin{1};
events=varargin{2};

% Initialize cancel button readout
if ~isfield(handles,'CancelStat'),
    handles.CancelStat = 0;
end
set(handles.JobMonitor,'UserData',handles.CancelStat);

waveform=zeros(1000,1);
fs=1000;
axes(handles.axesWaveform);
plot((1:length(waveform))./fs,waveform);


% Initialize values reported in text boxes
JobMonitor_Refresh(hObject, eventdata, handles, globalparams, events)

% Update handles structure
guidata(hObject, handles);



function JobMonitor_Refresh(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to JobMonitor (see VARARGIN)

handles=guidata(hObject);
globalparams=varargin{1};
events=varargin{2};

global TOUCHSTATE0

set(handles.buttLick,'String',sprintf('Lick=%d',TOUCHSTATE0));
if globalparams.HWSetup>0,
    set(handles.buttLick,'Enable','off');
end

if length(events)==0,
    trials=0;
    cortrials=0;
else
    trials=length(evtimes(events,'TRIALSTART'));
    cortrials=length(evtimes(events,'OUTCOME,MATCH'));
end

pstring=sprintf('Animal: %s  Site: %s\nPerformance: %d/%d\n',...
    globalparams.Ferret,globalparams.SiteID,cortrials,trials);
set(handles.textParams,'String',pstring);

set(handles.textFilename,'String',globalparams.mfilename);

handles.CancelStat = 0;
set(handles.JobMonitor,'UserData',handles.CancelStat);

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
function varargout = JobMonitor_OutputFcn(hObject, eventdata, handles, varargin) 
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
%handles.CancelStat = 1-handles.CancelStat;
set(handles.JobMonitor,'UserData',handles.CancelStat);



guidata(hObject, handles);




% --- Executes on button press in buttLick.
function buttLick_Callback(hObject, eventdata, handles)
% hObject    handle to buttLick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global TOUCHSTATE0

TOUCHSTATE0=1-TOUCHSTATE0;

set(handles.buttLick,'String',sprintf('Lick=%d',TOUCHSTATE0));


