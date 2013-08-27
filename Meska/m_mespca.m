function varargout = m_mespca(varargin)
% M_MESPCA M-file for m_mespca.fig
%      M_MESPCA, by itself, creates a new M_MESPCA or raises the existing
%      singleton*.
%
%      H = M_MESPCA returns the handle to a new M_MESPCA or the handle to
%      the existing singleton*.
%
%      M_MESPCA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in M_MESPCA.M with the given input arguments.
%
%      M_MESPCA('Property','Value',...) creates a new M_MESPCA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before m_mespca_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to m_mespca_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help m_mespca

% Last Modified by GUIDE v2.5 22-Aug-2011 11:28:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @m_mespca_OpeningFcn, ...
                   'gui_OutputFcn',  @m_mespca_OutputFcn, ...
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


% --- Executes just before m_mespca is made visible.
function m_mespca_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to m_mespca (see VARARGIN)

% set a bunch of global parameters and defaults here
global PCC KCOL XAXIS C0
global C_ENABLE_CACHING

C_ENABLE_CACHING=0;

PCC=3;
KCOL={'b','g','c','r','k','m','y'};
XAXIS=[-10 25];
C0=[];

leave_running_state(handles);

% Choose default command line output for m_mespca
handles.output = hObject;

inactive(handles.editSigma);
inactive(handles.buttThresh);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes m_mespca wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = m_mespca_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttIC.
function buttIC_Callback(hObject, eventdata, handles)
% hObject    handle to buttIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UPROJ C0 PCC PCS SPIKESET UNITMEAN UNITSTD UNITCOUNT SPKCOUNT

k=str2num(get(handles.editClusterCount,'String'));
if k<1,
    error('invalid cluster count');
end

enter_running_state(handles,'Waiting for user to click on approximate cluster centers');

axes(handles.axes12);
[x,y]=ginput(k);

C0=zeros(k,PCC);
UNITCOUNT=k;
SPKCOUNT=zeros(1,k);
UNITMEAN=zeros(size(PCS,1),UNITCOUNT);
UNITSTD=zeros(size(PCS,1),UNITCOUNT);

for ii=1:k,
    dd=(sqrt((UPROJ(:,1)-x(ii)).^2+(UPROJ(:,2)-y(ii)).^2));
    sidx=find(dd==min(dd));
    C0(ii,:)=UPROJ(sidx,1:PCC);
    UNITMEAN(:,ii)=PCS*C0(ii,:)';
    %UNITMEAN(:,ii)=SPIKESET(:,sidx);
end

leave_running_state(handles);

update_plots(handles);


% --- Executes on button press in buttCluster.
function buttCluster_Callback(hObject, eventdata, handles)
% hObject    handle to buttCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET 
global UPROJ SPKCLASS KCOL C0 EXTRAS

k=str2num(get(handles.editClusterCount,'String'));
tolerance=[str2num(get(handles.editTolerance1,'String'));
           str2num(get(handles.editTolerance2,'String'));
           str2num(get(handles.editTolerance3,'String'));
           str2num(get(handles.editTolerance4,'String'));
           str2num(get(handles.editTolerance5,'String'));
           str2num(get(handles.editTolerance6,'String'))];

if k~=size(UNITMEAN,2),
    errordlg('You must choose new initial conditions for new cluster count','meska');
    return
end

if tolerance<=0,
    errordlg('tolerance value invalid','meska');
    return
end

enter_running_state(handles,'Clustering...');

sweepout=get(handles.checkSweep,'value');
clustercore('kmeans',tolerance,sweepout);

EXTRAS.tolerance=tolerance;
EXTRAS.sweepout=sweepout;

leave_running_state(handles);

update_plots(handles);


% --- Executes on button press in buttChooseFile.
function buttChooseFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttChooseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global FILEDATA EXTRAS SPKRAW CELLIDS UNITCOUNT UNITMEAN UNITSTD SPIKESET
global XAXIS PCC PCS SPIKESET UPROJ SPKCLASS EVENTTIMES
global SPKCOUNT UNITTOL SIGTHRESH SWEEPOUT C0
global LASTFILEDATA
global chanstr

enter_running_state(handles,'Waiting for user to choose file...');

tfiledata=dbchooserawfile(0,'Choose file to sort');

if isempty(tfiledata),
    leave_running_state(handles);
    return
else
    FILEDATA=tfiledata;
end

update_status(handles,'LOADING...');
guidata(hObject, handles);

drawnow;

SPKRAW=[];

evpv=evpversion(FILEDATA.evpfile);
if evpv<1,
   evplocal=evpmakelocal(FILEDATA.evpfile);
   evpv=evpversion(evplocal);
end

if evpv<1,
   yn=questdlg('EVP file does not exist. Generate?'),
   
   if strcmpi(yn,'Cancel') || strcmpi(yn,'No'),
      return
   end
   alpha2evp(FILEDATA.parmfile,1);
end

% clear template stuff
UNITCOUNT=0;
UNITMEAN=[];
SPIKESET=[];

set(handles.editParameterFilename,'String',FILEDATA.parmfile);
set(handles.editChannel,'String',num2str(FILEDATA.channel));
set(handles.editSigma,'String',num2str(FILEDATA.sigthresh));

if FILEDATA.numchans<=8,
   chanstr={'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r'};
elseif FILEDATA.numchans<100,
   chanstr=cell(1,FILEDATA.numchans);
   for ii=1:length(chanstr),
      chanstr{ii}=sprintf('%02d-',ii);
   end
