function [e,event]=env(o,index,IsRef)
% function w=env(o, index,IsRef);
%
% generate envelope for SpNoise object
%
global SPNOISE_EMTX

LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
RelAttenuatedB=get(o,'RelAttenuatedB');
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
TonesPerBurst=get(o,'TonesPerBurst');
Names = get(o,'Names');
BaseSound=strtrim(get(o,'BaseSound'));
Subsets = get(o,'Subsets');
BaselineFrac=get(o,'BaselineFrac');

EnvVarName=[BaseSound,num2str(Subsets)];
%emtx = get(o,'emtx');
emtx = SPNOISE_EMTX.(EnvVarName);

SamplingRateEnv = get(o,'SamplingRateEnv');
UseBPNoise=get(o,'UseBPNoise');
BandCount=get(o,'BandCount');
StreamCount=get(o,'StreamCount');
idxset=get(o,'idxset');
streamset=get(o,'streamset');
ShuffledOnsetTimes=get(o,'ShuffledOnsetTimes');

timesamples = (1 : round(Duration*SamplingRate))' / SamplingRate;
e=zeros(length(timesamples),BandCount);

% force same carrier signal each time!!!!
saveseed=rand('seed');
rand('seed',index*20);

if isempty(RelAttenuatedB) || length(RelAttenuatedB)<StreamCount,
   RelAttenuatedB=zeros(StreamCount,1);
end

for bb=1:BandCount,
   tw=zeros(size(e));
   
   % extract appropriate envelope and resample to match desired output fs
   streamidx=streamset(index,bb);
   sp=emtx(:,idxset(index,streamidx));
   sp=sp(1:find(~isnan(sp), 1, 'last' ));
   % repeat envelope if Duration longer than orginal waveform
   % (3-sec, typically)
   segrepcount=ceil(Duration ./ (length(sp)./SamplingRateEnv));
   sp=repmat(sp,[segrepcount 1]);
   if ShuffledOnsetTimes(index,streamidx)>0,
      sp=shift(sp,round(ShuffledOnsetTimes(index,streamidx)*SamplingRateEnv));
   end
   if BaselineFrac>0 && BaselineFrac<1,
      sp=sp./(1-BaselineFrac) + BaselineFrac;
   end
   sp=resample(sp,SamplingRate,SamplingRateEnv);
   
   % make sure envelope and noise have same duration
   if length(sp)<length(tw),
      disp('desired Duration too long, trimming!!!');
      [length(sp) length(tw)]
      tw=tw(1:length(sp));
   elseif length(sp)>length(tw),
      sp=sp(1:length(tw));
   end
   
   % apply envelope
   tw=sp(:);
   
   % adjust level relative to other bands
   level_scale=10.^(-RelAttenuatedB(streamidx)./20);
   e(:,bb)=tw.*level_scale;
   
   % 10ms ramp at onset and offset:
   ramp = hanning(round(.01 * SamplingRate*2));
   ramp = ramp(1:floor(length(ramp)/2));
   e(1:length(ramp),bb) = e(1:length(ramp),bb) .* ramp;
   e(end-length(ramp)+1:end,bb) = e(end-length(ramp)+1:end,bb) .* flipud(ramp);
end

e=e./max(abs(e(:)));

% Now, put it in the silence:
e = [zeros(PreStimSilence*SamplingRate,BandCount) ; e ;zeros(PostStimSilence*SamplingRate,BandCount)];

% generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

% return random seed to previous state
rand('seed',saveseed);


