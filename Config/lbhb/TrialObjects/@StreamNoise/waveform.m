function [TrialSound, events , o] = waveform (o,TrialIndex)
% SVD 2012-10-19

par = get(o); % get the parameters of the trial object
RefObject=par.ReferenceHandle;
RefObject = set(RefObject, 'SamplingRate', par.SamplingRate);

% get the index of reference sounds for current trial
PreTrialSilence = par.PreTrialSilence;
PreTrialBins=round(PreTrialSilence.*par.SamplingRate);
PostTrialSilence = par.PostTrialSilence;
PostTrialBins=round(PostTrialSilence.*par.SamplingRate);

TrialSound = []; % initialize the waveform
events = [];
events(1).Note=['PreStimSilence , ',par.ReferenceClass,' , Reference'];
events(1).StartTime = 0;
events(1).StopTime = PreTrialSilence;
events(1).Trial = TrialIndex;

LastEvent = PreTrialSilence;

% generate the reference sound
RefTrialIndex=par.Sequences{par.SequenceIdx(TrialIndex)};
Names=get(RefObject,'Names');
for cnt1 = 1:size(RefTrialIndex,1)  % go through all the reference sounds in the trial
    for jj=1:size(RefTrialIndex,2),
        [tw,ev]=waveform(RefObject, RefTrialIndex(cnt1,jj),TrialIndex);
        if jj==1,
            w=tw;
            Note=ev(2).Note;
        else
            w=w+tw;
            Note=[Note,'+',Names{RefTrialIndex(cnt1,jj)}];
        end
    end
    
    % svd 2009-06-29 make sure that sound is in a column
    if size(w,2)>size(w,1),
        w=w';
    end
    
    % add "Reference" to the note, correct the time stamp in respect to
    % last event, and concatenate w onto TrialSound. and don't include
    % pre/post-stim silences if they're zero length
    if ev(1).StopTime-ev(1).StartTime==0,
        ev=ev(2:end);
    end
    if ev(end).StopTime-ev(end).StartTime==0,
        ev=ev(1:(end-1));
    end
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [Note ' , Reference'];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    TrialSound = [TrialSound ;w];
    events = [events ev];
end
events(end+1).Note=['PostStimSilence , ',par.ReferenceClass,' , Reference'];
events(end).StartTime = LastEvent;
events(end).StopTime = LastEvent+PostTrialSilence;
events(end).Trial = TrialIndex;

chancount=size(TrialSound,2);

TrialSound=cat(1,zeros(PreTrialBins,chancount),...
    TrialSound,zeros(PostTrialBins,chancount));


