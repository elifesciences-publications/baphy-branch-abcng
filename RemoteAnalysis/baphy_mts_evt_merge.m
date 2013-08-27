function evt=baphy_mts_evt_merge(events,withTORC);
if nargin<2
    withTORC=0; end
trials=max([events.Trial]);
evt=[];
for i=1:trials
    evt_tem=events(find([events.Trial]==i));
    j=1;TorcMarker=0;
    while ~strcmpi(evt_tem(j).Note,'trialstop')
        if length(findstr(evt_tem(j).Note,'$'))>0
            evt_tem(j).StopTime=evt_tem(j+3).StopTime;
            xx=strread(evt_tem(j+3).Note,'%s','delimiter',',');
            xx=deblank(xx);
            evt_tem(j).Note=strrep(evt_tem(j).Note,'$', xx{2}(5:end));
            if withTORC && TorcMarker   %merge with torc
                evt_tem(j).Note=strrep(evt_tem(j).Note,'Note', 'Torc-Note');
                evt_tem(j).StartTime=evt_tem(TorcMarker).StartTime;
            end
            evt=[evt;evt_tem(j)];
            j=j+4;
        elseif withTORC && length(findstr(evt_tem(j).Note,'Stim , TORC'))>0   %find TORC stim
            TorcMarker=j;
            if length(findstr(evt_tem(j+2).Note,'PreStimSilence'))>0
                j=j+3;   %skip post- and pre- stimsilence evts if there is a torc
            else
                j=j+1;
            end
        elseif withTORC && length(findstr(evt_tem(j).Note,'TORC'))>0 && ...
                length(findstr(evt_tem(j).Note,'target'))>0
            j=j+1;   %delete the TORC as target
        elseif withTORC && length(findstr(evt_tem(j).Note,'Stim , ferret'))>0   %find TORC stim
            TorcMarker=j;
            if length(findstr(evt_tem(j+2).Note,'PreStimSilence'))>0
                j=j+3;   %skip post- and pre- stimsilence evts if there is a torc
            else
                j=j+1;
            end
        elseif withTORC && length(findstr(evt_tem(j).Note,'ferret'))>0 && ...
                length(findstr(evt_tem(j).Note,'target'))>0
            j=j+1;   %delete the TORC as target
        else
            evt=[evt;evt_tem(j)];j=j+1;
        end
    end
    evt=[evt;evt_tem(end)];
end
for i=1:length(evt)
    evt(i).Note=strrep(evt(i).Note,' ','');   %delete space characters
end