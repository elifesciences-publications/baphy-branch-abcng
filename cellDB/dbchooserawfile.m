function varargout = dbchooserawfile(varargin)
% DBCHOOSERAWFILE M-file for dbchooserawfile.fig
%      DBCHOOSERAWFILE, by itself, creates a new DBCHOOSERAWFILE or raises the existing
%      singleton*.
%
%      H = DBCHOOSERAWFILE returns the handle to a new DBCHOOSERAWFILE or the handle to
%      the existing singleton*.
%
%      DBCHOOSERAWFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DBCHOOSERAWFILE.M with the given input arguments.
%
%      DBCHOOSERAWFILE('Property','Value',...) creates a new DBCHOOSERAWFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dbchooserawfile_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dbchooserawfile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help dbchooserawfile

% Last Modified by GUIDE v2.5 22-Jul-2014 09:47:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dbchooserawfile_OpeningFcn, ...
                   'gui_OutputFcn',  @dbchooserawfile_OutputFcn, ...
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


% --- Executes just before dbchooserawfile is made visible.
function dbchooserawfile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dbchooserawfile (see VARARGIN)

% varargin{1} - flag. if 1, disable a few components so that site and
% channel are fixed (this is for choosing a template file
% varargin{2} - string, title for window

global CHOOSING_TEMPLATE

% Choose default command line output for dbchooserawfile
handles.output = hObject;
guidata(hObject, handles);

if length(varargin)>0,
    CHOOSING_TEMPLATE=varargin{1};
else
    CHOOSING_TEMPLATE=0;
end
if length(varargin)>1,
    set(handles.figure1,'Name',varargin{2});
end

initialize_display(hObject,handles);

% UIWAIT makes dbchooserawfile wait for user response (see UIRESUME)
uiwait(handles.figure1);


% initialize_display, loading user-specific settings if they
% haven't been set
function initialize_display(hObject,handles,user);

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS CELLDB_ALLANIMALS
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA CHOOSING_TEMPLATE
global USECOMMONREFERENCE
global SIGTHRESH BAPHYHOME
global BAPHY_LAB

if exist('user','var'),
   CELLDB_USER=user;
end

dbopen;
if ~isempty(BAPHY_LAB),
    lab=BAPHY_LAB;
else
    lab='nsl';
end
sql=['SELECT id,userid,lab FROM gUserPrefs',...
    ' WHERE lab="',lab,'"',...
    ' ORDER BY userid'];
userdata=mysql(sql);
users=cell(length(userdata),1);
[users{:}]=deal(userdata.userid);

set(handles.checkAllAnimals,'Value',CELLDB_ALLANIMALS);
checkAllAnimals_Callback(hObject, [], handles);

% load last settings
if isempty(CELLDB_ANIMAL),
   load_db_settings;
end

useridx=find(strcmp(CELLDB_USER,users));
if isempty(useridx),
   useridx=1;
end

set(handles.popTester,'String',users);
set(handles.popTester,'Value',useridx);

% Update handles structure
guidata(hObject, handles);

if CHOOSING_TEMPLATE,
    set(handles.popTester,'Enable','off');
    set(handles.popAnimals,'Enable','off');
    set(handles.checkAllAnimals,'Enable','off');
    set(handles.listSites,'Enable','off');
    set(handles.listRunClass,'Enable','off');
    set(handles.popChannel,'Enable','off');
    if CHOOSING_TEMPLATE==1,
        CELLDB_RUNCLASS={'ALL'};   % force all selected
    elseif CHOOSING_TEMPLATE==2,
        CELLDB_RUNCLASS={'DEP'};   % force DEP runclass only for multi-depth module
    end
else
    set(handles.popTester,'Enable','on');
    set(handles.popAnimals,'Enable','on');
    set(handles.checkAllAnimals,'Enable','on');
    set(handles.listSites,'Enable','on');
    set(handles.listRunClass,'Enable','on');
    set(handles.popChannel,'Enable','on');
end

popAnimals_Callback(hObject, [], handles);

% set sigma threshold to whatever was used last
if ~isempty(SIGTHRESH),
   set(handles.editSigmaThreshold,'String',num2str(SIGTHRESH));
end
set(handles.checkGlobalSigma,'Value',CELLDB_GLOBAL_SIGMA);
set(handles.checkCommonReference,'Value',USECOMMONREFERENCE);


% --- Outputs from this function are returned to the command line.
function varargout = dbchooserawfile_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output{1};

close(handles.figure1);
drawnow;

% --- Executes on selection change in popTester.
function popTester_Callback(hObject, eventdata, handles)
% hObject    handle to popTester (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popTester contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popTester

global CELLDB_ANIMAL

users=get(handles.popTester,'String');
useridx=get(handles.popTester,'Value');
user=users{useridx};

% clear CELLDB_ANIMAL to force loading new settings
CELLDB_ANIMAL=[];
initialize_display(hObject,handles,user);


% --- Executes during object creation, after setting all properties.
function popTester_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popTester (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popAnimals.
function popAnimals_Callback(hObject, eventdata, handles)
% hObject    handle to popAnimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popAnimals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popAnimals

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS 
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA

animals=get(handles.popAnimals,'String');
animalidx=get(handles.popAnimals,'Value');
animal=animals{animalidx};
if strcmp(animal,'ALL'),
    animal='%';
end
CELLDB_ANIMAL=animal;

disp('loading site list');
sql=['SELECT gCellMaster.id,gCellMaster.siteid',...
    ' FROM gCellMaster,gDataRaw',...
    ' WHERE gCellMaster.id=gDataRaw.masterid',...
    ' AND not(gCellMaster.training)',...
    ' AND animal like "',animal,'" GROUP BY gCellMaster.id ORDER BY siteid'];
sitedata=mysql(sql);
sites=cell(1,length(sitedata));
if ~isempty(sites),
  [sites{:}]=deal(sitedata.siteid);
else
  sites={};
end
sites={'ALL' sites{:}};
disp('loaded site list');

set(handles.listSites,'String',sites);
siteidx=find(strcmp(CELLDB_SITEID,sites));
if isempty(siteidx),
   siteidx=1;
end
set(handles.listSites,'Value',siteidx(1));
CELLDB_SITEID=sites{siteidx(1)};

listSites_Callback(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function popAnimals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popAnimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listSites.
function listSites_Callback(hObject, eventdata, handles)
% hObject    handle to listSites (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listSites contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listSites

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA
global CHOOSING_TEMPLATE

sites=get(handles.listSites,'String');
siteidx=get(handles.listSites,'Value');
site=sites{siteidx};
if strcmp(site,'ALL'),
    site='%';
end
CELLDB_SITEID=site;

animal=CELLDB_ANIMAL;

% runclasses
sql=['SELECT DISTINCT runclass,runclassid FROM gDataRaw,gCellMaster',...
    ' WHERE gCellMaster.siteid like "',site,'"',...
    ' AND gDataRaw.masterid=gCellMaster.id AND animal like "',animal,'"',...
    ' ORDER BY runclass'];
runclassdata=mysql(sql);
runclasses=cell(1,length(runclassdata));
for ii=1:length(runclassdata),
    runclasses{ii}=num2str(runclassdata(ii).runclass);
end
runclasses={'ALL',runclasses{:}};

oldrc=CELLDB_RUNCLASS;

set(handles.listRunClass,'String',runclasses);
rcidx=find(ismember(runclasses,oldrc))
if isempty(rcidx) && ~(CHOOSING_TEMPLATE==2),
   rcidx=1;
end
set(handles.listRunClass,'Value',rcidx);
listRunClass_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function listSites_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listSites (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listRunClass.
function listRunClass_Callback(hObject, eventdata, handles)
% hObject    handle to listRunClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listRunClass contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listRunClass

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA CHOOSING_TEMPLATE

runclasses=get(handles.listRunClass,'String');
rcidx=get(handles.listRunClass,'Value');
rcset={runclasses{rcidx}};
if length(rcset)>0 && strcmp(rcset{1},'ALL'),
    rcset={runclasses{2:end}};
end
CELLDB_RUNCLASS=rcset;

if length(rcset)>0,
    runclass='(';
    for ii=1:length(rcset),
        runclass=[runclass,'"',rcset{ii},'",'];
    end
    runclass(end)=')';
else
    runclass='("XXX")';
end

animal=CELLDB_ANIMAL;
site=CELLDB_SITEID;

%    ' AND not(gDataRaw.bad)',...
% rawfiles
if CHOOSING_TEMPLATE,
    sql=['SELECT gDataRaw.id,parmfile,gDataRaw.respfile',...
        ' FROM gDataRaw INNER JOIN gCellMaster ON gDataRaw.masterid=gCellMaster.id',...
        ' LEFT JOIN sCellFile ON sCellFile.rawid=gDataRaw.id',...
        ' WHERE gCellMaster.siteid like "',site,'"',...
        ' AND animal like "',animal,'"',...
        ' AND not(gDataRaw.bad)',...
        ' AND gDataRaw.runclass in ',runclass,...
        ' AND not(isnull(sCellFile.id))',...
        ' GROUP BY gDataRaw.id,parmfile,gDataRaw.respfile',...
        ' ORDER BY parmfile,respfile'];
else
    sql=['SELECT gDataRaw.id,parmfile,respfile FROM gDataRaw,gCellMaster',...
        ' WHERE gCellMaster.siteid like "',site,'" AND gDataRaw.masterid=gCellMaster.id',...
        ' AND gDataRaw.masterid=gCellMaster.id AND animal like "',animal,'"',...
        ' AND not(gDataRaw.bad)',...
        ' AND gDataRaw.runclass in ',runclass,...
        ' ORDER BY parmfile,respfile'];
end

rawdata=mysql(sql);
rawfiles=cell(1,length(rawdata));
rawids=cell(1,length(rawdata));
[rawids{:}]=deal(rawdata.id);
for ii=1:length(rawdata),
    if length(rawdata(ii).parmfile)>0,
        rawfiles{ii}=basename(rawdata(ii).parmfile);
    else
        rawfiles{ii}=basename(rawdata(ii).respfile);
    end
end

set(handles.listRawFiles,'String',rawfiles);
set(handles.listRawFiles,'Value',1);
set(handles.listRawFiles,'UserData',rawids);

listRawFiles_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function listRunClass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listRunClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor','white');




% --- Executes on selection change in listRawFiles.
function listRawFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listRawFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listRawFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listRawFiles

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS 
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA

animal=CELLDB_ANIMAL;
site=CELLDB_SITEID;

sql=['SELECT gSingleCell.id,gSingleCell.cellid FROM gSingleCell,gCellMaster',...
    ' WHERE gSingleCell.siteid like "',site,'"',...
    ' AND gSingleCell.masterid=gCellMaster.id AND animal like "',animal,'"',...
    ' ORDER BY gSingleCell.cellid'];
cellnamedata=mysql(sql);
if length(cellnamedata)==0,
    cellnames={'NONE'};
else
    cellnames=cell(1,length(cellnamedata));
    [cellnames{:}]=deal(cellnamedata.cellid);
end

rawfiles=get(handles.listRawFiles,'String');
rfidx=get(handles.listRawFiles,'Value');
rawids=get(handles.listRawFiles,'UserData');
if length(rawfiles)<rfidx,
    rawfile='';
    rawid=0;
else
    rawfile=rawfiles{rfidx};
    rawid=rawids{rfidx};
end

if rawid>0,
    sql=['SELECT * FROM sCellFile WHERE rawid=',num2str(rawid),...
        ' AND respfilefmt="meska" order by cellid'];
else
    sql=['SELECT * FROM sCellFile WHERE cellid like "',site,'%"',...
        ' AND respfilefmt="meska" order by cellid'];
end
cellfiledata=mysql(sql);

cellstr='Sorted cells:';
for ii=1:length(cellfiledata),
   cellstr=[cellstr,' ',cellfiledata(ii).cellid];
end

sql=['SELECT id,comments FROM gCellMaster WHERE cellid = "',site,'"'];
cellfiledata=mysql(sql);
if length(cellfiledata)>0 & length(cellfiledata(1).comments)>0,
    cellstr=[cellstr char(10) cellfiledata(1).comments];
end

set(handles.textInfo,'String',cellstr);

sql=['SELECT gPenetration.penname,numchans FROM gPenetration,gCellMaster,gDataRaw',...
     ' WHERE gPenetration.id=gCellMaster.penid',...
     ' AND gCellMaster.id=gDataRaw.masterid',...
     ' AND gDataRaw.id=',num2str(rawid)];
pendata=mysql(sql);
Nmax = 128;
cstr=cell(1,128);
for ii=1:Nmax,
   cstr{ii}=num2str(ii);
end
if length(pendata)<1 | pendata.numchans<1,
    clear pendata;
    pendata.numchans=1;
    pendata.penname='unknown';
    cstr={'0'};
end
set(handles.popChannel,'String',{cstr{1:pendata.numchans}});
if CELLDB_CHANNEL>pendata.numchans,
   set(handles.popChannel,'Value',1);
else
   set(handles.popChannel,'Value',CELLDB_CHANNEL);
end


% --- Executes during object creation, after setting all properties.
function listRawFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listRawFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in buttOk.
function buttOk_Callback(hObject, eventdata, handles)
% hObject    handle to buttOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SIGTHRESH

rridx=get(handles.listRawFiles,'Value');
rawids=get(handles.listRawFiles,'UserData');
channel=get(handles.popChannel,'Value');

rawid=rawids{rridx};

sql=['SELECT * FROM gDataRaw WHERE id=',num2str(rawid)];
rawdata=mysql(sql);

outdata.rawid=rawid;
outdata.siteid=rawdata.cellid;
outdata.evpfile=rawdata.respfileevp;
outdata.spikefile=rawdata.matlabfile;
outdata.parmfile=rawdata.parmfile;
if ~exist(outdata.evpfile,'file'),
    outdata.evpfile=[rawdata.resppath basename(outdata.evpfile)];
end 
fileparts(outdata.parmfile)

if isempty(fileparts(outdata.parmfile)) || ~exist(outdata.parmfile,'file'),
    outdata.parmfile=[rawdata.resppath basename(outdata.parmfile)];
end
if strcmp(outdata.parmfile(end-1:end),'.m'),
   outdata.parmfile=outdata.parmfile(1:end-2);
end
   
sql=['SELECT gCellMaster.id, numchans FROM gCellMaster,gPenetration',...
     ' WHERE siteid="',outdata.siteid,'" AND gCellMaster.penid=gPenetration.id'];
site=mysql(sql);
outdata.numchans=site.numchans;

sql=['SELECT gSingleCell.* FROM gSingleCell',...
     ' WHERE siteid="',outdata.siteid,'" AND channum=',num2str(channel)];
site=mysql(sql);
outdata.cellcount=length(site);
outdata.channel=channel;
outdata.sigthresh=str2num(get(handles.editSigmaThreshold,'String'));
outdata.globalsigma=get(handles.checkGlobalSigma,'Value');

sql=['SELECT * FROM gData WHERE rawid=',num2str(rawid)];
datadata=mysql(sql);
for ii=1:length(datadata),
   if datadata(ii).datatype==0,
      outdata=setfield(outdata,datadata(ii).name,datadata(ii).value);
   else
      outdata=setfield(outdata,datadata(ii).name,datadata(ii).svalue);
   end
end

handles.output={outdata};
guidata(hObject, handles);
   
SIGTHRESH=str2num(get(handles.editSigmaThreshold,'String'));

save_db_settings;

uiresume;


% --- Executes on button press in buttCancel.
function buttCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output={[]} ;
guidata(hObject, handles);

uiresume;


% --- Executes on selection change in popChannel.
function popChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popChannel
global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS 
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA

CELLDB_CHANNEL=get(handles.popChannel,'Value');

% --- Executes during object creation, after setting all properties.
function popChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editSigmaThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editSigmaThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigmaThreshold as text
%        str2double(get(hObject,'String')) returns contents of editSigmaThreshold as a double


% --- Executes during object creation, after setting all properties.
function editSigmaThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigmaThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkGlobalSigma.
function checkGlobalSigma_Callback(hObject, eventdata, handles)
% hObject    handle to checkGlobalSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkGlobalSigma

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS 
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA

CELLDB_GLOBAL_SIGMA=get(handles.checkGlobalSigma,'Value');


% --- Executes on button press in checkSaveSigma.
function checkSaveSigma_Callback(hObject, eventdata, handles)
% hObject    handle to checkSaveSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSaveSigma


function checkCommonReference_Callback(hObject, eventdata, handles)
% hObject    handle to checkCommonReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkGlobalSigma

global USECOMMONREFERENCE

USECOMMONREFERENCE=get(handles.checkCommonReference,'Value');


% --- Executes on button press in checkAllAnimals.
function checkAllAnimals_Callback(hObject, eventdata, handles)
% hObject    handle to checkAllAnimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CELLDB_ANIMAL CELLDB_ALLANIMALS BAPHY_LAB

% Hint: get(hObject,'Value') returns toggle state of checkAllAnimals
allAnimals=get(handles.checkAllAnimals,'Value');
CELLDB_ALLANIMALS=allAnimals;

if ~allAnimals && ~isempty(BAPHY_LAB),
   sql=['SELECT DISTINCT min(gCellMaster.id) as id,gCellMaster.animal ',...
      ' FROM gCellMaster INNER JOIN gAnimal ON gCellMaster.animal=gAnimal.animal',...
      ' WHERE not(gCellMaster.training) AND gAnimal.lab="',BAPHY_LAB,'"',...
      ' GROUP BY gCellMaster.animal ORDER BY gCellMaster.animal'];
else
   sql=['SELECT DISTINCT min(id) as id,animal FROM gCellMaster WHERE not(training)' ...
      ' GROUP BY animal ORDER BY animal'];
end

animaldata=mysql(sql);
animals=cell(length(animaldata),1);
[animals{:}]=deal(animaldata.animal);
animals={'ALL' animals{:}};
animalidx=find(strcmp(CELLDB_ANIMAL,animals));
if isempty(animalidx),
   animalidx=2;
end

set(handles.popAnimals,'String',animals);
set(handles.popAnimals,'Value',animalidx);
