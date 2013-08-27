function [w, event]=waveform (o,index,IsRef);
% function w=waveform(t);
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
Names = get(o,'Names');
if length(Frequencies)>1
    Names = Names{index};
else
    Names= Names{1};
end
if length(Frequencies)>1
    Frequencies = Frequencies(index);
end
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end
% generate the tone
timesamples = (1 : Duration*SamplingRate) / SamplingRate;
w=zeros(size(timesamples));
tonegap = 0.3;
ScaleFactor = 80-get(o,'ScaleFactor');

w = w + sin(2*pi*Frequencies*timesamples);
% 10ms ramp at onset:
w = w(:);
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
w = 5 * w/max(abs(w));
wAll=[];
wAll = [wAll; w  / (10^(ScaleFactor(1)/20))];

for i = 2:3
    wAll = [wAll; zeros(ceil(tonegap*SamplingRate),1); w  / (10^(ScaleFactor(i)/20))];
    
end
filler=(1*SamplingRate)-length(wAll);
w = [wAll; zeros(filler,1)];
filler = filler./SamplingRate;

% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+((tonegap*2)+Duration*3)+filler,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names],...
    'StartTime',PreStimSilence+((tonegap*2)+Duration*3)+filler, 'StopTime',PreStimSilence+((tonegap*2)+Duration*3)+filler+PostStimSilence,'Trial',[]);

