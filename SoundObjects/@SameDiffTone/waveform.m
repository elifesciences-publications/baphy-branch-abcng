function [w, event, Levels]=waveform (o,index,IsRef);
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
tonegap = get(o,'ToneGap')*SamplingRate;

w = w + sin(2*pi*Frequencies*timesamples);
% 10ms ramp at onset:
w = w(:);
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
w = 5 * w/max(abs(w));
SD = get(o,'SameDiff');
if isempty(SD)
    SD = 'ss';
end

Levels=[];
switch SD(1,1)
    case 's'
        ScaleFactor = 80-(get(o,'Pedestal')-(get(o,'LevelDiff')/2));
        wAll=w / (10^(ScaleFactor/20));
        Levels = get(o,'Pedestal')-(get(o,'LevelDiff')/2);
    case 'S'
        ScaleFactor = 80-(get(o,'Pedestal')+(get(o,'LevelDiff')/2));
        wAll=w / (10^(ScaleFactor/20));
        Levels = get(o,'Pedestal')+(get(o,'LevelDiff')/2);
    case 'd'
        ScaleFactor = 80-(get(o,'Pedestal')-(get(o,'LevelDiff')/2));
        wAll=w / (10^(ScaleFactor/20));
        Levels = get(o,'Pedestal')-(get(o,'LevelDiff')/2);
        
    case 'D'
        ScaleFactor = 80-(get(o,'Pedestal')+(get(o,'LevelDiff')/2));
        wAll=w / (10^(ScaleFactor/20));
        Levels = get(o,'Pedestal')+(get(o,'LevelDiff')/2);
        
end

switch SD(1,2)
    case 's'
        ScaleFactor = 80-(get(o,'Pedestal')-(get(o,'LevelDiff')/2));
        wAll= [wAll; zeros(tonegap,1); w / (10^(ScaleFactor/20))];
        Levels = [Levels; get(o,'Pedestal')-(get(o,'LevelDiff')/2)];
        
    case 'S'
        ScaleFactor = 80-(get(o,'Pedestal')+(get(o,'LevelDiff')/2));
        wAll= [wAll; zeros(tonegap,1); w / (10^(ScaleFactor/20))];
        Levels = [Levels; get(o,'Pedestal')+(get(o,'LevelDiff')/2)];
        
    case 'd'
        ScaleFactor = 80-(get(o,'Pedestal')-(get(o,'LevelDiff')/2));
        wAll= [wAll; zeros(tonegap,1); w / (10^(ScaleFactor/20))];
        Levels = [Levels; get(o,'Pedestal')-(get(o,'LevelDiff')/2)];
        
    case 'D'
        ScaleFactor = 80-(get(o,'Pedestal')+(get(o,'LevelDiff')/2));
        wAll= [wAll; zeros(tonegap,1); w / (10^(ScaleFactor/20))];
        Levels = [Levels; get(o,'Pedestal')+(get(o,'LevelDiff')/2)];
        
end

w = wAll;
% figure(100)
% plot(w)
% pause
% close(100)

% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration+get(o,'ToneGap')+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+get(o,'ToneGap')+Duration+PostStimSilence,'Trial',[]);

