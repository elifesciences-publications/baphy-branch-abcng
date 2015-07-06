
%%Generic Matlab GUI functions
function varargout = test_params_guide(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_params_guide_OpeningFcn, ...
                   'gui_OutputFcn',  @test_params_guide_OutputFcn, ...
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

function test_params_guide_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function test_params_Callback(hObject, eventdata, handles)
refresh(handles)

function varargout = test_params_guide_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%Pupil measurement parameters
function edit_high_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
    get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_high_Callback(hObject, eventdata, handles)
refresh(handles)

function edit_low_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
    get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_low_Callback(hObject, eventdata, handles)
refresh(handles)

function edit_slop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
    get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_slop_Callback(hObject, eventdata, handles)
refresh(handles)

function edit_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
    get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_dist_Callback(hObject, eventdata, handles)
refresh(handles)

%%Image/video loading functions
function load_image_Callback(hObject, eventdata, handles)
[f dir] = uigetfile('*.*');
handles.im = imread([dir f]);
guidata(hObject, handles)
axes(handles.head_ax)
cla
imshow(handles.im)
axis equal

function load_video_Callback(hObject, eventdata, handles)
[f dir] = uigetfile('*.*');
set(handles.figure1, 'pointer', 'watch')
drawnow
savepath=pwd; % for some reason, mmread changes path to location of mmread.m
handles.vid = mmread([dir f],1:100:8000);
cd(savepath);
set(handles.figure1,'pointer','arrow')
guidata(hObject, handles)
    
function edit_frame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
		get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_frame_Callback(hObject, eventdata, handles)
handles.frame = str2num(get(handles.edit_frame, 'string'));
handles.im = handles.vid.frames(handles.frame).cdata;
guidata(hObject, handles)
axes(handles.head_ax)
cla
imshow(handles.im)
axis equal
if isfield(handles, 'roi')
    handles.eye_im = imcrop(rgb2gray(handles.im), handles.roi);
    guidata(hObject, handles)
    axes(handles.head_ax)
    rectangle('Position', handles.roi, 'Linewidth', 1, 'EdgeColor', 'b')
    refresh(handles)
end

function set_roi_Callback(hObject, eventdata, handles)
figure
imagesc(handles.im)
r = imrect;
handles.roi = getPosition(r);
close
handles.eye_im = imcrop(rgb2gray(handles.im), handles.roi);
guidata(hObject, handles)
axes(handles.head_ax)
if isfield(handles, 'roi')
    cla
    imshow(handles.im)
end
rectangle('Position', handles.roi, 'Linewidth', 1, 'EdgeColor', 'b')
refresh(handles)

%%Pupil measurement functions
function refresh(handles)
high = str2num(get(handles.edit_high, 'string'));
low  = str2num(get(handles.edit_low, 'string'));
slop = str2num(get(handles.edit_slop, 'string'));
dist = str2num(get(handles.edit_dist, 'string'));
eye_im = handles.eye_im;

[d, im, c, e] = measure_pupil(eye_im, high, low, dist, slop);
max_dist = (1+slop)*(c.d/2);
min_dist = (1-slop)*(c.d/2);

axes(handles.pupil_circle_ax)
cla
imshow(im.pupil)
ellipse(min_dist, min_dist, 0, c.x, c.y, 'g');
ellipse(max_dist, max_dist, 0, c.x, c.y, 'g');
axis equal

axes(handles.edge_ax)
cla
imshow(im.all_edges)
ellipse(min_dist, min_dist, 0, c.x, c.y, 'g');
ellipse(max_dist, max_dist, 0, c.x, c.y, 'g');
axis equal

axes(handles.pupil_ellipse_ax)
cla
hold on
imshow(eye_im)
ellipse(e.b, e.a, e.phi, e.Y0_in, e.X0_in, 'r');
text(c.x, c.y, num2str(round(d)), 'color', 'r');
hold off
axis equal

axes(handles.hist_ax)
cla
hist(double(eye_im(:)), 100);
axis tight
hold on
ax = axis;
plot([low low],  [ax(3) ax(4)], 'b');
plot([high high], [ax(3) ax(4)], 'b');
xlabel('Intensity')
ylabel('Frequency (# of Pixels)')
hold off

colormap(jet)

function [d, im, circ, ellipse] = measure_pupil(eye_im, high, low, dist, slop)
  
eye_thresh = eye_im;
eye_thresh(eye_im>high) = 0;
eye_thresh(eye_im<low) = 0;

all_edges = edge(eye_thresh,'canny');
im.all_edges = double(all_edges);

eye_boundary = bwperim(im2bw(eye_thresh, graythresh(eye_thresh)));
all_edges(eye_boundary==1) = 0;
im.all_edges(eye_boundary==1) = 0.2;
 
pupil = eye_thresh;
im.pupil = double(pupil);
pupil(eye_boundary==1) = 0;
im.pupil(eye_boundary==1) = 0.2;
[pupil_y, pupil_x] = find(pupil);
circ.x = round(mean(pupil_x));
circ.y = round(mean(pupil_y));
circ.a = length(pupil_y);
circ.d = sqrt(circ.a*4/pi);
im.pupil(circ.y, circ.x) = 0;

[edge_y, edge_x] = find(all_edges);
dist_from_center = sqrt((edge_x-circ.x).^2 + (edge_y-circ.y).^2);
max_dist = (1+slop)*(circ.d/2);
min_dist = (1-slop)*(circ.d/2);
bad_edges = dist_from_center>max_dist | dist_from_center<min_dist;
for ii = 1:length(bad_edges)
  if bad_edges(ii)
    all_edges(edge_y(ii), edge_x(ii)) = 0;
    im.all_edges(edge_y(ii), edge_x(ii)) = 0.4;
  end
end

[~, nearest_neighbor] = dsearchn([pupil_y,pupil_x], [edge_y,edge_x]);
for ii = 1:length(nearest_neighbor)
  if nearest_neighbor(ii) > dist
    all_edges(edge_y(ii), edge_x(ii)) = 0;
    im.all_edges(edge_y(ii), edge_x(ii)) = 0.6;
  end
end

[pupil_xs, pupil_ys] = find(squeeze(all_edges));
ellipse = fit_ellipse(pupil_xs,pupil_ys);
d = max(ellipse.a, ellipse.b);
