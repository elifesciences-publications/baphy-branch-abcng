function pupil_start_recording(hObject, handles)

global MG

f = get(handles.video_file, 'String');

if isfield(MG, 'video')
    close(MG.video)
end

%Create a new video object
MG.video = VideoWriter(f, 'Archival');
%MG.video = VideoWriter(f);
guidata(hObject, handles);

%Start recording
MG.recording=1;
MG.frames_written=0;
open(MG.video);
while MG.recording
    MG.im = getsnapshot(MG.cam);
    %Crop out everything but the eye
    frame.cdata = imcrop(MG.im, MG.roi);
    frame.colormap = [];
    %Save video
    writeVideo(MG.video, frame);
    %Save a timestamp
    MG.timestamp = now;
    MG.frames_written=MG.frames_written+1;
    if get(MG.Stim.TCPIP,'BytesAvailable'),
        M_Pupil_TCPIP(MG.Stim.TCPIP);
    end
    
    drawnow;
end
close(MG.video);