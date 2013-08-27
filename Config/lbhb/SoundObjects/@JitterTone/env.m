function [e,event,o]=env (o,index,IsRef);
% function [e,event]=env(o);
% this function is the waveform generator for object Tone

% compatibility issue: make new Tone object (with index) compatible witht
% the rest:
if ~exist('index','var') || isempty(index)
    index = 1;
end


event = [];
% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
Frequencies = get(o,'Frequencies');
JitterOctaves = ifstr2num(get(o,'JitterOctaves'));
SplitChannels=get(o,'SplitChannels');
bSplitChannels=strcmpi(SplitChannels,'Yes');
ChordCount=get(o,'ChordCount');
ChordWidth=get(o,'ChordWidth');
Names = get(o,'Names');
if length(Frequencies)>1
    Names = Names{index};
else
    Names= Names{1};
end
if length(Frequencies)>1
    Frequencies = Frequencies(index);
end
if JitterOctaves>0,
  deltaF=rand.*JitterOctaves-(JitterOctaves./2);
  fnew=round(2.^(log2(Frequencies)+deltaF));
  %fprintf('Jittering Tone frequency from %d to %d\n',Frequencies,fnew);
  Frequencies=fnew;
end

if ChordCount>1 && ChordWidth>0,
    lfmin=log2(Frequencies)-ChordWidth./2;
    lfmax=log2(Frequencies)+ChordWidth./2;
    Frequencies=2.^linspace(lfmin,lfmax,ChordCount);
end

PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end
% generate the tone
timesamples = (1 : Duration*SamplingRate)' / SamplingRate;
e=ones(size(timesamples));

% 10ms ramp at onset:
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
e(1:length(ramp)) = e(1:length(ramp)) .* ramp;
e(end-length(ramp)+1:end) = e(end-length(ramp)+1:end) .* flipud(ramp);
% Now, put it in the silence:
e = [zeros(round(PreStimSilence*SamplingRate),1) ; 
     e(:) ;
     zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+ ...
                  Duration+PostStimSilence,'Trial',[]);

% normalize to peak amplitude of 1
e = e/max(abs(e));

if bSplitChannels && index>1,
    e=cat(2,zeros(size(e)),e);
end
