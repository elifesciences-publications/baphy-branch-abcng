function varargout = m_template(varargin)
% M_TEMPLATE M-file for m_template.fig
%      M_TEMPLATE, by itself, creates a new M_TEMPLATE or raises the existing
%      singleton*.
%
%      H = M_TEMPLATE returns the handle to a new M_TEMPLATE or the handle to
%      the existing singleton*.
%
%      M_TEMPLATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in M_TEMPLATE.M with the given input arguments.
%
%      M_TEMPLATE('Property','Value',...) creates a new M_TEMPLATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before m_template_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to m_template_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help m_template

% Last Modified by GUIDE v2.5 16-Aug-2006 13:53:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @m_template_OpeningFcn, ...
                   'gui_OutputFcn',  @m_template_OutputFcn, ...
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


% --- Executes just before m_template is made visible.
function m_template_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to m_template (see VARARGIN)

% Choose default command line output for m_template
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes m_template wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = m_template_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function editTemplateFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editTemplateFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTemplateFilename as text
%        str2double(get(hObject,'String')) returns contents of editTemplateFilename as a double

% don't save globals here!! wait til user hits ok!
% global UNITMEAN UNITSTD XAXIS UNITCOUNT SPKCOUNT KCOL
global KCOL XAXIS

spikefile=get(hObject,'String');
cn=str2num(get(handles.editChannel,'String'));

if exist(spikefile,'file') & cn>0,
   disp('loading full meskres template');
   spkdata=load(spikefile);
   if isfield(spkdata,'sortextras') & length(spkdata.sortextras)>=cn &...
          ~isempty(spkdata.sortextras{cn}),
      UNITMEAN=spkdata.sortextras{cn}.unitmean;
      UNITSTD=spkdata.sortextras{cn}.unitstd;
      oldXAXIS=spkdata.sortinfo{cn}{1}(1).xaxis;
      UNITCOUNT=size(UNITMEAN,2);
      SPKCOUNT=zeros(UNITCOUNT,1);
      for ii=1:spkdata.sortinfo{cn}{1}(1).Ncl,
         SPKCOUNT(ii)=size(spkdata.sortinfo{cn}{1}(ii).unitSpikes,2);
      end
   end
else
    error('no spike file');
end

axes(handles.axesTemplate);
if oldXAXIS(2) < XAXIS(2),
    UNITMEAN((oldXAXIS(2)-oldXAXIS(1)):(XAXIS(2)-XAXIS(1)+1),:)=0;
    UNITSTD((oldXAXIS(2)-oldXAXIS(1)):(XAXIS(2)-XAXIS(1)+1),:)=0;
end
st=XAXIS(1):XAXIS(2);
for uu=1:UNITCOUNT,
    errorshade(st',UNITMEAN(:,uu),UNITSTD(:,uu),KCOL{uu});
    hold on
end
hl=zeros(UNITCOUNT,1);
ll={};
for uu=1:UNITCOUNT,
    hl(uu)=plot(st',UNITMEAN(:,uu),[KCOL{uu},'-']);
    if uu<=UNITCOUNT,
        ll{uu}=sprintf('%s template (%d spikes)',['unit-' num2str(uu)],SPKCOUNT(uu));
    else
        ll{uu}=sprintf('CLUSTER #%d CRAP',uu);
    end
end
hold off

legend(hl,ll,-1);
title(sprintf('sigma=%.2f',spkdata.sortextras{cn}.sigthreshold));

% --- Executes during object creation, after setting all properties.
function editTemplateFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTemplateFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editChannel_Callback(hObject, eventdata, handles)
% hObject    handle to editChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editChannel as text
%        str2double(get(hObject,'String')) returns contents of editChannel as a double

m_template('editTemplateFilename_Callback',...
    handles.editTemplateFilename,[],guidata(handles.editTemplateFilename))

% --- Executes during object creation, after setting all properties.
function editChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttBrowse.
function buttBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to buttBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filedata=dbchooserawfile(1,'Choose template file');

if ~isempty(filedata),  % ie, user didn't hit cancel
    set(handles.editTemplateFilename,'String',filedata.spikefile);
    set(handles.editChannel,'String',filedata.channel);
    guidata(hObject, handles);
    m_template('editTemplateFilename_Callback',...
        handles.editTemplateFilename,[],guidata(handles.editTemplateFilename))
end

% --- Executes on button press in buttClose.
function buttOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UNITMEAN UNITSTD XAXIS UNITCOUNT SPKCOUNT UNITTOL SIGTHRESH SWEEPOUT

spikefile=get(handles.editTemplateFilename,'String');
cn=str2num(get(handles.editChannel,'String'));

meska_loadtemplate(spikefile,cn);

close


% --- Executes on button press in buttClose.
function buttCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close




