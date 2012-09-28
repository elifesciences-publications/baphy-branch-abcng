function varargout = BaphyMainGui(varargin)
% BAPHYMAINGUI M-file for BaphyMainGui.fig
%      BAPHYMAINGUI, by itself, creates a new BAPHYMAINGUI or raises the existing
%      singleton*.
%
%      H = BAPHYMAINGUI returns the handle to a new BAPHYMAINGUI or the handle to
%      the existing singleton*.
%
%      BAPHYMAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAPHYMAINGUI.M with the given input arguments.
%
%      BAPHYMAINGUI('Property','Value',...) creates a new BAPHYMAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BaphyMainGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BaphyMainGui_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BaphyMainGui

% Last Modified by GUIDE v2.5 29-Nov-2007 10:42:02

% Begin initialization code - DO NOT EDIT
if isempty(which('InitializeHW'))
    startup;
end

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BaphyMainGui_OpeningFcn, ...
    'gui_OutputFcn',  @BaphyMainGui_OutputFcn, ...
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


% --- Executes just before BaphyMainGui is made visible.
function BaphyMainGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BaphyMainGui (see VARARGIN)

% Choose default command line output for BaphyMainGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Center the gui:
%movegui(hObject,'center');
% loading the fields
set(handles.popupmenu1,'String',BaphyMainGuiItems('Tester'));
if get(handles.popupmenu1,'Value')>length(get(handles.popupmenu1,'String')),
    set(handles.popupmenu1,'Value',1);
end
set(handles.popupmenu2,'String',BaphyMainGuiItems('Ferret'));
set(handles.popupmenu3,'String',BaphyMainGuiItems('Module'));
set(handles.popupmenu4,'String',BaphyMainGuiItems('Physiology'));
set(handles.edit1,'String',BaphyMainGuiItems('SiteID'));
set(handles.popupmenu7,'String',BaphyMainGuiItems('HWSetup'));
set(handles.edit2,'String',BaphyMainGuiItems('NumberOfElectrodes'));
% Now read the last settings from last time Baphy was used:
global BAPHYHOME;
if exist([BAPHYHOME filesep 'Config' filesep 'BaphyMainGuiSettings.mat']);
    load_settings(handles);
end
popupmenu2_Callback([], [], handles);



% UIWAIT makes BaphyMainGui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BaphyMainGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = handles.globalparams;
varargout{2} = handles.quit_baphy;
delete(handles.figure1);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

% Tester Callback:
% when the user changes, load the default settings for him/her:
global BAPHYHOME;
if exist([BAPHYHOME filesep 'Config' filesep 'BaphyMainGuiSettings.mat']);
    load_settings(handles,get(handles.popupmenu1,'Value'));
    guidata(hObject,handles);
end
popupmenu2_Callback([], [], handles);

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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

% get name of Ferret
contents = get(handles.popupmenu2,'String');
Ferret=contents{min(length(contents),get(handles.popupmenu2,'Value'))};

% get Training/physiology flag
contents = get(handles.popupmenu4,'String');
doingphysiology=~strcmp(contents{get(handles.popupmenu4,'Value')},'No');

% figure out Ferret's last siteid (should be db-robust
% this line has failed several times so far:
siteid=[];
try
    set(handles.pushbutton1,'Enable','off');
    drawnow
    siteid=dbgetlastsite(Ferret,doingphysiology);
    sql=['SELECT * FROM gAnimal WHERE animal="',Ferret,'"'];
    fdata=mysql(sql);
    figure(handles.figure1);
    if ~isempty(fdata) && ~isempty(fdata.photourl),
        f=urlwrite(fdata.photourl,tempname);
        s=imread(f,'jpeg');
        delete(f);
        subplot(handles.axes1);
        imagesc(s);
        axis image off;
    elseif exist('Ferret.jpg')
        ferret=imread('Ferret.jpg');
        subplot(handles.axes1),imagesc(ferret);
        axis image off;
    end
    drawnow
catch
    warning(['Database failed in dbgetlastsite: ' lasterr]);
    if exist('Ferret.jpg')
        ferret=imread('Ferret.jpg');
        subplot(handles.axes1),imagesc(ferret);
        axis image off;
    end
end
set(handles.pushbutton1,'Enable','on');

% save new siteid to edit box
set(handles.edit1,'String',siteid);


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4