else
   chanstr=cell(1,FILEDATA.numchans);
   for ii=1:length(chanstr),
      chanstr{ii}=sprintf('%03d-',ii);
   end
end

CELLIDS={};
for ii=1:12,
   if FILEDATA.numchans>1,
      CELLIDS{ii}=sprintf('%s-%s%d',FILEDATA.siteid,chanstr{FILEDATA.channel},ii);
   else
      CELLIDS{ii}=sprintf('%s-%d',FILEDATA.siteid,ii);
   end
end

if FILEDATA.globalsigma,
   fixedsigma=site_get_sigma(FILEDATA.siteid,FILEDATA.channel);
   if ~fixedsigma,
      yn=questdlg(['You requested to use the global fixed sigma, but' ...
                   ' none is associated with this site. Calc sigma' ...
                   ' and save it?'],'No global sigma','Yes','No', ...
                  'Yes');
   else
      fprintf('sigma for thresholding fixed at %.3f\n',fixedsigma);
   end
else
   fixedsigma=0;
end

% this should return a thresholded set of spike events
[SPKRAW, EXTRAS]=loadevp(FILEDATA.parmfile,FILEDATA.evpfile,...
                         num2str(FILEDATA.channel),FILEDATA.sigthresh,...
                         fixedsigma);

if FILEDATA.globalsigma && fixedsigma==0 && strcmp(yn,'Yes'),
   site_set_sigma(FILEDATA.siteid,FILEDATA.channel,EXTRAS.sigma);
end

SPKRAW=single(SPKRAW);

if FILEDATA.sigthresh & EXTRAS.evpv>=3,
   
   st=XAXIS(1):XAXIS(2);
   threshold=str2num(get(handles.editSigma,'String'));
   %[EVENTTIMES,sigma]=spk_roughmatch(SPKRAW,threshold,XAXIS);
   EXTRAS.sigthreshold=FILEDATA.sigthresh;
   EVENTTIMES=EXTRAS.spiketimes;
   sigma=EXTRAS.sigma;
   
   SPIKESET=double(SPKRAW(1:XAXIS(2)-XAXIS(1)+1,:));
   
   sp=std(SPIKESET);
   [hh,xx]=hist(std(SPIKESET),20);
   mm=max(find(hh>ceil(sum(hh)./1000)));
   includeidx=find(sp<=xx(mm)+mean(diff(xx))./2);
   
   if length(includeidx)<length(sp),
       fprintf('excluding %d/%d outliers\n',...
               length(sp)-length(includeidx),length(sp));
       SPIKESET=SPIKESET(:,includeidx);
       EVENTTIMES=EVENTTIMES(includeidx);
   end
   
   scorr=SPIKESET*SPIKESET';
   [u,s,v]=svd(scorr);
   UPROJ=SPIKESET'*u(:,1:PCC);
   if prod(size(UPROJ))>0
       for jj=1:PCC,
          if (sum(SPIKESET(:,jj)))<0,
             u(:,jj)=-u(:,jj);
             UPROJ(:,jj)=-UPROJ(:,jj);
          end
       end
   end

   UNITMEAN=mean(SPIKESET,2);
   UNITSTD=UNITMEAN.*0;
   UNITCOUNT=1;
   
   PCS=u(:,1:PCC);
   SPKCLASS=ones(size(EVENTTIMES));
   if ~isempty(LASTFILEDATA) && ...
         strcmp(LASTFILEDATA.siteid,FILEDATA.siteid) && ...
         LASTFILEDATA.channel==FILEDATA.channel &&...
         ~isempty(LASTFILEDATA.spikefile),
      
      fprintf('auto-matching template for %s\n',...
              LASTFILEDATA.spikefile);
      meska_loadtemplate(LASTFILEDATA.spikefile,LASTFILEDATA.channel);
      
      if ~isempty(UNITMEAN),
         set(handles.editClusterCount,'String',num2str(size(UNITMEAN,2)));
         for uu=1:6,
            hname=eval(sprintf('handles.editTolerance%d',uu));
            if uu<=length(UNITTOL),
               set(hname,'String',num2str(UNITTOL(uu)));
            else
               set(hname,'String',num2str(UNITTOL(1)));
            end
         end
         set(handles.checkSweep,'Value',SWEEPOUT);
         C0=UNITMEAN'*PCS;
         %buttCluster_Callback(handles.buttCluster, eventdata, handles);
         buttMatch_Callback(handles.buttMatch, eventdata, handles);
      end
   end
   
   update_plots(handles);
else

   leave_running_state(handles);
   
   % run initial threshold to clear out old data and make a dumb first fit.
   buttThresh_Callback(handles.buttThresh, eventdata, handles)
end

guidata(hObject, handles);


% --- Executes on button press in buttThresh.
function buttThresh_Callback(hObject, eventdata, handles)
% hObject    handle to buttThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET UPROJ SPKCLASS EVENTTIMES
global EXTRAS

enter_running_state(handles,'Thresholding...');

st=XAXIS(1):XAXIS(2);
threshold=str2num(get(handles.editSigma,'String'));
[EVENTTIMES,sigma]=spk_roughmatch(SPKRAW,threshold,XAXIS);
EXTRAS.sigthreshold=threshold;

SPIKESET=zeros(length(st),length(EVENTTIMES));
for jj=1:length(EVENTTIMES),
    SPIKESET(:,jj)=SPKRAW(EVENTTIMES(jj)+st);
