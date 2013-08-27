function varargout = penlocate(varargin)
% PENLOCATE M-file for penlocate.fig
%      PENLOCATE, by itself, creates a new PENLOCATE or raises the existing
%      singleton*.
%
%      H = PENLOCATE returns the handle to a new PENLOCATE or the handle to
%      the existing singleton*.
%
%      PENLOCATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PENLOCATE.M with the given input arguments.
%
%      PENLOCATE('Property','Value',...) creates a new PENLOCATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before penlocate_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to penlocate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help penlocate

% Last Modified by GUIDE v2.5 07-Jul-2008 11:45:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @penlocate_OpeningFcn, ...
                   'gui_OutputFcn',  @penlocate_OutputFcn, ...
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


% --- Executes just before penlocate is made visible.
function penlocate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to penlocate (see VARARGIN)

% varargin{1} - flag. if 1, disable a few components so that site and
% channel are fixed (this is for choosing a template file
% varargin{2} - string, title for window

% Choose default command line output for penlocate
handles.output = hObject;
guidata(hObject, handles);

if length(varargin)>1,
    set(handles.figure1,'Name',varargin{2});
end

initialize_display(hObject,handles);

% UIWAIT makes penlocate wait for user response (see UIRESUME)
uiwait(handles.figure1);


% initialize_display, loading user-specific settings if they
% haven't been set
function initialize_display(hObject,handles,user);

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS
global CELLDB_CHANNEL CELLDB_SIGMA CHOOSING_TEMPLATE
global SIGTHRESH BAPHYHOME BAPHY_LAB

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

sql=['SELECT gAnimal.* FROM gAnimal,gCellMaster',...
    ' WHERE gAnimal.animal=gCellMaster.animal',...
    ' GROUP BY gAnimal.id ORDER BY animal'];
animaldata=mysql(sql);
animals=cell(length(animaldata),1);
[animals{:}]=deal(animaldata.animal);
animals={'ALL' animals{:}};

% load last settings
if isempty(CELLDB_ANIMAL),
   load_db_settings
end

useridx=find(strcmp(CELLDB_USER,users));
if isempty(useridx),
   useridx=1;
end
animalidx=find(strcmp(CELLDB_ANIMAL,animals));
if isempty(animalidx),
   animalidx=1;
end

set(handles.popTester,'String',users);
set(handles.popTester,'Value',useridx);

set(handles.popAnimals,'String',animals);
set(handles.popAnimals,'Value',animalidx);

% Update handles structure
guidata(hObject, handles);

popAnimals_Callback(hObject, [], handles);



% --- Outputs from this function are returned to the command line.
function varargout = penlocate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
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

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS CELLDB_CHANNEL CELLDB_SIGMA

animals=get(handles.popAnimals,'String');
animalidx=get(handles.popAnimals,'Value');
animal=animals{animalidx};
if strcmp(animal,'ALL'),
    animal='Amazon';
end
CELLDB_ANIMAL=animal;

disp('loading site list');
sql=['SELECT gPenetration.id,gPenetration.penname',...
    ' FROM gPenetration',...
    ' WHERE not(training)',...
    ' AND animal like "',animal,'" ORDER BY penname'];
sitedata=mysql(sql);
sites=cell(1,length(sitedata));
if ~isempty(sitedata),
    [sites{:}]=deal(sitedata.penname);
else
    sites={};
end
disp('loaded site list');

set(handles.listPens,'String',sites);
siteidx=find(strcmp(CELLDB_SITEID,sites));
if isempty(siteidx),
   siteidx=1;
end
set(handles.listPens,'Value',siteidx(1));
if isempty(sites)
    CELLDB_SITEID='';
else
    CELLDB_SITEID=sites{siteidx(1)};
end

listPens_Callback(hObject, eventdata, handles);



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


% --- Executes on selection change in listPens.
function listPens_Callback(hObject, eventdata, handles)
% hObject    handle to listPens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listPens contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listPens

global CELLDB_USER CELLDB_ANIMAL CELLDB_PENID
pennames=get(handles.listPens,'String');
siteidx=get(handles.listPens,'Value');
if ~isempty(pennames),
    penname=pennames{siteidx};
else
    penname='';
end
CELLDB_PENID=penname;

disp(['loading info for ' penname]);

sql=['SELECT * FROM gPenetration WHERE penname="',penname,'"'];
pendata=mysql(sql);
if isempty(pendata),
    %do nothing
    return
elseif isempty(pendata.wellimfile),
    disp('guessing info from previous pen');
    numidx=find(penname>='0' & penname<='9');
    pennum=str2num(penname(numidx));
    prevpenname=[penname(1:numidx(1)-1) sprintf('%03d',pennum-1)];
    sql=['SELECT * FROM gPenetration WHERE penname="',prevpenname,'"'];
    prevpendata=mysql(sql);
    if length(prevpendata)==0 | isempty(prevpendata.wellimfile),
        disp('sorry, no previous info found.');
        set(handles.editPhotoFile,'string','<NOT DEFINED>');
    else
       set(handles.editPhotoFile,'string',prevpendata.wellimfile);
    end
else
    set(handles.editPhotoFile,'string',pendata.wellimfile);
end
set(handles.popChannels,'value',pendata.numchans);

cc=strsep(char(pendata.wellposition),'+');
for ii=1:min(pendata.numchans,8),
    if length(cc)==0,
        xx=0; yy=0;
    else
        xx=strsep(cc{ii},',',0)
        yy=xx{2};
        xx=xx{1};
    end
    xs=eval(sprintf('handles.editX%d',ii));
    ys=eval(sprintf('handles.editY%d',ii));
    set(xs,'String',num2str(round(xx)));
    set(ys,'String',num2str(round(yy)));
end

editPhotoFile_Callback(hObject, eventdata, handles);
popChannels_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function listPens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listPens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in buttOk.
function buttOk_Callback(hObject, eventdata, handles)
% hObject    handle to buttOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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



function editphotofile_Callback(hObject, eventdata, handles)
% hObject    handle to editphotofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editphotofile as text
%        str2double(get(hObject,'String')) returns contents of editphotofile as a double


% --- Executes during object creation, after setting all properties.
function editphotofile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editphotofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttPhotoFile.
function buttPhotoFile_Callback(hObject, eventdata, handles)
% hObject    handle to buttPhotoFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global BAPHYDATAROOT

persistent browsepath

if isempty(browsepath),
    %handles.dirname=config('datapath');
    rootpath=strrep(BAPHYDATAROOT,['daq' filesep],'');
    if exist([rootpath,'common' filesep 'photos' filesep 'Craniotomies']),
        browsepath=[rootpath,'common' filesep 'photos' filesep 'Craniotomies'];
    elseif exist([rootpath,'lbhb' filesep 'photos' filesep 'Craniotomies']),
        browsepath=[rootpath,'lbhb' filesep 'photos' filesep 'Craniotomies'];
    else
        browsepath=rootpath;
    end
end

[filename, pathname] = uigetfile({'*.JPG;*.jpg','jpegs (*.jpg)';'*.*','All Files (*.*)'},'Pick photo',...
    [browsepath filesep]);
if ~isequal(filename,0)&~isequal(pathname,0)
    set(handles.editPhotoFile, 'String', [pathname filename]);
    
    browsepath=fileparts(filename);
end

editPhotoFile_Callback(hObject, eventdata, handles)


% --- Executes on button press in buttMapPen.
function buttMapPen_Callback(hObject, eventdata, handles)
% hObject    handle to buttMapPen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttMapFreq.
function buttMapFreq_Callback(hObject, eventdata, handles)
% hObject    handle to buttMapFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CELLDB_ANIMAL

animal=CELLDB_ANIMAL;

dbopen
sql=['SELECT gCellMaster.*,gPenetration.numchans',...
     ' FROM gPenetration,gCellMaster',...
     ' WHERE gCellMaster.penid=gPenetration.id',...
     ' AND gPenetration.animal like "',animal,'"',...
     ' AND not(gPenetration.training)'];
sitedata=mysql(sql);
bfall=[];
cellids={};
cellcount=0;
for ii=1:length(sitedata),
   bfstr=strsep(char(sitedata(ii).bf),',');
   bfsite=[];
   bfupdate=0;
   for cc=1:sitedata(ii).numchans;
      cellid=[sitedata(ii).siteid '-' char('a'+cc-1) '1'];
      if length(bfstr)>=cc && ~isempty(bfstr{cc}),
         fprintf('%d: cellid=%s bf=%.0f\n',ii,cellid,bfstr{cc});
         bfsite(cc,1)=bf;
      else
         fprintf('%d: cellid=%s no bf\n',ii,cellid);
         sql=['SELECT * FROM gDataRaw',...
              ' WHERE gDataRaw.runclass="FTC" AND not(gDataRaw.bad)',...
              ' AND masterid=',num2str(sitedata(ii).id),...
              ' ORDER BY length(gDataRaw.matlabfile) desc,gDataRaw.id'];
         rawdata=mysql(sql);
         figure(1);
         clf
         aa=subplot(1,1,1);
         if length(rawdata)>0,
            parmfile=[rawdata(1).resppath rawdata(1).parmfile];
            [bf,lat]=ftc_tuning(parmfile,cc,0);
         else
            bf=0;lat=0;
         end
         if lat>0,
            bfsite(cc,1)=bf;
            bfupdate=1;
         else
            bfsite(cc,1)=0;
         end
      end
   end
   if bfupdate;
      bfstr=sprintf('%d,',bfsite);
      bfstr=bfstr(1:(end-1));
      
      fprintf('saving to celldb\n');
      sql=['UPDATE gCellMaster set bf="',bfstr,'"',...
           ' WHERE id=',num2str(rawdata(1).masterid)]
      keyboard
      mysql(sql);
   end
end

if 0
   sql=['SELECT gCellMaster.bf,gCellMaster.area,gCellMaster.depth,',...
        ' gDataRaw.* FROM gCellMaster LEFT' ...
        ' JOIN gDataRaw ON gCellMaster.id=gDataRaw.masterid ',...
        ' WHERE gCellMaster.penid=',num2str(pendata(ii).id),...
        ' AND gDataRaw.runclass="FTC" AND not(gDataRaw.bad)',...
        ' ORDER BY length(gDataRaw.matlabfile) desc,gDataRaw.id'];
   sitedata=mysql(sql);
   if isempty(pendata(ii).wellposition) || ...
         isempty(pendata(ii).wellimfile) || ...
         isempty(sitedata),
      disp(['no well position or FTC specified for pen ',pendata(ii).penname]);
   else
      imidx=find(strcmp(imageset,pendata(ii).wellimfile));
      if isempty(imidx),
         imageset={imageset{:},pendata(ii).wellimfile};
         imidx=length(imageset);
      end
      
      numchans=pendata(ii).numchans;
      cc=strsep(char(pendata(ii).wellposition),'+');
      x=zeros(pendata(ii).numchans,1);
      y=zeros(pendata(ii).numchans,1);
      
      for jj=1:pendata(ii).numchans,
         if length(cc)==0,
            x(jj)=0; y(jj)=0;
         else
            xx=strsep(cc{jj},',',0);
            y(jj)=xx{2};
            x(jj)=xx{1};
         end
      end
      
      siteidx=1;
      area=strsep(sitedata(siteidx).area,',',1);
      depth=strsep(sitedata(siteidx).depth,',');
      depth=cat(1,depth{:});
      bf=strsep(sitedata(siteidx).bf,',');
      bf=cat(1,bf{:});
      
      if length(bf)==0 || sum(bf)==0,
         % need to figure out bf!resppath:
         parmfile=[sitedata(siteidx).resppath sitedata(siteidx).parmfile];
         options=[];
         options.rasterfs=100;
         options.includeprestim=[0.1 0];
         options.tag_masks={'Reference'};
         fprintf('loading FTC raster for %s\n',...
                 basename(parmfile));
         r=[];
         for cc=1:numchans,
            options.channel=cc;
            [tr,tags]=loadevpraster(parmfile,options);
            r=cat(3,r,squeeze(nanmean(tr,2)));
         end
         
         unsortedtags=zeros(length(tags),1);
         for cnt1=1:length(tags),
            temptags = strrep(strsep(tags{cnt1},',',1),' ','');
            unsortedtags(cnt1) = str2num(temptags{2});
         end
         
         [sortedtags, index] = sort(unsortedtags); % sort the numeric tags
         tags={tags{index}};
         r=r(:,index,:);
         
         mb=squeeze(mean(mean(r(1:11,:,:))));
         m=squeeze(mean(r(12:end,:,:)));
         lt=log2(sortedtags);
         rlt=linspace(min(lt),max(lt),length(lt).*2)';
         rm=zeros(length(lt).*2,numchans);
         maxf=zeros(numchans,1);
         bf=zeros(numchans,1);
         for cc=1:numchans,
            rm(:,cc)=gsmooth(interp1(lt,m(:,cc),rlt),4);
            
            maxf(cc)=min(find(rm(:,cc)==max(rm(:,cc))));
            if rm(maxf(cc),cc)>2.*std(rm(:,cc)) &&...
                  rm(maxf(cc),cc)>5.*mb(cc),
               fprintf('chan %d: FTC peak at %.0f Hz\n',...
                       cc,2.^rlt(maxf(cc)));
               bf(cc)=round(2.^rlt(maxf(cc)));
            else
               fprintf('chan %d: FTC peak at %.0f Hz not significant\n',...
                       cc,2.^rlt(maxf(cc)));
               bf(cc)=0;
            end
         end
         
         bfstr=sprintf('%d,',bf);
         bfstr=bfstr(1:(end-1));
         
         fprintf('saving to celldb\n');
         sql=['UPDATE gCellMaster set bf="',bfstr,'"',...
              ' WHERE id=',num2str(sitedata(siteidx).masterid)]
         mysql(sql);
         
         figure(1);
         clf
         plot(rlt,rm);
         hold on
         for cc=1:numchans,
            plot(rlt(maxf(cc)),rm(maxf(cc),cc),'x');
         end
         hold off
         title(basename(parmfile));
         
      end
      
      xall=[xall;x];
      yall=[yall;y];
      bfall=[bfall;bf];
      imidxall=[imidxall;repmat(imidx,[numchans 1])];
      
      %keyboard
   end
end



% --- Executes on button press in buttMapDepth.
function buttMapDepth_Callback(hObject, eventdata, handles)
% hObject    handle to buttMapDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function editPhotoFile_Callback(hObject, eventdata, handles)
% hObject    handle to editPhotoFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPhotoFile as text
%        str2double(get(hObject,'String')) returns contents of editPhotoFile as a double

imfile=get(handles.editPhotoFile,'String');
if strcmp(imfile,'<NOT DEFINED>'),
    axes(handles.axesPhoto);
    cla
    axis off;
    text(0.3,0.3,'NOT LOADED');
    axis([0 1 0 1]);
else
    im=imread(imfile);
    axes(handles.axesPhoto);
    imagesc(im);
    axis off;
    axis image;
    
    chancount=get(handles.popChannels,'value');

    hold on
    for ii=1:min(chancount,8)
        xs=eval(sprintf('handles.editX%d',ii));
        ys=eval(sprintf('handles.editY%d',ii));
        xx=str2num(get(xs,'String'));
        yy=str2num(get(ys,'String'));
        if xx>0 | yy>0,
            text(xx,yy,num2str(ii),'HorizontalAlignment','center',...
                'VerticalAlignment','middle','Color',[1 1 1]);
        end
    end
    hold off
end


% --- Executes during object creation, after setting all properties.
function editPhotoFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPhotoFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttSetXY.
function buttSetXY_Callback(hObject, eventdata, handles)
% hObject    handle to buttSetXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CELLDB_PENID;

chancount=get(handles.popChannels,'value');

axes(handles.axesPhoto);

disp('saving to celldb...');

wellposition='';

for ii=1:min(chancount,8),
    [xx,yy]=ginput(1);
    
    xs=eval(sprintf('handles.editX%d',ii));
    ys=eval(sprintf('handles.editY%d',ii));
    set(xs,'String',num2str(round(xx)));
    set(ys,'String',num2str(round(yy)));
    
    wellposition=[wellposition sprintf('%d,%d+',round(xx),round(yy))]
    hold on
    plot(xx,yy,'k.');
    hold off
end

wellimfile=get(handles.editPhotoFile,'string');

sql=['UPDATE gPenetration set wellimfile="',wellimfile,'",wellposition="',wellposition,'"',...
    ' WHERE penname="',CELLDB_PENID,'"']
mysql(sql);

editPhotoFile_Callback(hObject, eventdata, handles);


function editX1_Callback(hObject, eventdata, handles)
% hObject    handle to editX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX1 as text
%        str2double(get(hObject,'String')) returns contents of editX1 as a double


% --- Executes during object creation, after setting all properties.
function editX1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editY1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editX2_Callback(hObject, eventdata, handles)
% hObject    handle to editX2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX2 as text
%        str2double(get(hObject,'String')) returns contents of editX2 as a double


% --- Executes during object creation, after setting all properties.
function editX2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY2_Callback(hObject, eventdata, handles)
% hObject    handle to editY2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY2 as text
%        str2double(get(hObject,'String')) returns contents of editY2 as a double


% --- Executes during object creation, after setting all properties.
function editY2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX3_Callback(hObject, eventdata, handles)
% hObject    handle to editX3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX3 as text
%        str2double(get(hObject,'String')) returns contents of editX3 as a double


% --- Executes during object creation, after setting all properties.
function editX3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY3_Callback(hObject, eventdata, handles)
% hObject    handle to editY3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY3 as text
%        str2double(get(hObject,'String')) returns contents of editY3 as a double


% --- Executes during object creation, after setting all properties.
function editY3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX4_Callback(hObject, eventdata, handles)
% hObject    handle to editX4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX4 as text
%        str2double(get(hObject,'String')) returns contents of editX4 as a double


% --- Executes during object creation, after setting all properties.
function editX4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY4_Callback(hObject, eventdata, handles)
% hObject    handle to editY4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY4 as text
%        str2double(get(hObject,'String')) returns contents of editY4 as a double


% --- Executes during object creation, after setting all properties.
function editY4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popChannels.
function popChannels_Callback(hObject, eventdata, handles)
% hObject    handle to popChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popChannels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popChannels

chancount=get(handles.popChannels,'value');

for ii=1:min(chancount,8),
    xs=eval(sprintf('handles.editX%d',ii));
    ys=eval(sprintf('handles.editY%d',ii));
    set(xs,'enable','on');
    set(ys,'enable','on');
end
for ii=chancount+1:8,
    xs=eval(sprintf('handles.editX%d',ii));
    ys=eval(sprintf('handles.editY%d',ii));
    set(xs,'enable','off');
    set(ys,'enable','off');
end


% --- Executes during object creation, after setting all properties.
function popChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX5_Callback(hObject, eventdata, handles)
% hObject    handle to editX5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX5 as text
%        str2double(get(hObject,'String')) returns contents of editX5 as a double


% --- Executes during object creation, after setting all properties.
function editX5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY5_Callback(hObject, eventdata, handles)
% hObject    handle to editY5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY5 as text
%        str2double(get(hObject,'String')) returns contents of editY5 as a double


% --- Executes during object creation, after setting all properties.
function editY5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX6_Callback(hObject, eventdata, handles)
% hObject    handle to editX6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX6 as text
%        str2double(get(hObject,'String')) returns contents of editX6 as a double


% --- Executes during object creation, after setting all properties.
function editX6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY6_Callback(hObject, eventdata, handles)
% hObject    handle to editY6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY6 as text
%        str2double(get(hObject,'String')) returns contents of editY6 as a double


% --- Executes during object creation, after setting all properties.
function editY6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX7_Callback(hObject, eventdata, handles)
% hObject    handle to editX7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX7 as text
%        str2double(get(hObject,'String')) returns contents of editX7 as a double


% --- Executes during object creation, after setting all properties.
function editX7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY7_Callback(hObject, eventdata, handles)
% hObject    handle to editY7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY7 as text
%        str2double(get(hObject,'String')) returns contents of editY7 as a double


% --- Executes during object creation, after setting all properties.
function editY7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX8_Callback(hObject, eventdata, handles)
% hObject    handle to editX8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX8 as text
%        str2double(get(hObject,'String')) returns contents of editX8 as a double


% --- Executes during object creation, after setting all properties.
function editX8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY8_Callback(hObject, eventdata, handles)
% hObject    handle to editY8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY8 as text
%        str2double(get(hObject,'String')) returns contents of editY8 as a double


% --- Executes during object creation, after setting all properties.
function editY8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


