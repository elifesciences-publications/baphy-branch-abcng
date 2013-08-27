function [w, ev]=waveform (o,index, IsRef)
% function w=waveform(t);
% this function is the waveform generator for object FrequencyTuning


SamplingRate = ifstr2num(get(o,'SamplingRate'));
PreStimSilence = ifstr2num(get(o,'PreStimSilence'));
PostStimSilence = ifstr2num(get(o,'PostStimSilence'));

% the parameters of tone object
SamplingRate = ifstr2num(get(o,'SamplingRate'));
Duration = ifstr2num(get(o,'Duration')); % duration is second
Names = get(o,'Names');
Frequency = ifstr2num(Names{index});
% if its a multiple tone (not simultaneous), generate them here:
NumberOfTones = get(o,'NumberOfTones');
if NumberOfTones==1,
    % now generate a tone with specified frequency:
    t = Tone(SamplingRate, 0, get(o,'PreStimSilence'), get(o,'PostStimSilence'), ...
        Frequency, Duration);
    [w, ev] = waveform(t);
    clear t;
else
    w=[];ev=[];
%     Gap = get(o,'GapDuration');
    Gap = .5/(NumberOfTones/Duration);
    dur = (Duration-Gap*(NumberOfTones-1))/NumberOfTones;
    LastTimeStamp = 0;
    for cnt1=1:NumberOfTones
        if cnt1==1,
            pre = PreStimSilence;
            pos = Gap;
        elseif cnt1==NumberOfTones
            pre = 0;
            pos = PostStimSilence;
        else
            pre = 0;
            pos = Gap;
        end
        t = Tone(SamplingRate, 0, pre, pos, ...
            Frequency, dur);
        [wt, evt] = waveform(t);
        w = [w ;wt];
        for cnt2 = 1:length(evt);
            evt(cnt2).StartTime = evt(cnt2).StartTime + LastTimeStamp;
            evt(cnt2).StopTime  = evt(cnt2).StopTime  + LastTimeStamp;
        end
        LastTimeStamp = evt(end).StopTime;
        ev = [ev evt];
        clear t;
    end
    % IMPORTANT: to match the compatibility with behavior, I am chaning the
    % random tone to produce only one event, like we have just one tone
    % insteat of tone pips. they can be still recover from the other
    % parameters
    evtemp = ev(2);
    evtemp.StopTime = ev(end-1).StopTime;
    ev = [ev(1) evtemp ev(end)];
end
w = 5 * w/max(abs(w));