end
scorr=SPIKESET*SPIKESET';
[u,s,v]=svd(scorr);

UPROJ=SPIKESET'*u(:,1:PCC);
for jj=1:PCC,
    if (sum(SPIKESET(:,jj)))<0,
        u(:,jj)=-u(:,jj);
        UPROJ(:,jj)=-UPROJ(:,jj);
    end
end

UNITMEAN=mean(SPIKESET,2);
UNITSTD=UNITMEAN.*0;
UNITCOUNT=1;

PCS=u(:,1:PCC);
SPKCLASS=ones(size(EVENTTIMES));

leave_running_state(handles);

update_plots(handles);


% --- Executes on button press in buttTemplate.
function buttTemplate_Callback(hObject, eventdata, handles)
% hObject    handle to buttTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global C0 UNITMEAN UNITTOL SWEEPOUT PCS SIGTHRESH

enter_running_state(handles,'Waiting for user to load template...');

uiwait(m_template);

leave_running_state(handles);

if isempty(PCS),
    buttMatch_Callback(handles.buttMatch, eventdata, handles);
end

if ~isempty(UNITMEAN),
    set(handles.editClusterCount,'String',num2str(size(UNITMEAN,2)));
    for uu=1:6,
       hname=eval(sprintf('handles.editTolerance%d',uu));
       if uu<=length(UNITTOL),
          set(hname,'String',num2str(UNITTOL(uu)));
       else
          set(hname,'String',num2str(UNITTOL(1)));
       end
    end
    set(handles.checkSweep,'Value',SWEEPOUT);
    % don't re-threshold??
    %if ~isempty(SIGTHRESH),
    %    oldsigthreshold=str2num(get(handles.editSigma,'String'));
    %    newsigthreshold=SIGTHRESH;
    %    if oldsigthreshold ~= newsigthreshold,
    %        set(handles.editSigma,'String',num2str(newsigthreshold));
    %        buttThresh_Callback(handles.buttThresh, eventdata, handles)
    %    end
    %end
    C0=UNITMEAN'*PCS;
    %buttCluster_Callback(handles.buttCluster, eventdata, handles);
    buttMatch_Callback(handles.buttCluster, eventdata, handles);
end



% --- Executes on button press in buttSave.
function buttSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(m_save);


% --- Executes on button press in buttQuit.
function buttQuit_Callback(hObject, eventdata, handles)
% hObject    handle to buttQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('not clearing any data!');
close

function editParameterFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editParameterFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editParameterFilename as text
%        str2double(get(hObject,'String')) returns contents of editParameterFilename as a double


% --- Executes during object creation, after setting all properties.
function editParameterFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParameterFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigma_Callback(hObject, eventdata, handles)
% hObject    handle to editSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigma as text
%        str2double(get(hObject,'String')) returns contents of editSigma as a double


% --- Executes during object creation, after setting all properties.
function editSigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTolerance1_Callback(hObject, eventdata, handles)
% hObject    handle to editTolerance1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTolerance1 as text
%        str2double(get(hObject,'String')) returns contents of editTolerance1 as a double


% --- Executes during object creation, after setting all properties.
function editTolerance1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTolerance1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttMatch.
function buttMatch_Callback(hObject, eventdata, handles)
% hObject    handle to buttMatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET 
global UPROJ SPKCLASS KCOL C0 EXTRAS

k=str2num(get(handles.editClusterCount,'String'));
tolerance=[str2num(get(handles.editTolerance1,'String'));
           str2num(get(handles.editTolerance2,'String'));
           str2num(get(handles.editTolerance3,'String'));
           str2num(get(handles.editTolerance4,'String'));
           str2num(get(handles.editTolerance5,'String'));
           str2num(get(handles.editTolerance6,'String'))];

if k~=size(UNITMEAN,2),
    errordlg('You must choose new initial conditions for new cluster count','meska');
    return
end

if sum(tolerance<=0)>0,
    errordlg('tolerance value invalid','meska');
    return
end

enter_running_state(handles,'Clustering...');

sweepout=get(handles.checkSweep,'value');
clustercore('distance',tolerance,sweepout);

EXTRAS.tolerance=tolerance;
EXTRAS.sweepout=sweepout;

leave_running_state(handles);

update_plots(handles);


if 0,
    global SPKRAW UNITMEAN XAXIS PCC PCS SPIKESET UPROJ SPKCLASS EVENTTIMES

    enter_running_state(handles,'Finding template matches...');

    st=XAXIS(1):XAXIS(2);

    [EVENTTIMES,sigma]=spk_roughmatch(SPKRAW,UNITMEAN,XAXIS);

    SPIKESET=zeros(length(st),length(EVENTTIMES));
    for jj=1:length(EVENTTIMES),
        SPIKESET(:,jj)=SPKRAW(EVENTTIMES(jj)+st);
    end
    scorr=SPIKESET*SPIKESET';
    [u,s,v]=svd(scorr);

    UPROJ=SPIKESET'*u(:,1:PCC);
    for jj=1:PCC,
        if (sum(SPIKESET(:,jj)))<0,
            u(:,jj)=-u(:,jj);
            UPROJ(:,jj)=-UPROJ(:,jj);
        end
    end

    PCS=u(:,1:PCC);

    set(handles.editClusterCount,'String',num2str(size(UNITMEAN,2)));
    C0=UNITMEAN'*PCS;

    buttCluster_Callback(handles.buttCluster, eventdata, handles)

    leave_running_state(handles);

    update_plots(handles);