% same action as if Ferret popup changed
popupmenu2_Callback([], eventdata, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Continue button
% Continue: save all the settings and variables and exit.
save_settings(handles);
handles.globalparams = Createglobalparams(handles);

siteid=handles.globalparams.SiteID;
doingphysiology=~strcmp(handles.globalparams.Physiology,'No');
defsiteid=dbgetlastsite(handles.globalparams.Ferret,doingphysiology);

penid=siteid(1:(end-1));
defpenid=defsiteid(1:(end-1));

if ~strcmp(defpenid,penid),
    dlg=questdlg(['Penetration name (',penid,') does not match default (',...
        defpenid,')! Continue?']);
    if ~strcmpi(dlg,'Yes')
        return;
    end
end

if ~isfield(handles.globalparams,'PumpMlPerSec')
    dlg=questdlg('Calibration data for this setup does not exist, continue?');
    if ~strcmpi(dlg,'Yes')
        return;
    end
end
quit_baphy=0;
handles.quit_baphy = quit_baphy;
guidata(handles.figure1, handles);
uiresume;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Exit button:
save_settings(handles);
quit_baphy=1;
handles.globalparams = Createglobalparams(handles);
% handles.globalparams = globalparams;
handles.quit_baphy = quit_baphy;
guidata(handles.figure1, handles);
uiresume;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calibration
handles.globalparams = Createglobalparams(handles);
handles.globalparams.AOTriggerType = 'HWDigital';
if handles.globalparams.HWSetup>0
    set(handles.figure1,'visible','off');
    try
        CalibrationGUI(handles.globalparams);
        set(handles.figure1,'visible','on');
    catch
        set(handles.figure1,'visible','on');
    end
end
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.globalparams = Createglobalparams(handles);
handles.globalparams.AOTriggerType = 'HWDigital';
if handles.globalparams.HWSetup>0
    set(handles.figure1,'visible','off');
    cmdstr=[handles.globalparams.TuningCurveCommand,'(handles.globalparams);'];
    try
        eval(cmdstr);
        set(handles.figure1,'visible','on');
    catch
        set(handles.figure1,'visible','on');
    end
end

% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Load settings
% This function read the settings from the configuration file
% It reads a cell array called user. Each cell of user has a structure
% named 'settings' which has all the menu selections for that specific
% user. Last user is always used to initialize the gui.
function load_settings(handles,current_user);
global BAPHYHOME;
try
    load ([BAPHYHOME filesep 'Config' filesep 'BaphyMainGuiSettings.mat']);
    if nargin<2 current_user=lastuser;end
    if current_user<=length(user),  settings=user{current_user};else settings=[];end
    if ~isempty(settings)
        if length(get(handles.popupmenu1,'String')) < current_user,
            current_user=1;
        end
        set(handles.popupmenu1,'Value',current_user);
        set(handles.popupmenu2,'Value',min(settings.Ferret,length(get(handles.popupmenu2,'String'))));
        set(handles.popupmenu3,'Value',settings.Module);
        set(handles.popupmenu4,'Value',settings.Physiology);
        set(handles.edit1,'String',settings.SiteID);
        set(handles.edit2,'String',settings.NumberOfElectrodes);
        set(handles.popupmenu7,'Value',settings.HWsetup);
    end
catch
    % the file is corrupted (perhaps because of major change in
    % baphymaingui)
    delete([BAPHYHOME filesep 'Config' filesep 'BaphyMainGuiSettings.mat']);
end

%
function save_settings (handles)
% this function save the current setting for the specified user
% user is a cell array, with indices from 1 to number of users
% in each cell array, a structure named "settings" holds all the menu items
% for that user. When this function is called, it first loads the uesr
% array, update the corresponding one and save it back.
global BAPHYHOME
if exist([BAPHYHOME filesep 'Config' filesep 'BaphyMainGuiSettings.mat']);
    load ([BAPHYHOME filesep 'Config' filesep 'BaphyMainGuiSettings.mat']);
end
user_index = get(handles.popupmenu1,'Value');
settings.Ferret = get(handles.popupmenu2,'Value');
settings.Module = get(handles.popupmenu3,'Value');
settings.Physiology = get(handles.popupmenu4,'Value');
settings.SiteID = get(handles.edit1,'String');
settings.HWsetup = get(handles.popupmenu7,'Value');
settings.NumberOfElectrodes = get(handles.edit2,'String');
% now put it in the correct cell
user{user_index}=settings;
lastuser=user_index;
save ([BAPHYHOME filesep 'Config' filesep 'BaphyMainGuiSettings.mat'],'user','lastuser');





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




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenu2.
function popupmenu2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in bNewSite.
function bNewSite_Callback(hObject, eventdata, handles)
% hObject    handle to bNewSite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save new siteid to edit box
ositeid=get(handles.edit1,'String');

if isempty(ositeid),
    % get name of Ferret
    contents = get(hObject,'String');
    Ferret=contents{get(hObject,'Value')};

    % figure out Ferret's last siteid (should be db-robust
    ositeid=dbgetlastsite(Ferret);
end

if isempty(ositeid),
    msgbox('Old SiteID must be specified first','Baphy','error');
    return
end

siteletter=ositeid(end);
if siteletter<'a' | siteletter>'z',
    msgbox('SiteID must end in letter a-z','Baphy','error');
    return
end

siteid=[ositeid(1:end-1) char(double(siteletter)+1)];

% save new siteid to edit box
set(handles.edit1,'String',siteid);



% --- Executes on button press in bNewPen.
function bNewPen_Callback(hObject, eventdata, handles)
% hObject    handle to bNewPen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save new siteid to edit box
ositeid=get(handles.edit1,'String');

if isempty(ositeid),
    % get name of Ferret
    contents = get(hObject,'String');
    Ferret=contents{get(hObject,'Value')};

    % figure out Ferret's last siteid (should be db-robust
    ositeid=dbgetlastsite(Ferret);
end

if isempty(ositeid),
    msgbox('Old SiteID must be specified first','Baphy','error');
    return
end

numidx=find(ositeid>='0' & ositeid<='9');
pennum=str2num(ositeid(numidx));

siteid=[ositeid(1:numidx(1)-1) sprintf('%03d',pennum+1) ...
    ositeid(numidx(end)+1:end)];

% save new siteid to edit box
set(handles.edit1,'String',siteid);



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% analysis push button:
baphy_remote;


% --- Executes during object creation, after setting all properties.
function editPump_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPump_Callback(hObject, eventdata, handles)
% hObject    handle to editPump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPump as text
%        str2double(get(hObject,'String')) returns contents of editPump as a double


%%%%%%%%%%%%%%%%%%%%%%%%%
function globalparams = Createglobalparams(handles)
global BAPHYHOME;
t1=get(handles.popupmenu1,'Value');
t2=get(handles.popupmenu1,'String');
globalparams.Tester = t2{t1};                       % output 1: Tester
t1=get(handles.popupmenu2,'Value');
t2=get(handles.popupmenu2,'String');
globalparams.Ferret = t2{t1};                       % output 2: Ferret
t1=get(handles.popupmenu3,'Value');
t2=get(handles.popupmenu3,'String');
globalparams.Module = t2{t1};                       % output 3: Module
t1=get(handles.popupmenu4,'Value');
t2=get(handles.popupmenu4,'String');
globalparams.Physiology = t2{t1};                         % output 4: Physiology
t2=get(handles.edit1,'String');
globalparams.SiteID = t2;                           % output 5: SiteID
t1=get(handles.popupmenu7,'Value');
t2=get(handles.popupmenu7,'String');
HWsetupID = (t2{t1}(1:3));
ColonIndex = strfind(HWsetupID,':');
globalparams.HWSetup = str2num(t2{t1}(1:ColonIndex-1));          % output 6: Hardware Setup
t2=get(handles.edit2,'String');
globalparams.NumberOfElectrodes = str2num(t2);      % output 7: Number OF Electrodes
globalparams.date = datestr(now,29);
% Based on the Module, specify initilize and run command
globalparams.initcommand=BaphyMainGuiItems('initcommand',globalparams);
globalparams.runcommand=BaphyMainGuiItems('runcommand',globalparams);
globalparams.TuningCurveCommand=BaphyMainGuiItems('TuningCurveCommand',globalparams);
if isempty(globalparams.TuningCurveCommand),
  globalparams.TuningCurveCommand='BaphyTuningCurve';
end
globalparams.AOTriggerType = BaphyMainGuiItems('AOTriggerType',globalparams);
globalparams.LickSign = BaphyMainGuiItems('LickSign',globalparams);
paramfname = [BAPHYHOME filesep 'Config' filesep 'HWSetupParams.mat'];
if exist(paramfname,'file')
    load (paramfname);
    if ~exist('PumpMlPerSec','var') || isnan(PumpMlPerSec.Pump),
        PumpMlPerSec.Pump=1.4;
    end
    globalparams.PumpMlPerSec = PumpMlPerSec;
    globalparams.MicVRef = MicVRef;
    globalparams.EqualizerCurve = EqualizerCurve;
else
    globalparams.PumpMlPerSec.Pump = 0;
    globalparams.MicVRef = 0;
    globalparams.EqualizerCurve = 0;
end
% warning('fixing equalizer curve at 14 all the way across!!!!');
% globalparams.EqualizerCurve(:)=14;

% --- Executes on button press in buttCellDB.
function buttCellDB_Callback(hObject, eventdata, handles)
% hObject    handle to buttCellDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hacked to run penlocate rather than celldb

global CELLDB_USER CELLDB_ANIMAL

t1=get(handles.popupmenu1,'Value');
t2=get(handles.popupmenu1,'String');
Tester = t2{t1};                       % output 1: Tester

t1=get(handles.popupmenu2,'Value');
t2=get(handles.popupmenu2,'String');
Ferret = t2{t1};                       % output 2: Ferret

dbopen;
sql=sprintf('SELECT * FROM gUserPrefs WHERE realname like "%%%s%%"',Tester);
udata=mysql(sql);
if length(udata)==0,
    url=['http://bhangra.isr.umd.edu/celldb/'];
else
    userid=udata(1).userid;
    passwd=udata(1).password;
    url=['http://bhangra.isr.umd.edu/celldb/celllist.php?userid=',userid,...
        '&passwd=',passwd];
    
    CELLDB_USER=userid;
end
CELLDB_ANIMAL=[];
penlocate;

return

web(url,'-browser');

