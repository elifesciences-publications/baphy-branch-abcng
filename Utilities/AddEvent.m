function events=AddEvent(events,note,trial,starttime,stoptime)
%% function events=AddEvent(events,note,trial,starttime,stoptime);
%
% append behavior or stimulus event onto list of event timestamps during a
% trial
%
% two syntaxes:
%   events=AddEvent(events, note[string], trial[number], starttime[sec],
%                   stoptime(default=[])
%   or
%   events=AddEvent(events,neweventstruct,trial);
%
% second format is designed to be compatible with mini-event structure
% outputs of IO-commands.  eg,
% >>  events=AddEvent(events,IOControlPump(HW,'Start',1),TrialCounter)
% will turn the pump on for one second and record the start and stop times
% in the event list
%
% created SVD 2005-10
% modified SVD 2005-11-28 -- added neweventstruct syntax
% modified Nima 2005-12-7 -- new event can be an array of events, but all
% should be in the same trial.

ecount=length(events)+1;
if isstruct(events) && ~isempty(events)
 if ~isfield(events,'StopTime') events.StopTime=[]; end
 if ~isfield(events,'Trial') events.Trial =0; end
end

if isstruct(note),
    for cnt1 = 1:length(note)
        if ~isfield(note(cnt1),'StopTime'),
            note(cnt1).StopTime=[];
        end
        if ~isfield(note(cnt1),'Trial'),
            note(cnt1).Trial=0;
        end
        if ~isfield(note(cnt1),'Rove')
          note(cnt1).Rove=[];
        end
%         if  ~isfield(events,'Rove') && isfield(note(cnt1),'Rove')
%           events.Rove=[];
%         end
        if length(events)==0,
            events=note(cnt1);
        else
          FN = fieldnames(note);
          for i=1:length(FN)
            events(ecount).(FN{i}) = note(cnt1).(FN{i});
          end
        end
        events(ecount).Trial=trial;
        ecount = length(events) + 1;
    end
else
    ecount=length(events)+1;
    events(ecount).Note=note;
    events(ecount).StartTime=starttime;
    if exist('stoptime','var'),
        events(ecount).StopTime=stoptime;
    end
    events(ecount).Trial=trial;
end