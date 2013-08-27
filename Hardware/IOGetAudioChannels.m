% function AudioChannels=IOGetAudioChannels(HW)
%
% returns indices of analog out channels with Names starting with "Sound"
%
% created SVD 2012-11-29
%
function AudioChannels=IOGetAudioChannels(HW)

if ~strcmpi(IODriver(HW),'NIDAQMX'),
    % backwards compatibility.  Assume just single audio channel for
    % systems using DAQ toolbox interface
    AudioChannels=1;
    return;
end

% get names assigned to HW.AO in IntializeHW
Names=strsep(HW.AO(1).Names,',',1);

% find out which ones start with "Sound"
ChanCount=length(Names);
AudioChannels=[];
for ii=1:ChanCount,
    if strcmpi(Names{ii}(1:5),'Sound'),
        AudioChannels=cat(2,AudioChannels,ii);
    end
end
