

parmfile='L:\Chanterelle\chn065\chn065c05_p_VOC';

% load spike data, exptevents gets loaded for free along the way

options=struct;
options.rasterfs=100;
options.includeprestim=1;
options.channel=2;
[r,tags,trialset,exptevents]=loadevpraster(parmfile,options);
% trialset is a 40x2 matrix that maps the trial number for each row of
% the raster


% Goal:
% 1. assign a pupil diameter to each trial (maybe average of last 2
% seconds)
% 2. sort repetitions of r according to pupil diameter


% find Pupil log events
[t,trial,PupilNote,toff,EventIndex] = evtimes(exptevents,'PUPIL*');

trialduration=zeros(size(trial));
trialstarttime=zeros(size(trial));
for ii=1:length(trial),
    % this trial's start info
    nn=strsep(PupilNote{ii},',');
    % dumb hack to parse note string properly
    timestamp=eval([nn{2} ']']);
    framecount=eval(['[' nn{3}]);
    
    fprintf('trial %d start: Pupil client reports time %s, framecount %d\n',...
        trial(ii),datestr(timestamp),framecount);
    
    if ii<length(trial),
        nn=strsep(PupilNote{ii+1},',');
        % dumb hack to parse note string properly
        timestamp2=eval([nn{2} ']']);
        framecount2=eval(['[' nn{3}]);
        
        trialduration(ii)=timestamp2-timestamp;
        trialframes(ii)=framecount2-framecount;
        fprintf('this trial: %s , frames: %d\n',...
            datestr(trialduration(ii)),trialframes(ii));
    end

end