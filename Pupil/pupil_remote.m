%%Generic Matlab GUI functions
function varargout = pupil_remote(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pupil_remote_OpeningFcn, ...
                   'gui_OutputFcn',  @pupil_remote_OutputFcn, ...
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

function pupil_remote_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = pupil_remote_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%Pupil measurement parameters
function edit_high_Callback(hObject, eventdata, handles)
refresh(hObject, handles)

function edit_high_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

function edit_low_Callback(hObject, eventdata, handles)
refresh(hObject, handles)

function edit_low_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

function edit_slop_Callback(hObject, eventdata, handles)
refresh(hObject, handles)

function edit_slop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

function edit_dist_Callback(hObject, eventdata, handles)
refresh(hObject, handles)

function edit_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

%%Video loading
function browse_Callback(hObject, eventdata, handles)
[f dir] = uigetfile({'*.mj2;*.avi','Supported Video Files (*.avi, *.mj2)'});
handles.vid_file = [dir f];
set(handles.experiment, 'String', [dir f]);
if sum(handles.vid_file) ~= 0
    guidata(hObject, handles)
    load_video(handles.vid_file, hObject, eventdata, handles);
end

function experiment_Callback(hObject, eventdata, handles)
handles.vid_file = get(handles.experiment, 'String');
guidata(hObject, handles)
load_video(handles.vid_file, hObject, eventdata, handles);

function load_video(vid_file, hObject, eventdata, handles)
handles.vid = VideoReader(vid_file);
handles.im = read(handles.vid, 1);
handles.all_d = [];
handles.excluded_frames = [];
handles.frame = 1;
handles.n_frames = get(handles.vid, 'NumberOfFrames');
n_frame_msg = sprintf('of %d', handles.n_frames);
set(handles.n_frame_msg, 'String', n_frame_msg);
set(handles.edit_frame, 'String', '1');
guidata(hObject, handles)
set_roi = questdlg('Choose a region of interest?', 'Yes', 'No');
switch set_roi
    case 'Yes'
        set_roi_Callback(hObject, eventdata, handles);
    case 'No'
        handles.roi = [1 1 size(handles.im,2)-1 size(handles.im,1)-1];
        guidata(hObject, handles)
        refresh(hObject, handles)
end

function experiment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_frame_Callback(hObject, eventdata, handles)
handles.frame = str2num(get(handles.edit_frame, 'string'));
handles.im = read(handles.vid, handles.frame);
guidata(hObject, handles)
refresh(hObject, handles)
function edit_frame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')), ...
        set(hObject,'BackgroundColor','white');
end

function set_roi_Callback(hObject, eventdata, handles)
figure
imshow(handles.im)
r = imrect;
handles.roi = getPosition(r);
close
guidata(hObject, handles)
refresh(hObject, handles)

%%Video analysis
function [high low slop dist] = update_params(handles)
high = str2num(get(handles.edit_high, 'string'));
low  = str2num(get(handles.edit_low, 'string'));
slop = str2num(get(handles.edit_slop, 'string'));
dist = str2num(get(handles.edit_dist, 'string'));

function refresh(hObject, handles)

handles.im = read(handles.vid, handles.frame);
handles.eye_im = imcrop(rgb2gray(handles.im), handles.roi);

axes(handles.head_ax)
cla
imshow(handles.im)
if isfield(handles, 'rect')
    set(handles.rect, 'Position', handles.roi);
else
    handles.rect = rectangle('Position', handles.roi, ...
                             'Linewidth', 1, ...
                             'EdgeColor', 'b');
end

[high low slop dist] = update_params(handles);

axes(handles.hist_ax)
cla
hist(double(handles.eye_im(:)), 1:255);
axis tight
hold on
ax = axis;
plot([low low],  [ax(3) ax(4)], 'b');
plot([high high], [ax(3) ax(4)], 'b');
xlabel('Intensity')
ylabel('Frequency (# of Pixels)')
hold off

[d, im, c, e] = measure_pupil(handles.eye_im, high, low, dist, slop);
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
imshow(handles.eye_im)
hold on
ellipse(e.b, e.a, e.phi, e.Y0_in, e.X0_in, 'r');
text(c.x, c.y, num2str(round(d)), 'color', 'r');
hold off
axis equal

colormap(jet)

if not(isempty(handles.all_d))
    axes(handles.time_ax)
    ax = axis;
    cla
    hold on
    plot(handles.all_d)
    plot([handles.frame handles.frame], [ax(3) ax(4)], 'k')
    plot(handles.excluded_frames, handles.all_d(handles.excluded_frames), 'ro')
    hold off
    axis tight
end

function analyze_video_Callback(hObject, eventdata, handles)
global STOPPED
set(handles.stop, 'Value', 0);
STOPPED = 0;
handles.excluded_frames = [];
[high low slop dist] = update_params(handles);
all_d = zeros(handles.n_frames,1);
axes(handles.time_ax)
for frame = 1:handles.n_frames
    im = read(handles.vid, frame);
    eye_im = imcrop(rgb2gray(im), handles.roi);
    d = measure_pupil(eye_im, high, low, dist, slop);
    all_d(frame) = d;
    plot(1:frame, all_d(1:frame))
    xlabel('Frame')
    ylabel('Pupil Diameter (Pixels)')
    drawnow
    if STOPPED
        break
    end
end
set(handles.frame_slider, ...
    'Max', frame, ...
    'SliderStep', [1 1]./(frame-1), ...
    'Value', frame);
handles.all_d = all_d(1:frame);
handles.frame = frame;
set(handles.edit_frame, 'String', num2str(frame));
axis tight
guidata(hObject, handles)
refresh(hObject, handles)

function frame_slider_Callback(hObject, eventdata, handles)
handles.frame = round(get(handles.frame_slider, 'Value'));
set(handles.edit_frame, ...
    'Value', handles.frame, ...
    'String', num2str(handles.frame));
guidata(hObject, handles)
refresh(hObject, handles)

function frame_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function exclude_frame_Callback(hObject, eventdata, handles)
f = handles.frame;
handles.excluded_frames = [handles.excluded_frames f];
switch f
    case 0
        handles.all_d(f) = handles.all_d(f+1);
    case handles.n_frames
        handles.all_d(f) = handles.all_d(f-1);
    otherwise
        handles.all_d(f) = mean([handles.all_d(f-1) handles.all_d(f+1)]);
end
guidata(hObject, handles)
refresh(hObject, handles)

function stop_Callback(hObject, eventdata, handles)
global STOPPED
STOPPED = get(handles.stop, 'Value');

function save_pupil_data_Callback(hObject, eventdata, handles)
f_default = [handles.vid_file(1:end-4) '.pup.mat'];
f_user = inputdlg('Save to:', 'Save Pupil Data', 1, {f_default});
f = f_user{1};
[params.high params.low params.slop params.dist] = update_params(handles);
pupil_data = struct(...
    'vid_file', handles.vid_file, ...
    'pupil_diameter', handles.all_d, ...
    'excluded_frames', handles.excluded_frames, ...
    'params', params);
save(f, 'pupil_data');