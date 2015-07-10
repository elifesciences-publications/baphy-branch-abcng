%%Generic Matlab GUI functions
function varargout = pupil(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pupil_OpeningFcn, ...
                   'gui_OutputFcn',  @pupil_OutputFcn, ...
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

function pupil_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = pupil_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%Pupil measurement parameters
function edit_high_Callback(hObject, eventdata, handles)
refresh(handles)

function edit_high_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

function edit_low_Callback(hObject, eventdata, handles)
refresh(handles)

function edit_low_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

function edit_slop_Callback(hObject, eventdata, handles)
refresh(handles)

function edit_slop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

function edit_dist_Callback(hObject, eventdata, handles)
refresh(handles)

function edit_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

%%Image/video loading
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
set(handles.figure1, 'pointer', 'arrow')
guidata(hObject, handles)

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

function edit_frame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

%%Camera interface
function preview_video_Callback(hObject, eventdata, handles)
if isfield(handles, 'cam')
    closepreview(handles.cam)
end
handles.cam = videoinput('winvideo', 1);
handles.cam.ReturnedColorSpace = 'RGB';
res = handles.cam.VideoResolution;
nbands = handles.cam.NumberOfBands;
himage = image(zeros(res(2), res(1), nbands), 'Parent', handles.head_ax);
preview(handles.cam, himage);
guidata(hObject, handles)

function run_Callback(hObject, eventdata, handles)
running = get(handles.run, 'value');
recording = get(handles.record, 'value');
if running
    set(handles.run, 'string', 'Stop');
    [eye_im high low slop dist] = update_params(handles);
    interval = 0.1;
    d_over_time = [];
    t = [];
    if recording
        handles.vid_obj.FrameRate = 1/interval;
        open(handles.vid_obj);
    end
    tic
    while running
        handles.im = getsnapshot(handles.cam);
        handles.eye_im = imcrop(rgb2gray(handles.im), handles.roi);
        guidata(hObject, handles)
        d = measure_pupil(handles.eye_im, high, low, slop, dist);
        d_over_time = [d_over_time d];
        t = [t toc];
        t = t(1:length(d_over_time));
        axes(handles.time_ax)
        plot(t, d_over_time, 'b.-')
        xlabel('Time (s)')
        ylabel('Pupil Diameter (pixels)')
        refresh(handles)
        if recording
            frame.cdata = repmat(handles.eye_im, [1 1 3]);
            frame.colormap = [];
            writeVideo(handles.vid_obj, frame);
        end
        pause(interval)
        running = get(handles.run, 'value');
    end
else
    set(handles.run, 'string', 'Start')
    if recording
        close(handles.vid_obj);
    end
end

function record_Callback(hObject, eventdata, handles)
if get(handles.record, 'value')
    [f dir] = uiputfile;
    handles.vid_obj = VideoWriter([dir f]);
    guidata(hObject, handles)
end

%%Region of interest selection
function set_roi_Callback(hObject, eventdata, handles)
figure
if isfield(handles, 'cam')
    handles.im = getsnapshot(handles.cam);
end
imshow(handles.im)
r = imrect;
handles.roi = getPosition(r);
close
handles.eye_im = imcrop(rgb2gray(handles.im), handles.roi);
axes(handles.head_ax)
if isfield(handles, 'rect')
    set(handles.rect, 'Position', handles.roi);
else
    handles.rect = rectangle('Position', handles.roi, ...
                             'Linewidth', 1, ...
                             'EdgeColor', 'b');
end
guidata(hObject, handles)
refresh(handles)

%%Pupil measurement
function [eye_im high low slop dist] = update_params(handles)
high = str2num(get(handles.edit_high, 'string'));
low  = str2num(get(handles.edit_low, 'string'));
slop = str2num(get(handles.edit_slop, 'string'));
dist = str2num(get(handles.edit_dist, 'string'));
eye_im = handles.eye_im;

function refresh(handles)
[eye_im high low slop dist] = update_params(handles);

axes(handles.hist_ax)
cla
hist(double(eye_im(:)), 1:255);
axis tight
hold on
ax = axis;
plot([low low],  [ax(3) ax(4)], 'b');
plot([high high], [ax(3) ax(4)], 'b');
xlabel('Intensity')
ylabel('Frequency (# of Pixels)')
hold off

[d, im, c, e] = measure_pupil(eye_im, high, low, dist, slop);
max_dist = (1+slop)*(c.d/2);
min_dist = (1-slop)*(c.d/2);

axes(handles.pupil_circle_ax)
cla
imshow(im.pupil)
hold on
ellipse(min_dist, min_dist, 0, c.x, c.y, 'g');
ellipse(max_dist, max_dist, 0, c.x, c.y, 'g');
hold off
axis equal

axes(handles.edge_ax)
cla
imshow(im.all_edges)
hold on
ellipse(min_dist, min_dist, 0, c.x, c.y, 'g');
ellipse(max_dist, max_dist, 0, c.x, c.y, 'g');
hold off
axis equal

axes(handles.pupil_ellipse_ax)
cla
imshow(eye_im)
hold on
ellipse(e.b, e.a, e.phi, e.Y0_in, e.X0_in, 'r');
text(c.x, c.y, num2str(round(d)), 'color', 'r');
hold off
axis equal

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
if not(isnan(circ.x)) & not(isnan(circ.y))
    im.pupil(circ.y, circ.x) = 0;
end

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

if not(isempty(pupil_x)) & not(isempty(pupil_y))
    [~, nearest_neighbor] = dsearchn([pupil_y,pupil_x], [edge_y,edge_x]);
    for ii = 1:length(nearest_neighbor)
        if nearest_neighbor(ii) > dist
            all_edges(edge_y(ii), edge_x(ii)) = 0;
            im.all_edges(edge_y(ii), edge_x(ii)) = 0.6;
        end
    end
    
    [pupil_xs, pupil_ys] = find(squeeze(all_edges));
    ellipse = fit_ellipse(pupil_xs,pupil_ys);
    if isempty(ellipse) | not(strcmp(ellipse.status, '')) %could not fit ellipse
        ellipse = struct( ...
            'a',0,...
            'b',0,...
            'phi',0,...
            'X0',0,...
            'Y0',0,...
            'X0_in',0,...
            'Y0_in',0,...
            'long_axis',0,...
            'short_axis',0,...
            'status', ellipse.status);
    end
    d = max(ellipse.a, ellipse.b);
else
    d = 0;
    ellipse = struct( ...
        'a',0,...
        'b',0,...
        'phi',0,...
        'X0',0,...
        'Y0',0,...
        'X0_in',0,...
        'Y0_in',0,...
        'long_axis',0,...
        'short_axis',0,...
        'status', '');
end