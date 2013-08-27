function varargout = m_save(varargin)
% M_SAVE M-file for m_save.fig
%      M_SAVE, by itself, creates a new M_SAVE or raises the existing
%      singleton*.
%
%      H = M_SAVE returns the handle to a new M_SAVE or the handle to
%      the existing singleton*.
%
%      M_SAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in M_SAVE.M with the given input arguments.
%
%      M_SAVE('Property','Value',...) creates a new M_SAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before m_save_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to m_save_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help m_save

% Last Modified by GUIDE v2.5 16-Aug-2006 15:59:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @m_save_OpeningFcn, ...
                   'gui_OutputFcn',  @m_save_OutputFcn, ...
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


% --- Executes just before m_save is made visible.
function m_save_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to m_save (see VARARGIN)

% Choose default command line output for m_save
handles.output = hObject;

global UNITCOUNT CELLID FILEDATA NEWSNR

source=FILEDATA.parmfile;

[bb,pp]=basename(source);
SORTROOT=[pp 'sorted'];

destbase=bb;
if strcmp('.par',destbase(end-3:end)),
   destbase=destbase(1:end-4);
end
destin=[SORTROOT filesep destbase];

set(handles.editSpikeFilename,'String',[destin '.spk.mat']);

FontWeight = 'bold';

pos = [0 23*UNITCOUNT+80];
isopct=zeros(size(NEWSNR));
for jj=1:UNITCOUNT,

    uicontrol('Style','text','String',sprintf('cluster %d',jj),'FontWeight',FontWeight,...
        'HorizontalAlignment','left','position',[pos-[-50 23*(jj-1)+4] 100 20]);
    
    if jj<=FILEDATA.cellcount,
        mapto=num2str(jj);
    else
        mapto='';
    end
    maphandle(jj) = uicontrol('Style','Edit','String',mapto,...
        'Value',jj,'HorizontalAlignment','center',...
        'BackgroundColor',[1 1 1],'position',[pos-[-150 23*(jj-1)] 50 20]);
    
    isopct(jj)=round( 100*erf(NEWSNR(jj)./2) .* 10) ./10;
    isohandle(jj)= uicontrol('Style','Edit','String',num2str(isopct(jj)),...
        'Value',isopct(jj),'HorizontalAlignment','center',...
        'BackgroundColor',[1 1 1],'position',[pos-[-250 23*(jj-1)] 50 20]);
end

uicontrol('Style','text','String','Map cluster...','FontWeight','bold',...
        'HorizontalAlignment','left','position',[pos-[-50 23*(-1)+4] 100 20]);
uicontrol('Style','text','String','... To cell #','FontWeight','bold',...
        'HorizontalAlignment','left','position',[pos-[-150 23*(-1)+4] 100 20]);
uicontrol('Style','text','String','Isolation %','FontWeight','bold',...
        'HorizontalAlignment','left','position',[pos-[-250 23*(-1)+4] 100 20]);


handles.maphandle=maphandle;
handles.isohandle=isohandle;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes m_save wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = m_save_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editSpikeFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editSpikeFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpikeFilename as text
%        str2double(get(hObject,'String')) returns contents of editSpikeFilename as a double


% --- Executes during object creation, after setting all properties.
function editSpikeFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpikeFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttOK.
function buttOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UNITCOUNT CELLIDS SPKCLASS SPIKESET XAXIS EVENTTIMES FILEDATA EXTRAS
global CELLDB_USER
global LASTFILEDATA SAVEOK

unitmap=zeros(UNITCOUNT,1);
isopct=zeros(UNITCOUNT,1);
q={};
for jj=1:UNITCOUNT,
    rr=str2num(get(handles.maphandle(jj),'String'));
    if ~isempty(rr),
        if ~isempty(find(unitmap==rr)),
            errordlg('Cannot map two clusters to one unit. Or can you????');
            return
        end
        unitmap(jj)=rr;
    end
    rr=str2num(get(handles.isohandle(jj),'String'));
    if unitmap(jj)>0 && ~isempty(rr),
        isopct(unitmap(jj))=rr;
    end
    
    spmatch=find(SPKCLASS==unitmap(jj));
    
    if unitmap(jj)>0,
       rr=str2num(get(handles.isohandle(jj),'String'));
       if ~isempty(rr),
          isopct(unitmap(jj))=rr;
       end
       q{jj}=sprintf('cluster %d maps to %s (%d spikes)\n',jj,CELLIDS{unitmap(jj)},length(spmatch));
    end
end

q{UNITCOUNT+1}='Continue with save?';
yn=questdlg(q);

if strcmpi(yn,'Cancel') || strcmpi(yn,'No'),
   SAVEOK=0;
   close
   return
end

source=FILEDATA.parmfile;
destin=get(handles.editSpikeFilename,'String');
destin=strrep(destin,'.spk.mat','');
if ~isempty(CELLDB_USER),
   sorter=CELLDB_USER;
else
   sorter= 'david';
end

PSORTER=1;
comments='PC-cluster sorted by mespca.m';
abaflag=0;

if exist([destin '.spk.mat'],'file'),
   yn=questdlg('Append to existing .spk.mat file (rather than overwrite!)? ');
   if length(yn)>0 && yn(1)=='N',
      delete([destin '.spk.mat']);
   elseif length(yn)>0 && yn(1)=='C',
      SAVEOK=0;
      close
      return
   end
end

% save spike times and templates for each cluster

% reorder templates so that first one corresponds to first unit in sorted
% cells. and so on. crap clusters tacked on at the end
unitmean=zeros(size(SPIKESET,1),max(unitmap));
unitstd=zeros(size(SPIKESET,1),max(unitmap));
spksav1=cell(12,1);
for ab=1:UNITCOUNT,
    if unitmap(ab)>0,
        spmatch=find(SPKCLASS==ab);
        spksav1{unitmap(ab),1}=EVENTTIMES(spmatch);
        unitmean(:,unitmap(ab))=mean(SPIKESET(:,spmatch),2);
        unitstd(:,unitmap(ab))=std(SPIKESET(:,spmatch),0,2);
    end
end
for ab=1:UNITCOUNT,
    if unitmap(ab)==0,
        spmatch=find(SPKCLASS==ab);
        unitmean=[unitmean mean(SPIKESET(:,spmatch),2)];
        unitstd=[unitstd std(SPIKESET(:,spmatch),0,2)];
    end
end

extras=EXTRAS;
extras.unitmean=unitmean;
extras.unitstd=unitstd;
savespikes(source,destin,EVENTTIMES,SPIKESET,spksav1,sorter,PSORTER,...
           comments,extras,abaflag,XAXIS);

FILEDATA.spikefile=[destin,'.spk.mat'];

LASTFILEDATA=FILEDATA;

ONEFILE=1;
fname=FILEDATA.parmfile;
spk=spksav1;

siteid=FILEDATA.siteid;
chanNum=num2str(FILEDATA.channel);
destin2=destin;
source2=source;
matchcell2file;

SAVEOK=1;
close

% --- Executes on button press in buttCancel.
function buttCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SAVEOK

SAVEOK=0;
close