end

function editClusterCount_Callback(hObject, eventdata, handles)
% hObject    handle to editClusterCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editClusterCount as text
%        str2double(get(hObject,'String')) returns contents of editClusterCount as a double


% --- Executes during object creation, after setting all properties.
function editClusterCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editClusterCount (see GCBO)
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

function update_status(handles,status)

set(handles.textStatus,'String',status);


function enter_running_state(handles,status);

if nargin>1,
    update_status(handles,status);
end

% moved functionality to load for speed
%inactive(handles.editSigma);
%inactive(handles.buttThresh);
inactive(handles.editClusterCount);
inactive(handles.editTolerance1);
inactive(handles.editTolerance2);
inactive(handles.editTolerance3);
inactive(handles.editTolerance4);
inactive(handles.editTolerance5);
inactive(handles.editTolerance6);
inactive(handles.buttChooseFile);
inactive(handles.buttTemplate);
inactive(handles.buttMatch);
inactive(handles.buttIC);
inactive(handles.buttCluster);
inactive(handles.buttMovie);
inactive(handles.buttSTRF);
inactive(handles.buttRaster);
inactive(handles.buttSave);
inactive(handles.buttQuit);
inactive(handles.butt_sitesort);
drawnow;

function leave_running_state(handles);

set(handles.textStatus,'String','IDLE');

% moved functionality to load for speed
%active(handles.editSigma);
%active(handles.buttThresh);
active(handles.editClusterCount);
active(handles.editTolerance1);
active(handles.editTolerance2);
active(handles.editTolerance3);
active(handles.editTolerance4);
active(handles.editTolerance5);
active(handles.editTolerance6);
active(handles.buttChooseFile);
active(handles.buttTemplate);
active(handles.buttMatch);
active(handles.buttIC);
active(handles.buttCluster);
active(handles.buttMovie);
active(handles.buttSTRF);
active(handles.buttRaster);
active(handles.buttSave);
active(handles.buttQuit);
active(handles.butt_sitesort);
drawnow;

% --------------------------------------------------------------------
% --- inactive.
function inactive(handle_tag)
% handles    structure with handles and user data (see GUIDATA)

set(handle_tag, 'Enable', 'off');


% --------------------------------------------------------------------
% --- active.
function active(handle_tag)
% handles    structure with handles and user data (see GUIDATA)

set(handle_tag, 'Enable', 'on');



function update_plots(handles);

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET UPROJ 
global SPKCLASS SPKCOUNT KCOL C0 CELLIDS EXTRAS EVENTTIMES NEWSNR FILEDATA
persistent resplots

disp([evalin('caller','mfilename') ': refreshing plots']);

enter_running_state(handles,'Finding template matches...');

aset=[handles.axes12 handles.axes13 handles.axes23];
apair1=[1 1 2];
apair2=[2 3 3];
k=str2num(get(handles.editClusterCount,'String'));

for uu=1:length(aset),
    axes(aset(uu));
    cla
    if aset==1,
       testrange=round(linspace(1,length(SPIKESET),2000));
    else
       testrange=round(linspace(1,length(SPIKESET),1000));
    end
    u1=apair1(uu);
    u2=apair2(uu);
    
    for jj=max(SPKCLASS):-1:1,
        spmatch=find(SPKCLASS==jj);
        if length(spmatch)>0
            testrange=spmatch(round(linspace(1,length(spmatch),...
                round(1200/max(SPKCLASS)))));
        end
        
        plot(UPROJ(testrange,u1),UPROJ(testrange,u2),[KCOL{jj},'.']);
        hold on
        
    end
    a=[mean(UPROJ(:,u1))-std(UPROJ(:,u1)).*4 ...
       mean(UPROJ(:,u1))+std(UPROJ(:,u1)).*4 ...
       mean(UPROJ(:,u2))-std(UPROJ(:,u2)).*4 ...
       mean(UPROJ(:,u2))+std(UPROJ(:,u2)).*4];
    plot([a(1) a(2)],[0 0],'k--');
    plot([0 0],[a(3) a(4)],'k--');
    
    for ii=1:UNITCOUNT,
        x0=PCS(:,u1)'*UNITMEAN(:,ii);
        xs=PCS(:,u1)'*UNITSTD(:,ii);
        y0=PCS(:,u2)'*UNITMEAN(:,ii);
        ys=PCS(:,u2)'*UNITSTD(:,ii);
        ht=text(x0,y0,num2str(ii));
        set(ht,'Color',[1 0 0]);
    end
    
    hold off
    xm=mean(UPROJ(:,u1));
    ym=mean(UPROJ(:,u2));
    xs=std(UPROJ(:,u1));
    ys=std(UPROJ(:,u2));
    
    axis(a);
    %axis tight
    aa=axis;
    
    %axis([max([aa(1) xm-xs.*5]) min([aa(2) xm+xs.*5]) ...
    %      max([aa(3) ym-ys.*5]) min([aa(4) ym+ys.*5])]);

    title(sprintf('PCs %d vs %d',u1,u2));
end

axes(handles.axesPC);
st=XAXIS(1):XAXIS(2);
plot(st,PCS);
legend('pc1','pc2','pc3');

if isfield(handles,'resplots'),
    try
    delete(handles.resplots);
    catch
    end
    try
    delete(handles.resplots2);
    catch
    end
end
handles.resplots=[];
handles.resplots2=[];

%leave_running_state(handles);
%guidata(handles.figure1, handles);

