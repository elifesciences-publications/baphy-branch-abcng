function LabelAxis (o, AxisHandle, index, Units, Location);
% function LabelAxis (o, AxisHandle, index, Units, Location);
%
% This function labels the x axis of plot AxisHandle with information from speech
% specified by index.
% Units can be phoneme, word or sentence. the default is phoneme.
% Location can be 'center', 'start' or 'stop' of the unit.

% Nima, December 2005

if nargin<5 Location = 'center';end
if nargin<4 Units = 'Phonemes'; end

axis tight;
duration = length(waveform(o,index)) / get(o,'SamplingRate');
xlim = get(AxisHandle, 'xlim');
xlimNorm =  xlim / duration;
SpeechUnits = get(o,Units);
events = SpeechUnits{index};
if strcmpi(Units,'Sentences')
    events(1).StartTime = duration/2;
    events(1).StopTime = duration/2;
end
for cnt1 = 1:length(events);
    if events(cnt1).StartTime < duration
        labels_note {cnt1} = events(cnt1).Note;
        switch lower(Location)
            case {'center'}
                UL = mean([events(cnt1).StartTime events(cnt1).StopTime]);
            case {'start'}
                UL = events(cnt1).StartTime;
            case {'stop'}
                UL = events(cnt1).StopTime;
        end
        labels_loc {cnt1} = max(1,min(xlim(2), UL * xlimNorm(2)));
    end
end
set(AxisHandle,'XTick',cat(1,labels_loc{:}));
set(AxisHandle,'XTickLabel',labels_note);

