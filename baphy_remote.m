function varargout = baphy_remote(varargin)
% baphy_remote M-file for baphy_remote.fig
%      baphy_remote, by itself, creates a new baphy_remote or raises the existing
%      singleton*.
%
%      H = baphy_remote returns the handle to a new baphy_remote or the handle to
%      the existing singleton*.
%
%      baphy_remote('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in baphy_remote.M with the given input arguments.
%
%      baphy_remote('Property','Value',...) creates a new baphy_remote or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before baphy_remote_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to baphy_remote_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.
% Edit the above text to modify the response to help baphy_remote

% Last Modified by GUIDE v2.5 09-May-2012 16:30:43

% Begin initialization code - DO NOT EDIT
% global varaibles

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @baphy_remote_OpeningFcn, ...
  'gui_OutputFcn',  @baphy_remote_OutputFcn, ...
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
if strcmp(get(0,'DefaultFigureWindowStyle'),'docked')
  set(gcf,'WindowStyle','normal');
end
% End initialization code - DO NOT EDIT



%----------------------------------------------------------------------
% --- Executes just before baphy_remote is made visible.
function baphy_remote_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to baphy_remote (see VARARGIN)

if length(varargin)>0,
  warning('input arguments ignored');
end

baphy_set_path;

global maxchans
M = regexp(fieldnames(handles),'spike(?<Number>[0-9]{1,3})','tokens');
Ind = find(~cellfun(@isempty,M));
maxchans = length(Ind);

% reset gui buttons to passive state
leave_running_state(handles);

% default condition: all active Electrodes are chosen
%for i = 1:maxchans,
%  if ~strcmpi(eval(['get(handles.spike' num2str(i) ',''Enable'')']),'Off')
%        max=eval(['get(handles.spike' num2str(i) ',''Max'')']);
%        temp = strcat('spike', num2str(i));
%        set(handles.(temp), 'Value', max);
%  end
%end

handles.output=[];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes baphy_remote wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%----------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = baphy_remote_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global variables
global RUNNING

% Get default command line output from handles structure
varargout{1} = handles.output;


function enter_running_state(handles);

global STOP_RUNNING RUNNING PAUSED
STOP_RUNNING=0;
PAUSED=0;
RUNNING=1;

inactive(handles.editSigThreshold);
inactive(handles.buttSTRF);
inactive(handles.butt2evp);
inactive(handles.buttRaster);
inactive(handles.clear_all);
inactive(handles.select_all);
inactive(handles.browse);
%inactive(handles.checkShowInc);
inactive(handles.popDataUse);
inactive(handles.checkLFP);
inactive(handles.checkLick);
inactive(handles.checkCompactPlot);
inactive(handles.checkPSTH);
inactive(handles.editPSTHfs);
inactive(handles.editGrid);
inactive(handles.buttFlush);
active(handles.buttStop);
active(handles.pause);

function leave_running_state(handles);

global STOP_RUNNING RUNNING PAUSED
STOP_RUNNING=0;
PAUSED=0;
RUNNING=0;

active(handles.editSigThreshold);
active(handles.buttSTRF);
active(handles.butt2evp);
active(handles.buttRaster);
active(handles.clear_all);
active(handles.select_all);
active(handles.browse);
%active(handles.checkShowInc);
active(handles.popDataUse);
active(handles.checkLFP);
active(handles.checkLick);
active(handles.checkCompactPlot);
active(handles.checkPSTH);
active(handles.editPSTHfs);
active(handles.editGrid);
active(handles.buttFlush);
inactive(handles.buttStop);
inactive(handles.pause);
set(handles.status,'String','Status: Waiting for command');


% ---------------------------------------------------------------------
% --- Executes on button press in pause.
function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global STOP_RUNNING RUNNING PAUSED
if RUNNING,
  PAUSED=1-PAUSED;
  if PAUSED,
    set(handles.status,'String','Status: Paused. Press PAUSE to continue.');
    drawnow;
  end
end


% ---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function text1_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


% ---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function text2_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function  plot_types_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to plot_types (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.type = get(hObject, 'Tag');
guidata(hObject, handles);


% --------------------------------------------------------------------
% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global RUNNING
if RUNNING
  yn=questdlg('Programs appear to be running. Exit anyway?', ...
    'baphy','Yes','No','Yes');
  if strcmpi(yn,'Yes')
    % really stop the experiment
    RUNNING=0;
    window_name = get(handles.figure1, 'Name');
    close(window_name);
  else
    % continue analyzing
    RUNNING=1;
  end
else
  window_name = get(handles.figure1, 'Name');
  close(window_name);
end


% --------------------------------------------------------------------
% --- inactive.
function inactive(handle_tag)
% handles    structure with handles and user data (see GUIDATA)

set(handle_tag, 'Enable', 'off');
drawnow;


% --------------------------------------------------------------------
% --- active.
function active(handle_tag)
% handles    structure with handles and user data (see GUIDATA)

set(handle_tag, 'Enable', 'on');
drawnow;


% --- Executes on button press in select_all.
function select_all_Callback(hObject, eventdata, handles)
% hObject    handle to select_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maxchans;

for i = 1:maxchans
  if ~strcmpi(eval(['get(handles.spike' num2str(i) ',''Enable'')']),'Off')
    max=eval(['get(handles.spike' num2str(i) ',''Max'')']);
    temp = strcat('spike', num2str(i));
    set(handles.(temp), 'Value', max);
  end
end

% --- Executes on button press in clear_all.
function clear_all_Callback(hObject, eventdata, handles)
% hObject    handle to clear_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maxchans;

for i = 1:maxchans
  if ~strcmpi(eval(['get(handles.spike' num2str(i) ',''Enable'')']),'Off')
    min=eval(['get(handles.spike' num2str(i) ',''Min'')']);
    temp = strcat('spike', num2str(i));
    set(handles.(temp), 'Value', min);
  end
end

function file_name_input_Callback(hObject, eventdata, handles)
% hObject    handle to file_name_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_name_input as text
%        str2double(get(hObject,'String')) returns contents of file_name_input as a double
global maxchans
global BAPHY_LAB

mfile=get(handles.file_name_input,'String');

% only fill out form if mfile is there
if ~isempty(mfile) & ~exist([mfile '.m'],'file'),
  warning(sprintf('file: %s.m not found.',mfile));
elseif ~isempty(mfile),
    LoadMFile(mfile);
    d=dir([mfile '.m']);
    
    mode   = globalparams.Physiology;
    
    % initialize the guicontrols
    % available Electrodes
    electrodes = globalparams.NumberOfElectrodes;
    for i=1:min(maxchans,electrodes),
      eval(['set(handles.spike' num2str(i) ',''Enable'',''On'')']);
    end
     if strcmpi(BAPHY_LAB,'lbhb') && ~isempty(get(handles.ChannelChooser,'String')),
       % don't do anything
     else
       set(handles.ChannelChooser,'String',['1:',num2str(electrodes)]);
     end
     
    % Current repetitions
    if isfield(exptparams,'Repetition'),
        set(handles.current_repetition,'String',exptparams.Repetition);
    end
    % Analyzed repetitions
    set(handles.analyzed_repetition,'String',0);
    
    % SET THRESHOLD BASED ON RECORDER
    if ~isfield(globalparams.HWparams,'DAQSystem')
      if globalparams.NumberOfElectrodes >8
        globalparams.HWparams.DAQSystem = 'MANTA';
      else
        globalparams.HWparams.DAQSystem = 'AO';
      end
    end
    if strcmpi(BAPHY_LAB,'lbhb') %, && globalparams.NumberOfElectrodes<8,
       % don't do anything
    else
       switch globalparams.HWparams.DAQSystem
         case 'MANTA';
           %roughly modified by CB 13/02
           %set(handles.editSigThreshold,'String','0');
           set(handles.editSigThreshold,'String','-4.0');
         otherwise,
           set(handles.editSigThreshold,'String','4');
       end
    end
    switch globalparams.HWparams.DAQSystem
      case 'MANTA';
        set(handles.butt2evp,'Visible','off');
      otherwise,
        set(handles.butt2evp,'Visible','on');
    end
    
    %status fields
    set(handles.experiment_input,'String',basename(mfile));
    if isfield(exptparams,'comment'),
        set(handles.comment_input,'String',exptparams.comment);
    end
    set(handles.ferret_input,'String',globalparams.Ferret);
    set(handles.mode_input,'String',globalparams.Physiology);
    set(handles.start_time_input,'String','n/a');
    set(handles.stop_time_input,'String',d.date);
    if iscell(exptparams.runclass),
        runclass=exptparams.runclass{exptparams.thisstimidx};
        set(handles.textRunClass,'String',runclass);
    else
        set(handles.textRunClass,'String',exptparams.runclass);
    end
    
    [pp,bb,ee]=fileparts(mfile);
    if exist([pp filesep 'sorted' filesep bb '.spk.mat'],'file'),
        active(handles.checkUseSorted);
    else
        set(handles.checkUseSorted,'Value',0);
        inactive(handles.checkUseSorted);
    end
    set(handles.status,'String','Status: Loaded parameter file. Waiting for command');
    
    handles.exptparams=exptparams;
    handles.globalparams=globalparams;
    handles.exptevents=exptevents;
    guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function file_name_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_name_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

persistent browsepath
global LOCAL_DATA_ROOT;

if ~isfield(handles,'dirname')  handles.dirname=LOCAL_DATA_ROOT; end

[filename, pathname] = uigetfile({'*.m','baphy files (*.m)';'*.*','All Files (*.*)'},'Pick parameter file',...
  [handles.dirname filesep]);
if ~isequal(filename,0)&~isequal(pathname,0)
  [pathname,filename]=fileparts([pathname filename]);
  indx=findstr(filename,'.');
  if ~isempty(indx)
    filename=filename(1:indx(1)-1);
  end
  set(handles.file_name_input, 'String', [pathname filesep filename]);
  handles.dirname=pathname;
  handles.filename=filename;
  guidata(hObject, handles);
  
  browsepath=fileparts(filename);
end

file_name_input_Callback(hObject, eventdata, handles);

% function run_online_analysis
%
% wrapper for calling online analysis: currently either raster or strf
% estimation. called by buttRaster_Callback or buttSTRF_Callback
function run_online_analysis(hObject, eventdata, handles, analysis_name);

global STOP_RUNNING RUNNING PAUSED
global BATCH_FIGURE_HANDLE
global CLEAR_MFILE_AFTER_LOAD
global USECOMMONREFERENCE

if ~exist('analysis_name','var'),
  analysis_name='strf';
end

% always force creation of new figure on first iteration
BATCH_FIGURE_HANDLE=[];
CLEAR_MFILE_AFTER_LOAD=0;
 
mfile=get(handles.file_name_input,'String');

% Get Channel Selection
global BRChannelChooser maxchans
if isempty(BRChannelChooser) BRChannelChooser = 'Text'; end
switch BRChannelChooser
  case 'Text';
    Electrodes = eval(['[',get(handles.ChannelChooser,'String'),']']);
  case 'Checkbox';
    for i=1:maxchans Electrodes(i) = get(handles.(['spike',n2s(i)]),'Value'); end
    Electrodes = find(Electrodes);
end

sigthreshold=ifstr2num(get(handles.editSigThreshold,'String'));

datausestr=get(handles.popDataUse,'String');
datause=datausestr{get(handles.popDataUse,'Value')};

d=dir([mfile '.m']);
lasttrialcount=0;
enter_running_state(handles);
showinc=get(handles.checkShowInc,'Value');



if get(handles.checkUseSorted,'Enable'),
  options.usesorted=get(handles.checkUseSorted,'Value');
else
  options.usesorted=0;
end
if options.usesorted,
  [pp,bb,ee]=fileparts(mfile);
  spkfile=[pp filesep 'sorted' filesep bb '.spk.mat'];
  
  ss=load(spkfile);
  Electrodes2=[];
  unit=[];
  for cc=1:length(Electrodes),
    % number of units in most recent sorting
    if length(ss.sortinfo{Electrodes(cc)})>0
      ccount=length(ss.sortinfo{Electrodes(cc)}{1});
      Electrodes2=[Electrodes2 repmat(Electrodes(cc),[1 ccount])];
      unit=[unit 1:ccount];
    else
      Electrodes2=[Electrodes2 Electrodes(cc)];
      unit=[unit 0];
    end
  end
  Electrodes=Electrodes2;
else
  unit=ones(size(Electrodes));
end

cctr=0;
while ~STOP_RUNNING,
  dnew=dir([mfile '.m']);
  
  if lasttrialcount==0 || datenum(dnew.date)>datenum(d.date),
    % make sure new version gets loaded
    clear(mfile);
    
    set(handles.status,'String','Status: Computing STRFs');
    drawnow;
    if handles.globalparams.ExperimentComplete,
       trialcount=handles.globalparams.rawfilecount;
    elseif any(handles.globalparams.HWparams.HWSetup==[7,8,10,12]) ||...
        (isfield(handles.globalparams.HWparams,'DAQSystem') &&...
        strcmpi(handles.globalparams.HWparams.DAQSystem,'MANTA')),
      LoadMFile(mfile);
      trialcount=exptevents(end).Trial;
    else
      trialcount=alpha2evp(mfile);
    end
    drawnow;
    if lasttrialcount<trialcount,
      if get(handles.checkShowInc,'Value'),
        % force creation of new figure on each iteration
        BATCH_FIGURE_HANDLE=[];
        disp('creating new figure');
      end
      options.Electrodes=Electrodes;
      options.unit=unit;
      options.datause=datause;
      options.sigthreshold=sigthreshold;
      options.lfp=get(handles.checkLFP,'Value');
      options.compact=get(handles.checkCompactPlot,'Value');
      options.lick=get(handles.checkLick,'Value');
      options.psth=get(handles.checkPSTH,'Value');
      options.psthfs=str2num(get(handles.editPSTHfs,'String'));
      options.runclass=get(handles.textRunClass,'String');
      if isfield(handles.exptparams,'TrialObject') && ...
          isfield(handles.exptparams.TrialObject,'ReferenceHandle'),
        options.ReferenceClass=handles.exptparams.TrialObject.ReferenceHandle.descriptor;
      else
        options.ReferenceClass=[];
      end
      
      gridtext=get(handles.editGrid,'String');
      if ~isempty(gridtext),
        options.ElectrodeMatrix=str2num(gridtext);
      else
        options.ElectrodeMatrix=[];
      end
      
      STOP_RUNNING=online_batch(mfile,analysis_name,options);
      fprintf('Waiting.');
      cctr=0;
    else
      STOP_RUNNING=1;
    end
    lasttrialcount=trialcount;
  end
  if ~STOP_RUNNING,
    set(handles.status,'String','Status: Waiting for next repetition');
    d.date=dnew.date;
    
    % DISPLAY ELABORATE 'PASSING OF TIME' ANIMATION
    if mod(cctr,10)<5,
      fprintf('.');
    else
      fprintf('\b');
    end
    cctr=cctr+1;
    pause(0.5);
  end
end
CLEAR_MFILE_AFTER_LOAD=1;

leave_running_state(handles);
fprintf('DONE\n');


% --- Executes on button press in buttSTRF.
function buttSTRF_Callback(hObject, eventdata, handles)
% hObject    handle to buttSTRF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

run_online_analysis(hObject, eventdata, handles,'strf');

% --- Executes on button press in buttRaster.
function buttRaster_Callback(hObject, eventdata, handles)
% hObject    handle to buttRaster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

run_online_analysis(hObject, eventdata, handles,'raster');

% --- Executes on button press in buttSTRF.
function buttCSD_Callback(hObject, eventdata, handles)
% hObject    handle to buttSTRF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% GET ELECTRODES TO USE
String = get(handles.CSDEditElectrodes,'String');
if strcmp(String,'all')
  Electrodes = eval(get(handles.ChannelChooser,'String'));
else
  try  Electrodes = eval(String);
  catch  fprintf('Electrodes misspecified!\n'); return; 
  end
  if ~isnumeric(Electrodes) | isempty(Electrodes)
    fprintf('Electrodes misspecified!\n'); return; 
  end
end

% GET TRIALS TO USE
String = get(handles.CSDEditTrials,'String');
if strcmp(String,'all')  
  Trials = String;
else
  try  Trials = eval(String);
  catch fprintf('Trials misspecified!\n'); return; 
  end
   if ~isnumeric(Trials) | isempty(Trials)
    fprintf('Trials misspecified!\n'); return; 
  end
end

% GET CURRENT FILENAME
if ~isfield(handles,'filename')  fprintf('Load a recording first!\n'); return; end
cPos = find(handles.filename=='_');
Identifier = handles.filename(1:cPos-1);
 
fprintf(['[ Computing CSD for ',Identifier,' ]\n']);

cFIG = round(1e8*rand)+1;
MD_computeCSD('Identifier',Identifier,'Electrodes',Electrodes,'Trials',Trials,'FIG',cFIG);

UH = []; 
baphy_remote_figsave(cFIG,UH,handles.globalparams,'csd');

% --- Executes on button press in butt2evp.
function butt2evp_Callback(hObject, eventdata, handles)
% hObject    handle to butt2evp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mfile=get(handles.file_name_input,'String');
enter_running_state(handles);
alpha2evp(mfile,1);
leave_running_state(handles);


% --- Executes on button press in buttStop.
function buttStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global STOP_RUNNING RUNNING PAUSED
if RUNNING,
  STOP_RUNNING=1;
end
if PAUSED,
  PAUSED=0;
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

clear globalparams exptparams exptevents


% --- Executes on button press in checkShowInc.
function checkShowInc_Callback(hObject, eventdata, handles)
% hObject    handle to checkShowInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkShowInc




% --- Executes on selection change in popDataUse.
function popDataUse_Callback(hObject, eventdata, handles)
% hObject    handle to popDataUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popDataUse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popDataUse


% --- Executes during object creation, after setting all properties.
function popDataUse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popDataUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end




% --- Executes on key press over browse with no controls selected.
function browse_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in buttFlush.
function buttFlush_Callback(hObject, eventdata, handles)
% hObject    handle to buttFlush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% DEFAULTS
global LOCAL_DATA_ROOT BAPHY_LAB USECOMMONREFERENCE

sFrom=LOCAL_DATA_ROOT;
if isfield(handles,'dirname'),
  sFrom=fileparts(fileparts(handles.dirname));
end
if strcmpi(BAPHY_LAB,'LBHB'),
   sTo='H:\daq\';
   email='';
else
   sTo='M:\daq\';
   email='benglitz@gmail.com';
end

prompt={'Root to flush FROM:','Flush TO:','Verbose (provides debugging infos)','Email Address for Results'};
name='Flush data to server?';
numlines=1;
defaultanswer={sFrom,sTo,'0',email};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if length(answer)==0  disp('Flush cancelled'); return; end

flush_data_to_server(answer{1},answer{2},str2num(answer{3}),answer{4});

function editSigThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editSigThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigThreshold as text
%        str2double(get(hObject,'String')) returns contents of editSigThreshold as a double


% --- Executes during object creation, after setting all properties.
function editSigThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in checkLFP.
function checkLFP_Callback(hObject, eventdata, handles)
% hObject    handle to checkLFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLFP


% --- Executes on button press in checkPSTH.
function checkPSTH_Callback(hObject, eventdata, handles)
% hObject    handle to checkPSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPSTH





function editPSTHfs_Callback(hObject, eventdata, handles)
% hObject    handle to editPSTHfs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPSTHfs as text
%        str2double(get(hObject,'String')) returns contents of editPSTHfs as a double


% --- Executes during object creation, after setting all properties.
function editPSTHfs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPSTHfs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in checkUseSorted.
function checkUseSorted_Callback(hObject, eventdata, handles)
% hObject    handle to checkUseSorted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkUseSorted



function editSortedChannel_Callback(hObject, eventdata, handles)
% hObject    handle to editSortedChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSortedChannel as text
%        str2double(get(hObject,'String')) returns contents of editSortedChannel as a double


% --- Executes during object creation, after setting all properties.
function editSortedChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSortedChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in checkLick.
function checkLick_Callback(hObject, eventdata, handles)
% hObject    handle to checkLick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLick




% --- Executes on button press in spike5.
function spike_Callback(hObject, eventdata, handles)
% hObject    handle to spike5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global BRChannelChooser
BRChannelChooser = 'Checkbox';


% --- Executes on button press in checkCompactPlot.
function checkCompactPlot_Callback(hObject, eventdata, handles)
% hObject    handle to checkCompactPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkCompactPlot


function editGrid_Callback(hObject, eventdata, handles)
% hObject    handle to editGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGrid as text
%        str2double(get(hObject,'String')) returns contents of editGrid as a double


% --- Executes during object creation, after setting all properties.
function editGrid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

function ChannelChooser_CreateFcn(hObject, eventdata, handles)
% SELECT CHANNELS CALLBACK
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ChannelChooser_Callback(hObject, eventdata, handles)

global BRChannelChooser
BRChannelChooser = 'Text';







function CSDEditTrials_Callback(hObject, eventdata, handles)
% hObject    handle to CSDEditTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CSDEditTrials as text
%        str2double(get(hObject,'String')) returns contents of CSDEditTrials as a double


% --- Executes during object creation, after setting all properties.
function CSDEditTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CSDEditTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CSDEditElectrodes_Callback(hObject, eventdata, handles)
% hObject    handle to CSDEditElectrodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CSDEditElectrodes as text
%        str2double(get(hObject,'String')) returns contents of CSDEditElectrodes as a double


% --- Executes during object creation, after setting all properties.
function CSDEditElectrodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CSDEditElectrodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkCommonRef.
function checkCommonRef_Callback(hObject, eventdata, handles)
% hObject    handle to checkCommonRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global USECOMMONREFERENCE;
USECOMMONREFERENCE = get(handles.checkCommonRef,'Value');