classcount=max(SPKCLASS);
plotcount=max([UNITCOUNT+1 classcount]);
a=[];

yoff=0.1;
ysp=(1-yoff.*1.5)./plotcount;
yh=ysp.*0.75;
if yh>0.4,
    yh=0.4;
end

% cummulative spike display
handles.resplots=[handles.resplots subplot('position',[0.55 yoff 0.1 yh])];


for ii=1:UNITCOUNT,
   handles.resplots=[handles.resplots ...
            subplot('position',[0.55 (plotcount-ii).*ysp+yoff 0.1 yh])];
   errorshade(st',UNITMEAN(:,ii,1),UNITSTD(:,ii,1),KCOL{ii});
   if ii<=FILEDATA.cellcount & ii<=length(SPKCOUNT) & SPKCOUNT(ii)>0,
       title(sprintf('%s tplt (%d spks)',CELLIDS{ii},SPKCOUNT(ii)));
   elseif ii<=length(SPKCOUNT),
       title(sprintf('user IC %d',ii));
   else
       title(sprintf('crap tplt #%d',ii));
   end
   axis tight
   a=[a;axis];
end

NEWSNR=zeros(classcount,1);

for jj=classcount:-1:1,
    spmatch=find(SPKCLASS==jj);
    
    handles.resplots=[handles.resplots subplot('position',[0.7 (plotcount-jj).*ysp+yoff 0.1 yh])];
    newunitmean=mean(SPIKESET(:,spmatch),2);
    newunitstd=std(SPIKESET(:,spmatch),0,2);
    
    errorshade(st',newunitmean,newunitstd);
    if jj<=k,
        hold on
        plot(st',UNITMEAN(:,jj),'k--','LineWidth',2);
        hold off
        axis tight
        a=[a;axis];
        
        NEWSNR(jj)=std(newunitmean)./EXTRAS.sigma;
        title(sprintf('C%d n=%d snr=%.2f',jj,length(spmatch),...
            NEWSNR(jj)));
        
        axes(handles.resplots(1));
        if jj<classcount,
           hold on
        end
        if length(spmatch)>0,
            testidx=spmatch(round(linspace(1,length(spmatch),50)));
            plot(st,SPIKESET(:,testidx),KCOL{jj});
        end
        if jj==k,
           hold on
           plot(st([1 end]),-EXTRAS.sigma.*EXTRAS.sigthreshold.*[1 1],'k--');
        end
        hold off
    else
        title(sprintf('crap: %d\n',length(spmatch)));
    end
    
    handles.resplots2=[handles.resplots2 subplot('position',[0.85 (plotcount-jj).*ysp+yoff 0.1 yh])];
    isi=diff(EVENTTIMES(spmatch))./EXTRAS.rate*1000;
    isi=isi(find(isi<30));
    hist(isi,linspace(0,50,51));
    if jj==1,
        title('ISI');
    end
    ta=axis;
    axis([0 30 ta(3:4)]);
end

aout=[XAXIS min(a(:,3)) max(a(:,4))];
for aaa=handles.resplots,
    axes(aaa);
    axis(aout);
end

leave_running_state(handles);
guidata(handles.figure1, handles);


% save the sorted data to a temporary file for quick & dirty STRF and raster
function destin=savespiketemp;

global UNITCOUNT CELLIDS SPKCLASS SPIKESET XAXIS EVENTTIMES FILEDATA EXTRAS

tspikefile=tempname;

source=FILEDATA.parmfile;
destin=basename(FILEDATA.parmfile);
destin=strrep(destin,'.m','');
destin=[fileparts(tempname) filesep destin];
sorter= 'temp';
PSORTER=1;
comments='PC-cluster temp file by mespca.m';
abaflag=0;

% delete any previously existing tempfile
if exist([destin '.spk.mat'],'file'),
    delete([destin '.spk.mat']);
end

% save spike times and templates for each cluster

% reorder templates so that first one corresponds to first unit in sorted
% cells. and so on. crap clusters tacked on at the end
unitmean=zeros(size(SPIKESET,1),UNITCOUNT);
unitstd=zeros(size(SPIKESET,1),UNITCOUNT);
spk=cell(12,1);
for ab=1:UNITCOUNT,
    spmatch=find(SPKCLASS==ab);
    spk{ab,1}=EVENTTIMES(spmatch);
    unitmean(:,ab)=mean(SPIKESET(:,spmatch),2);
    unitstd(:,ab)=std(SPIKESET(:,spmatch),0,2);
end

extras=EXTRAS;
extras.unitmean=unitmean;
extras.unitstd=unitstd;
savespikes(source,destin,EVENTTIMES,SPIKESET,spk,sorter,PSORTER,...
           comments,extras,abaflag,XAXIS);

destin=[destin '.spk.mat'];

% --- Executes on button press in buttSTRF.
function buttSTRF_Callback(hObject, eventdata, handles)
% hObject    handle to buttSTRF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UNITCOUNT CELLIDS SPKCLASS SPIKESET XAXIS EVENTTIMES FILEDATA EXTRAS

destin=savespiketemp;

figure;
for ii=1:UNITCOUNT,
    axeshandle=subplot(1,UNITCOUNT,ii);
    
    if isfield(FILEDATA,'ReferenceClass') && ...
          strcmp(FILEDATA.ReferenceClass,'ComplexChord') && ...
          isfield(FILEDATA,'Ref_LightSubset') & ...
          length(length(FILEDATA.Ref_LightSubset)>2),
       
       options.usesorted=1;
       options.spikefile=destin;
       alm_online(FILEDATA.parmfile,FILEDATA.channel,ii,axeshandle,options);
       
    elseif isfield(FILEDATA,'ReferenceClass') && ...
          strcmp(FILEDATA.ReferenceClass,'TStuning'),  %for multi-level tuning
       options.usesorted=1;
       options.spikefile=destin;
       options.datause='Ref';
       mltc_online(FILEDATA.parmfile,FILEDATA.channel,ii,axeshandle,options);
       
    elseif isfield(FILEDATA,'ReferenceClass') && ...
          (strcmp(FILEDATA.ReferenceClass,'ComplexChord') || ...
           strcmp(FILEDATA.ReferenceClass,'NoiseBurst') || ...
           strcmp(FILEDATA.ReferenceClass,'RandomTone')),
       options.rasterfs=1000;
       options.sigthreshold=4;
       options.datause='Ref Only';
       options.psth=0;
       options.psthfs=20;
       options.lfp=0;
       options.usesorted=1;
       options.spikefile=destin;
       
       chord_strf_online(FILEDATA.parmfile,FILEDATA.channel,ii,...
                         axeshandle,options);
    elseif isfield(FILEDATA,'ReferenceClass') && ...
          (strcmp(FILEDATA.ReferenceClass,'SpNoise') ||...
           strcmp(FILEDATA.ReferenceClass,'PipSequence')),
        
       options.rasterfs=100;
       options.sigthreshold=4;
       options.datause='Ref Only';
       options.psth=0;
       options.psthfs=20;
       options.lfp=0;
       options.usesorted=1;
       options.spikefile=destin;
       options.chancount=0;
       if strcmp(FILEDATA.ReferenceClass,'SpNoise'),
           options.filtfmt='envelope';
       else
           options.filtfmt='parm';
       end
       boost_online(FILEDATA.parmfile,FILEDATA.channel,ii,...
                         axeshandle,options);
    else
       options.usefirstcycle=0;
       strf_offline2(FILEDATA.parmfile,destin,FILEDATA.channel,ii, ...
                     axeshandle,options);
    end
end

% delete temp file when done
if exist(destin,'file'),
    delete(destin);
end


% --- Executes on button press in buttRaster.
function buttRaster_Callback(hObject, eventdata, handles)
% hObject    handle to buttRaster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UNITCOUNT CELLIDS SPKCLASS SPIKESET XAXIS EVENTTIMES FILEDATA EXTRAS

disp('Computing raster...');
destin=savespiketemp;
channel=FILEDATA.channel; %? or FILEDATA.channel;
rasterfs=500;

figure;
for ii=1:UNITCOUNT,
    hs=subplot(1,UNITCOUNT,ii);
    
    options.spikefile=destin;
    options.rasterfs=500;
    options.channel=FILEDATA.channel;
    options.usesorted=1;
    options.unit=ii;
    options.psthfs=15;
    
    if ~isempty(findstr(FILEDATA.parmfile,'FTC')) | ...
          ~isempty(findstr(FILEDATA.parmfile,'AMT')) | ...
          ~isempty(findstr(FILEDATA.parmfile,'BNB')) | ...
          ~isempty(findstr(FILEDATA.parmfile,'AMN')),
       options.rasterfs=1000;
       options.datause='Ref';
       options.psth=0;
    elseif ~isempty(findstr(FILEDATA.parmfile,'DMS')),
       options.PreStimSilence=0.25;
       options.PostStimSilence=0.35;
       %options.MaxStimDuration=0.75;
       %options.datause='Collapse keep order';
       options.datause='Collapse both';
       options.psth=1;
    elseif ~isempty(findstr(FILEDATA.parmfile,'MTS')),
       options.PreStimSilence=0.1;
       options.PostStimSilence=1;
       options.datause='Collapse both';
       options.psth=1;
    elseif 1 | ~isempty(findstr(FILEDATA.parmfile,'_RTD')) | ...
          ~isempty(findstr(FILEDATA.parmfile,'_PTD')) | ...
          ~isempty(findstr(FILEDATA.parmfile,'_CLT')) | ...
          ~isempty(findstr(FILEDATA.parmfile,'_MTD')) | ...
          ~isempty(findstr(FILEDATA.parmfile,'_VTL')),
       options.datause='Collapse both';
       options.psth=1;
       options.rasterfs=1000;
       options.psthfs=18;
    else
       options.datause='Both';
       options.psth=0;
    end
    
    [r,tags]=raster_load(FILEDATA.parmfile,channel,ii,options);
    raster_plot(FILEDATA.parmfile,r,tags,hs,options);
end




% --- Executes on button press in buttMovie.
function buttMovie_Callback(hObject, eventdata, handles)
% hObject    handle to buttMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET UPROJ 
global SPKCLASS SPKCOUNT KCOL C0 CELLIDS EXTRAS EVENTTIMES NEWSNR FILEDATA

enter_running_state(handles,'Displaying fancy movie...');

aset=[handles.axes12 handles.axes13 handles.axes23];
apair1=[1 1 2];
apair2=[2 3 3];
k=str2num(get(handles.editClusterCount,'String'));

moviesteps=10;
stepsize=length(SPIKESET)./moviesteps;
for mstep=1:moviesteps,
   steprange=round((mstep-1).*stepsize+1):round(mstep.*stepsize);
   
   for uu=1:length(aset),
      axes(aset(uu));
      aa=axis;
      %cla
      %testrange=round(linspace(1,length(SPIKESET),2000));
      u1=apair1(uu);
      u2=apair2(uu);
      
      for jj=max(SPKCLASS):-1:1,
         spmatch=steprange(find(SPKCLASS(steprange)==jj));
         if length(spmatch)>0
            testrange=spmatch(round(linspace(1,length(spmatch),...
                                             round(600/max(SPKCLASS)))));
            plot(UPROJ(testrange,u1),UPROJ(testrange,u2),[KCOL{jj},'.']);
         end
         
         hold on
         
      end
      a=axis;
      plot([a(1) a(2)],[0 0],'k--');
      plot([0 0],[a(3) a(4)],'k--');
      
      for ii=1:UNITCOUNT,
         x0=PCS(:,u1)'*UNITMEAN(:,ii);
         xs=PCS(:,u1)'*UNITSTD(:,ii);
         y0=PCS(:,u2)'*UNITMEAN(:,ii);
         ys=PCS(:,u2)'*UNITSTD(:,ii);
         ht=text(x0,y0,num2str(ii));
         set(ht,'Color',[1 0 0]);
      end
      
      hold off
      axis(aa);
      
      %title(sprintf('PCs %d vs %d',u1,u2));
   end
   pause(0.2);
end

leave_running_state(handles);



function editTolerance2_Callback(hObject, eventdata, handles)
% hObject    handle to editTolerance2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTolerance2 as text
%        str2double(get(hObject,'String')) returns contents of editTolerance2 as a double


% --- Executes during object creation, after setting all properties.
function editTolerance2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTolerance2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTolerance3_Callback(hObject, eventdata, handles)
% hObject    handle to editTolerance3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTolerance3 as text
%        str2double(get(hObject,'String')) returns contents of editTolerance3 as a double


% --- Executes during object creation, after setting all properties.
function editTolerance3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTolerance3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTolerance4_Callback(hObject, eventdata, handles)
% hObject    handle to editTolerance4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTolerance4 as text
%        str2double(get(hObject,'String')) returns contents of editTolerance4 as a double


% --- Executes during object creation, after setting all properties.
function editTolerance4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTolerance4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTolerance5_Callback(hObject, eventdata, handles)
% hObject    handle to editTolerance5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTolerance5 as text
%        str2double(get(hObject,'String')) returns contents of editTolerance5 as a double


% --- Executes during object creation, after setting all properties.
function editTolerance5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTolerance5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTolerance6_Callback(hObject, eventdata, handles)
% hObject    handle to editTolerance6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTolerance6 as text
%        str2double(get(hObject,'String')) returns contents of editTolerance6 as a double


% --- Executes during object creation, after setting all properties.
function editTolerance6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTolerance6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkSweep.
function checkSweep_Callback(hObject, eventdata, handles)
% hObject    handle to checkSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSweep


% --- Executes on button press in butt_sitesort.
function butt_sitesort_Callback(hObject, eventdata, handles)
% hObject    handle to butt_sitesort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global FILEDATA EXTRAS SPKRAW CELLIDS UNITCOUNT UNITMEAN UNITSTD SPIKESET
global XAXIS PCC PCS SPIKESET UPROJ SPKCLASS EVENTTIMES
global SPKCOUNT UNITTOL SIGTHRESH SWEEPOUT C0
global LASTFILEDATA SAVEOK
global chanstr

enter_running_state(handles,'Running site sort...');

baseparmfile=get(handles.editParameterFilename,'String');
basechannel=str2num(get(handles.editChannel,'String'));
basesigma=str2num(get(handles.editSigma,'String'));

if isempty(baseparmfile),
   errordlg('You must have loaded one file to initiate site sort.');
   leave_running_state(handles);
   return
end

bb=basename(baseparmfile);
sql=['SELECT * FROM sCellFile where stimfile="',bb,'"',...
     ' AND channum=',num2str(basechannel)];
filedata=mysql(sql);
if isempty(filedata),
   errordlg('Current file must have been sorted to initiate site sort.');
   leave_running_state(handles);
   return
end

% load template
LASTFILEDATA=FILEDATA;

sql=['SELECT * FROM gDataRaw WHERE id=',num2str(LASTFILEDATA.rawid)];
rawdata=mysql(sql);
LASTFILEDATA.spikefile=rawdata.matlabfile;

sql=['SELECT DISTINCT gDataRaw.*,sCellFile.channum',...
     ' FROM gDataRaw LEFT JOIN sCellFile',...
     ' ON gDataRaw.id=sCellFile.rawid',...
     ' AND sCellFile.channum=',num2str(basechannel),...
     ' WHERE gDataRaw.masterid=',num2str(rawdata.masterid),...
     ' AND not(gDataRaw.bad)',...
     ' ORDER BY gDataRaw.id'];
rawdata=mysql(sql);

fileliststr=sprintf('Site %s Channel %d\nFiles to be sorted:\n\n',...
                    rawdata(1).cellid,basechannel);
for ii=1:length(rawdata),
   if isempty(rawdata(ii).channum),
      fileliststr=[fileliststr sprintf('%s\n',basename(rawdata(ii).parmfile))];
   else
      fileliststr=[fileliststr sprintf('(SKIP) %s\n',basename(rawdata(ii).parmfile))];
   end
end
fileliststr=[fileliststr sprintf('\nProceed?')];
yn=questdlg(fileliststr);
if ~strcmp(yn,'Yes'),
   leave_running_state(handles);
   return
end

for ii=1:length(rawdata),
   if ~isempty(rawdata(ii).channum),
      fprintf('Skipping %s, already sorted\n',basename(rawdata(ii).parmfile));
   else
      FILEDATA=loadrawfiledata(rawdata(ii).id,basechannel);
      FILEDATA.sigthresh=basesigma;
      %FILEDATA.globalsigma=get(handles.checkGlobalSigma,'Value');
      FILEDATA.globalsigma=LASTFILEDATA.globalsigma;
      
      update_status(handles,'LOADING...');
      guidata(hObject, handles);
      
      
      SPKRAW=[];
      
      evpv=evpversion(FILEDATA.evpfile);
      if evpv<1,
         evplocal=evpmakelocal(FILEDATA.evpfile);
         evpv=evpversion(evplocal);
      end
      
      if evpv<1,
         errordlg(['evp file not found: ',FILEDATA.evpfile]);
         return
      end
      
      % clear template stuff
      UNITCOUNT=0;
      UNITMEAN=[];
      SPIKESET=[];
      
      set(handles.editParameterFilename,'String',FILEDATA.parmfile);
      set(handles.editChannel,'String',num2str(FILEDATA.channel));
      set(handles.editSigma,'String',num2str(FILEDATA.sigthresh));
      
      drawnow;
      
      if FILEDATA.globalsigma,
         fixedsigma=site_get_sigma(FILEDATA.siteid,FILEDATA.channel);
         if ~fixedsigma,
            yn=questdlg(['You requested to use the global fixed sigma, but' ...
                         ' none is associated with this site. Calc sigma' ...
                         ' and save it?'],'No global sigma','Yes','No', ...
                        'Yes');
         else
            fprintf('sigma for thresholding fixed at %.3f\n',fixedsigma);
         end
      else
         fixedsigma=0;
      end
      
      % this should return a thresholded set of spike events
      [SPKRAW, EXTRAS]=loadevp(FILEDATA.parmfile,FILEDATA.evpfile,...
                               num2str(FILEDATA.channel),...
                               FILEDATA.sigthresh,fixedsigma);
      
      if FILEDATA.globalsigma && fixedsigma==0 && strcmp(yn,'Yes'),
         site_set_sigma(FILEDATA.siteid,FILEDATA.channel,EXTRAS.sigma);
      end
      
      SPKRAW=single(SPKRAW);
      
      st=XAXIS(1):XAXIS(2);
      threshold=str2num(get(handles.editSigma,'String'));
      %[EVENTTIMES,sigma]=spk_roughmatch(SPKRAW,threshold,XAXIS);
      EXTRAS.sigthreshold=FILEDATA.sigthresh;
      EVENTTIMES=EXTRAS.spiketimes;
      sigma=EXTRAS.sigma;
      
      SPIKESET=double(SPKRAW(1:XAXIS(2)-XAXIS(1)+1,:));
      scorr=SPIKESET*SPIKESET';
      [u,s,v]=svd(scorr);
      
      UPROJ=SPIKESET'*u(:,1:PCC);
      if prod(size(UPROJ))>0
         for jj=1:PCC,
            if (sum(SPIKESET(:,jj)))<0,
               u(:,jj)=-u(:,jj);
               UPROJ(:,jj)=-UPROJ(:,jj);
            end
         end
      end
      
      UNITMEAN=mean(SPIKESET,2);
      UNITSTD=UNITMEAN.*0;
      UNITCOUNT=1;
      
      PCS=u(:,1:PCC);
      SPKCLASS=ones(size(EVENTTIMES));
      
      fprintf('Auto-matching template for %s\n',LASTFILEDATA.spikefile);
      meska_loadtemplate(LASTFILEDATA.spikefile,LASTFILEDATA.channel);
      
      set(handles.editClusterCount,'String',num2str(size(UNITMEAN,2)));
      for uu=1:6,
         hname=eval(sprintf('handles.editTolerance%d',uu));
         if uu<=length(UNITTOL),
            set(hname,'String',num2str(UNITTOL(uu)));
         else
            set(hname,'String',num2str(UNITTOL(1)));
         end
      end
      set(handles.checkSweep,'Value',SWEEPOUT);
      C0=UNITMEAN'*PCS;
      
      disp('Running k-means...');
      buttCluster_Callback(handles.buttCluster, eventdata, handles);
      %buttMatch_Callback(handles.buttMatch, eventdata, handles);
      
      if isfield(FILEDATA,'ReferenceClass'),
         if strcmp(FILEDATA.ReferenceClass,'Torc') || ...
                 strcmp(FILEDATA.ReferenceClass,'NoiseBurst'),
            buttSTRF_Callback;
         elseif strcmp(FILEDATA.ReferenceClass,'RandomTone') || ...
                 strcmp(FILEDATA.ReferenceClass,'SpNoise'),
            buttRaster_Callback;
         end
      end
      
      uiwait(m_save);
      
      if ~SAVEOK,
         yn=questdlg(['User cancelled save.  Continue with next file?'...
                      ' No aborts site sort.']);
         if length(yn)==0 || yn(1)~='Y',
            uiwait(msgbox('User cancelled save.  Aborting site sort.'));
            leave_running_state(handles);
            return
         end
      end
      
   end
end

uiwait(msgbox(['Site sort complete for site ',rawdata(1).cellid,...
               ' channel ',num2str(basechannel)]));

leave_running_state(handles);
guidata(hObject, handles);

