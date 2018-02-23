function [w,ev,o] = waveform(o,index,IsRef,Mode,TrialTotal)
% index = [Tar or Ref] = channel where to put the probe
% YB/JN, 2017/09
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
ClickWidth           = get(o,'ClickWidth');
SamplingRate = get(o,'SamplingRate');
ChannelNb = get(o,'ChannelNumber');
MeanICI    = get(o,'MeanICI'); StdICI = get(o,'StdICI');
ClickCloudMinDuration = get(o,'ClickCloudMinDuration');
ClickCloudMaxDuration    = get(o,'ClickCloudMaxDuration');
ClickCloudMeanDuration    = get(o,'ClickCloudMeanDuration');
CCDurationBin    = get(o,'CCDurationBin');
BlockCondition    = get(o,'BlockCondition');

if ~isempty(get(o,'CuedChannel'))
    index = str2num(get(o,'CuedChannel'));
elseif BlockCondition~=0
    if mod( ceil(TrialTotal/BlockCondition) ,2) == 1
        index = str2num(get(o,'TargetChannel'));
    else
        index = mod(str2num(get(o,'TargetChannel')),2)+1;
    end
end
ev = [];
w = zeros(round(PreStimSilence * SamplingRate),ChannelNb);
ev     = AddEvent(ev,['PreStimSilence - ' num2str(index)],[],0,PreStimSilence);

%% GENERATE CLICK CLOUD
% Click Cloud duration
if ~ClickCloudMinDuration==ClickCloudMeanDuration
    [CCDuration] = PoissonProcessPsychophysics(ClickCloudMeanDuration-ClickCloudMinDuration,...
        ClickCloudMaxDuration-ClickCloudMinDuration,1,[],CCDurationBin);
    CCDuration = CCDuration+ClickCloudMinDuration;
else
    CCDuration = ClickCloudMeanDuration;
end
% Click timings
wAllChannels = [];
flag = -1;
for ChannelNum = 1:ChannelNb
    wSingleChannel = zeros(round(CCDuration*SamplingRate),1);
    CT = max([0.03 normrnd(MeanICI,StdICI)]);
    while CT < (CCDuration-ClickWidth)
        if flag==-1; flag = 1; else flag = -1; end
        wSingleChannel( round(CT*SamplingRate) + (1:round(ClickWidth*SamplingRate))) = flag;
        ev = AddEvent(ev,['Click - ' num2str(ChannelNum)],[],PreStimSilence+CT,PreStimSilence+CT+ClickWidth);
        CT = CT+normrnd(MeanICI,StdICI);
    end
    wAllChannels = [wAllChannels wSingleChannel];
end
w = [w ; wAllChannels];
ev = AddEvent(ev,['ClickCloud - ' num2str(index)],[],PreStimSilence,PreStimSilence+CCDuration);

%% GENERATE THE PROBE
switch get(o,'ProbeSound')
    case {'TORC '}
        TorcDur = get(o,'ProbeDuration');
        TORCPreStimSilence = 0;
        TORCPostStimSilence = 0;
        TorcFreq = 'V:500-16000 Hz';
        TorcRates = '4:4:48';
        TorcObj = Torc(SamplingRate,0, ...                    % No Loudness
            TORCPreStimSilence,TORCPostStimSilence,TorcDur, TorcFreq, TorcRates);
        P = waveform(TorcObj,1);        
end
ProbeW = zeros(length(P),ChannelNb);
ProbeW(:,index) = P;
if ~isempty(get(o,'RefTarRel_dB')) && str2num(get(o,'RefTarRel_dB'))~=0  && index~=str2num(get(o,'TargetChannel'))
  global LoudnessAdjusted; LoudnessAdjusted  = 1;
  NormFactor = maxLocalStd([w(:,index);ProbeW(:,index)],SamplingRate,.1);
  RatioToDesireddB = 10^(-str2num(get(o,'RefTarRel_dB'))/20);   % dB to ratio in SPL
  ProbeW(:,index) = ProbeW(:,index)*RatioToDesireddB/NormFactor;
  w = w/NormFactor;
end
w = [w ; ProbeW];

ev     = AddEvent(ev,['Probe - ' num2str(index)],[],ev(end).StopTime,ev(end).StopTime+get(o,'ProbeDuration'));
w = [w ; zeros(round(PostStimSilence * SamplingRate),ChannelNb)];
ev     = AddEvent(ev,['PostStimSilence - ' num2str(index)],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);

