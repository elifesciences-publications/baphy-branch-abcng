function [w,event]=waveform (o,index,IsRef)
% function w=waveform(o, index,IsRef);
%
% generate waveform for SpNoise object
%
global SPNOISE_EMTX

LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
RelAttenuatedB=get(o,'RelAttenuatedB');
SplitChannels=get(o,'SplitChannels');
bSplitChannels=strcmpi(SplitChannels,'Yes');
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
IterateStepMS=get(o,'IterateStepMS');
IterationCount=get(o,'IterationCount');
TonesPerBurst=get(o,'TonesPerBurst');
Names = get(o,'Names');
SamplingRateEnv = get(o,'SamplingRateEnv');
UseBPNoise=get(o,'UseBPNoise');
BaseSound=strtrim(get(o,'BaseSound'));
Subsets = get(o,'Subsets');
BaselineFrac=get(o,'BaselineFrac');
idxset=get(o,'idxset');
ShuffledOnsetTimes=get(o,'ShuffledOnsetTimes');
SingleBandFrac=get(o,'SingleBandFrac');

EnvVarName=[BaseSound,num2str(Subsets)];
%emtx = get(o,'emtx');
emtx = SPNOISE_EMTX.(EnvVarName);

timesamples = (1 : round(Duration*SamplingRate))' / SamplingRate;
w=zeros(size(timesamples));

% force same carrier signal each time!!!!  preserve same carrier for
% single-band versions but keep backward compatible with previous
if SingleBandFrac>0,
   % figure out idxs of component bands
   rseed=idxset(find(idxset(1:index,1)>0, 1, 'last' ),1);
else
   rseed=index;
end
saveseed=rand('seed');
savenseed=randn('seed');
rand('seed',rseed*20);
randn('seed',rseed*20);

if isempty(RelAttenuatedB) || length(RelAttenuatedB)<length(LowFreq),
  RelAttenuatedB=zeros(size(LowFreq));
end

bandcount=min([length(HighFreq),length(LowFreq),length(RelAttenuatedB)]);

if length(IterateStepMS)<bandcount,
   IterateStepMS=repmat(IterateStepMS(1),[1 bandcount]);
end
if length(IterationCount)<bandcount,
   IterationCount=repmat(IterationCount(1),[1 bandcount]);
end

for bb=1:bandcount,
    if UseBPNoise,
       % use Utility to make consistent across sound objects
        tw=BandpassNoise(LowFreq(bb),HighFreq(bb),Duration,SamplingRate);
        mm=max(abs(tw));
        if IterateStepMS(bb),
           IterateGain=1;
           IterateStepSize=round(IterateStepMS(bb)./1000.*SamplingRate);
           for ii=1:IterationCount(bb),
              tw=tw+shift(tw,IterateStepSize).*IterateGain;
           end
           tw=tw./max(abs(tw)).*mm;
        end
        
        if length(tw)>size(w,1),
            disp('trimming');
            tw=tw(1:size(w,1));
        elseif length(tw)<size(w,1),
            disp('padding');
            tw(end+1:size(w,1))=0;
        end
        
    else
        tw=zeros(size(w,1),1);
        if TonesPerBurst(bb)==1,
            lfrange=mean(log([LowFreq(bb) HighFreq(bb)]));
        else
            lfrange=linspace(log(LowFreq(bb)),log(HighFreq(bb)),TonesPerBurst(bb));
        end
        
        % add a bunch of tones at random phase
        for lf=lfrange,
            phase=rand* 2.*pi;
            tw = tw + sin(2*pi*round(exp(lf))*timesamples+phase);
        end
    end
    
    tw=tw./max(abs(tw(:)));
    
    % extract appropriate envelope and resample to match desired output fs
    if idxset(index,bb)>0
       sp=emtx(:,idxset(index,bb));
    else
       sp=zeros(size(emtx(:,1)));
    end
    sp=sp(1:find(~isnan(sp), 1, 'last' ));
    % repeat envelope if Duration longer than orginal waveform
    % (3-sec, typically)
    segrepcount=ceil(Duration ./ (length(sp)./SamplingRateEnv));
    sp=repmat(sp,[segrepcount 1]);
    if ShuffledOnsetTimes(index,bb)>0,
        sp=shift(sp,round(ShuffledOnsetTimes(index,bb)*SamplingRateEnv));
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
    tw=tw.*sp;
    
    if SingleBandFrac && max(abs(tw))>0,
       tw=tw./max(abs(tw));
    end
    
    % adjust level relative to other bands
    level_scale=10.^(-RelAttenuatedB(bb)./20);
    if bSplitChannels && bb>1,
        w=cat(2,w,tw.*level_scale);
    else
        w=w+tw.*level_scale;
    end
end

w=w./max(abs(w(:)));
chancount=size(w,2);

% 10ms ramp at onset and offset:
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
ramp=repmat(ramp,[1,chancount]);
w(1:length(ramp),:) = w(1:length(ramp),:) .* ramp;
w(end-length(ramp)+1:end,:) = w(end-length(ramp)+1:end,:) .* flipud(ramp);

% normalize min/max +/-5
w = 5 ./ max(abs(w(:))) .* w;

% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,chancount) ; 
    w ; zeros(PostStimSilence*SamplingRate,chancount)];

% generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

% return random seed to previous state
rand('seed',saveseed);
randn('seed',savenseed);
