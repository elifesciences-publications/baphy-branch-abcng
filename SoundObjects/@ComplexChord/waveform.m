function [w, event]=waveform(o,index,IsRef)
% function w=waveform(t);
% this function is the waveform generator for object ComplexChord
%
% created SVD 2007-03-30

event = [];
% the parameters of ComplexChord object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
Frequencies = get(o,'Frequencies');
AM = get(o,'AM');
FM = get(o,'FM');  % not activated yet
ModDepth = get(o,'ModDepth');  % modulation ModDepth
ToneIdxSet = get(o,'ToneIdxSet');
LightIdxSet=get(o,'LightIdxSet');
LightPhaseSet=get(o,'LightPhaseSet');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
Names = get(o,'Names');

% number of AMs or Frequencies (whichever is larger) controls total number of tones
if length(Frequencies)<length(AM),
    Frequencies=repmat(Frequencies(1),1,length(AM));
end

ThisChord=ToneIdxSet(index,:);
ChordCount=length(ThisChord);
FirstToneCount=length(Frequencies);
if isempty(FM),
    FM=zeros(1,FirstToneCount);
elseif length(FM)<FirstToneCount,
    FM=repmat(FM(1),1,FirstToneCount);
end
if isempty(AM),
    AM=zeros(1,FirstToneCount);
elseif length(AM)<FirstToneCount,
    AM=repmat(AM(1),1,FirstToneCount);
end
if isempty(ModDepth),
    ModDepth=ones(1,FirstToneCount);
elseif length(ModDepth)<FirstToneCount,
    ModDepth=repmat(ModDepth(1),1,FirstToneCount);
end

FirstToneAtten=get(o,'FirstToneAtten');
if isempty(FirstToneAtten),
    FirstToneAtten=zeros(1,FirstToneCount);
elseif length(FirstToneAtten)<FirstToneCount,
    FirstToneAtten=repmat(FirstToneAtten(1),1,FirstToneCount);
end

% generate the tone
timesamples = (1 : Duration*SamplingRate) / SamplingRate;
w=zeros(size(timesamples));
atten=[FirstToneAtten(ThisChord(1)) get(o,'SecondToneAtten') get(o,'ThirdToneAtten')];
atten=10.^(-atten./20);

for cnt1 = 1:length(ThisChord),
    ii=ThisChord(cnt1);
    if AM(ii)>0 && ~isempty(LightIdxSet) && sum(LightIdxSet>=0)>0,
        % full ModDepth modulation. use cosine envelope to make onset same as
        % pure tones (and same as AFM!)
        env=double(sin(pi*AM(ii).*2*timesamples)>0);
        env=conv2(env,ones(1,round(SamplingRate.*0.01))./round(SamplingRate.*0.01),'same');
        w = w + sin(2*pi*Frequencies(ii)*timesamples) .* ...
            (1-ModDepth(ii) + ModDepth(ii) .* env ./ 0.4053) .* atten(cnt1);
    elseif AM(ii)>0,
        % full ModDepth modulation. use cosine envelope to make onset same as
        % pure tones (and same as AFM!)
        w = w + sin(2*pi*Frequencies(ii)*timesamples) .* ...
            (1-ModDepth(ii) + ModDepth(ii) .* abs(sin(pi*AM(ii)*timesamples)) ./ 0.4053) .* atten(cnt1);
    elseif AM(ii)==0,
        w = w + sin(2*pi*Frequencies(ii)*timesamples) .* atten(cnt1);
    else
        % AM==-1 means no tone!
        w = w + zeros(size(timesamples));
    end
end

% 10ms ramp at onset and offset:
w = w(:);
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);

% normalize min/max to 10 dB below 5
w = 5 ./ ChordCount .* w;

% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];

if ~isempty(LightIdxSet) && sum(LightIdxSet>=0)>0,
    LightAmp=3;
    if LightIdxSet(index)==-1 || AM(LightIdxSet(index))==-1,
        w2=zeros(size(timesamples));
    elseif AM(LightIdxSet(index))>0,
        w2=(sin(2.*pi*AM(LightIdxSet(index))*...
            (timesamples+LightPhaseSet(index)./1000))>0).*LightAmp;
    else
        w2=ones(size(timesamples)).*LightAmp;
    end
    w2 = [zeros(PreStimSilence*SamplingRate,1) ; w2(:) ;zeros(PostStimSilence*SamplingRate,1)];
    w=[w w2];
end
%[index size(w) std(w)]

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
