function varargout = dbbrowser(varargin)
% DBBROWSER M-file for dbbrowser.fig
%      DBBROWSER, by itself, creates a new DBBROWSER or raises the existing
%      singleton*.
%
%      H = DBBROWSER returns the handle to a new DBBROWSER or the handle to
%      the existing singleton*.
%
%      DBBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DBBROWSER.M with the given input arguments.
%
%      DBBROWSER('Property','Value',...) creates a new DBBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dbbrowser_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dbbrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help dbbrowser

% Last Modified by GUIDE v2.5 10-Dec-2005 17:21:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dbbrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @dbbrowser_OutputFcn, ...
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


% --- Executes just before dbbrowser is made visible.
function dbbrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dbbrowser (see VARARGIN)

% Choose default command line output for dbbrowser
handles.output = hObject;

sql=['SELECT gAnimal.* FROM gAnimal,gCellMaster',...
    ' WHERE gAnimal.animal=gCellMaster.animal',...
    ' GROUP BY gAnimal.id ORDER BY animal'];
animaldata=mysql(sql);
animals=cell(length(animaldata),1);
[animals{:}]=deal(animaldata.animal);
animals={'ALL' animals{:}};

set(handles.popAnimals,'String',animals);
set(handles.popAnimals,'Value',2);

udata.animal='Bom';
udata.site='%';
udata.runclass='%';
set(handles.figure1,'UserData',udata);

% Update handles structure
guidata(hObject, handles);

popAnimals_Callback(hObject, eventdata, handles);
listSites_Callback(hObject, eventdata, handles);


% UIWAIT makes dbbrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dbbrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popAnimals.
function popAnimals_Callback(hObject, eventdata, handles)
% hObject    handle to popAnimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popAnimals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popAnimals

animals=get(handles.popAnimals,'String');
animalidx=get(handles.popAnimals,'Value');
animal=animals{animalidx};
if strcmp(animal,'ALL'),
    animal='%';
end
udata.animal=animal;
udata.site='%';
udata.runclass='%';
set(handles.figure1,'UserData',udata);

sql=['SELECT gCellMaster.id,gCellMaster.siteid',...
    ' FROM gCellMaster,gDataRaw',...
    ' WHERE gCellMaster.id=gDataRaw.masterid',...
    ' AND animal like "',animal,'" GROUP BY gCellMaster.id ORDER BY siteid'];
sitedata=mysql(sql);
sites=cell(1,length(sitedata));
[sites{:}]=deal(sitedata.siteid);
sites={'ALL' sites{:}};

set(handles.listSites,'String',sites);
set(handles.listSites,'Value',1);

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

sites=get(handles.listSites,'String');
siteidx=get(handles.listSites,'Value');
site=sites{siteidx};
if strcmp(site,'ALL'),
    site='%';
end

udata=get(handles.figure1,'UserData');
udata.site=site;
set(handles.figure1,'UserData',udata);
animal=udata.animal;

% runclasses
sql=['SELECT DISTINCT runclass,runclassid FROM gDataRaw,gCellMaster',...
    ' WHERE gCellMaster.siteid like "',site,'"',...
    ' AND gDataRaw.masterid=gCellMaster.id AND animal like "',animal,'"',...
    ' ORDER BY runclass'];
runclassdata=mysql(sql);
runclasses=cell(1,length(runclassdata));
if length(runclassdata)>0,
    [runclasses{:}]=deal(runclassdata.runclass);
end
runclasses={'ALL',runclasses{:}};

set(handles.listRunClass,'String',runclasses);
set(handles.listRunClass,'Value',1);

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




% --- Executes on selection change in listRawFiles.
function listRawFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listRawFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listRawFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listRawFiles

udata=get(handles.figure1,'UserData');
animal=udata.animal;
site=udata.site;

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
rawfile=rawfiles{rfidx};
rawids=get(handles.listRawFiles,'UserData');
rawid=rawids{rfidx};

if rawid>0,
    sql=['SELECT * FROM sCellFile WHERE rawid=',num2str(rawid),...
        ' AND respfilefmt="meska" order by cellid'];
else
    sql=['SELECT * FROM sCellFile WHERE cellid like "',site,'%"',...
        ' AND respfilefmt="meska" order by cellid'];
end
cellfiledata=mysql(sql);

for ii=1:length(cellfiledata),
    ff=find(strcmp(cellnames,cellfiledata(ii).cellid));
    if ~isempty(ff),
        cellnames{ff}=[cellfiledata(ii).cellid,' (sorted)'];
    end
end

set(handles.listCells,'String',cellnames);
set(handles.listCells,'Value',[1]);



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




% --- Executes on selection change in listCells.
function listCells_Callback(hObject, eventdata, handles)
% hObject    handle to listCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listCells contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listCells


% --- Executes during object creation, after setting all properties.
function listCells_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
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

runclasses=get(handles.listRunClass,'String');
rcidx=get(handles.listRunClass,'Value');
rcset={runclasses{rcidx}};
if strcmp(rcset{1},'ALL'),
    rcset={runclasses{2:end}};
end

runclass='(';
for ii=1:length(rcset),
    runclass=[runclass,'"',rcset{ii},'",'];
end
runclass(end)=')';

udata=get(handles.figure1,'UserData');
udata.runclass=runclass;
set(handles.figure1,'UserData',udata);
animal=udata.animal;
site=udata.site;

% rawfiles
sql=['SELECT gDataRaw.id,parmfile,respfile FROM gDataRaw,gCellMaster',...
    ' WHERE gCellMaster.siteid like "',site,'" AND gDataRaw.masterid=gCellMaster.id',...
    ' AND gDataRaw.masterid=gCellMaster.id AND animal like "',animal,'"',...
    ' AND gDataRaw.runclass in ',runclass,...
    ' ORDER BY parmfile,respfile'];
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
rawfiles={'ALL',rawfiles{:}};
rawids={0 rawids{:}};

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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


