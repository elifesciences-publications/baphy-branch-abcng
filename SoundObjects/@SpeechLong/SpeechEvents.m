function events = SpeechEvents (o, Unit, cmd);
% SpeechEvents generate the event list for specified Unit. if cmd is
% 'List', the function returns all the unit events and their count.
% examples: 
%   event = SpeechEvents (o,'Words','List');  returns the list of all words
%       sorted by their number of occurence
%   event = SpeechEvents (o,'Phonemes', 'ix'); returns the event structure
%       containing all the occurences of phoneme 'ix'

% Nima, December 2005

if strcmpi(cmd,'List')
    Units = get(o,Unit);
    events = [];
    allEvents = [];
    counter = [];
    for cnt1 = 1:length(Units)
        for cnt2 = 1:length(Units{cnt1})
            index = strfind(allEvents, ['|' Units{cnt1}(cnt2).Note '|']);
            if isempty(index)
                allEvents = [allEvents '|' Units{cnt1}(cnt2).Note '|'];
                index = strfind(allEvents, ['|' Units{cnt1}(cnt2).Note '|']);
                counter(index) = 1;
            else
                counter(index) = counter(index) + 1;
            end
        end
    end
    barIndex = strfind(allEvents, '|');
    while find(counter)
        [m,i] = max(counter);
        temp = allEvents(i:end);
        tempind = strfind(temp, '|');
        temp = temp(tempind(1)+1:tempind(2)-1);
        events(end+1).Note = temp;
        events(end).Count = counter(i);
        counter(i) = 0;
    end
    return;
end

Units = get(o,Unit);
Names = get(o,'Names');
PreStim = get(o,'PreStimSilence');
events = [];
for cnt1 = 1:length(Units)
    for cnt2 = 1:length(Units{cnt1})
        if strcmpi(Units{cnt1}(cnt2).Note, cmd)
            events(end+1).Note = Names{cnt1};
            events(end).Trial   = cnt1;
            events(end).StartTime = Units{cnt1}(cnt2).StartTime;
            events(end).StopTime = Units{cnt1}(cnt2).StopTime;
        end
    end
end
