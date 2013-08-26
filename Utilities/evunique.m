% function Note=evunique(events,note,trial)
%
% file all unique events that match "note" (default any) in trials
% specified by trial (default all)
%
% created SVD 2005-12-03
% 
function Note=evunique(events,note,trial)

if ~exist('note','var'),
    note='**';
end

note = upper (note);
if exist('trial','var'),
    tt=find(cat(1,events.Trial)==trial);
else
    tt=1:length(events);
end

notes=cell(length(tt),1);
[notes{:}]=deal(events(tt).Note);
notes = upper(notes);
if strcmp(note,'**'),
    tt2=1:length(notes);
elseif note(1)=='*' & note(end)=='*',
    ttfind=strfind(notes,note(2:end-1));
    tt2=[];
    for ii=1:length(ttfind),
        if ~isempty(ttfind{ii}),
            tt2=[tt2 ii];
        end
    end
elseif note(1)=='*',
    ttfind=strfind(notes,note(2:end));
    tt2=[];
    for ii=1:length(ttfind),
        if ~isempty(ttfind{ii}),
            if ttfind{ii}==(length(notes{ii})-length(note)+2),
                tt2=[tt2 ii];
            end
        end
    end
    
elseif note(end)=='*',
    tt2=strmatch(note(1:end-1),notes);
else
    tt2=find(strcmp(notes,note));
end
tt2=tt(tt2);
Note=cell(length(tt2),1);
[Note{:}]=deal(events(tt2).Note);
Note=unique(Note);