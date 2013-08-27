function StopExperiment = CanStart (o, HW, StimEvents, globalparams, exptparams, TrialIndex)
% CanStart for ReferenceAvoidance
% We wait until the animal does not lick for at least NoResponseTime

global StopExperiment  % records if user pressed "Stop" in RefTarGui

% turn on the light if its needed:
if strcmpi(get(o,'TurnOffLight'),'Ineffective')
    ev = IOLightSwitch(HW,1);
end

if 0 && TrialIndex==1
    PumpDuration = 2*get(o,'PumpDuration');
    tic;  %added by pby
    IOControlPump (HW,'start',PumpDuration);
    pause(PumpDuration);
    if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive')
        IOLightSwitch (HW, 1);
    end
    pause(1);
end

% figure out neutral delay (if any)
if isfield(exptparams,'NeutralPreTrialDelay'),
    NeutralDelay=exptparams.NeutralPreTrialDelay;
else
    NeutralDelay=0;
end

% variable no lick time
NoLickTime=get(o,'NoResponseTimeFixed') + random('exp',get(o,'NoResponseTimeVar'));

% set up sound to play during neutral delay and NoLickTime
% (if ReferenceDuringPreTrial=='Yes')
RefCounter=0;
TrialObject=exptparams.TrialObject;
TrialObjectParms=get(TrialObject);
BehaviorParms=get(o);

% figure out which AO channel is playing common targets
if isfield(HW.AO,'NumChannels'),
   AOChannels=HW.AO.NumChannels;
   if AOChannels>1,
      ChannelNames=strsep(HW.AO.Names,',',1);
      AOChannelOrder=zeros(AOChannels,1);
      for ii=1:AOChannels,
         tc=find(strcmp(['SoundOut',num2str(ii)],ChannelNames));
         if ~isempty(tc),
            AOChannelOrder(ii)=tc;
         else
            AOChannelOrder(ii)=ii;
         end
      end
      if isfield(TrialObjectParms,'TargetIdxFreq') && isfield(TrialObjectParms,'TargetChannel'),
         CommonTarget=find(TrialObjectParms.TargetIdxFreq==max(TrialObjectParms.TargetIdxFreq),1);
         if CommonTarget>length(TrialObjectParms.TargetChannel),
            CommonTarget=AOChannelOrder(1);
         else
            CommonTarget=AOChannelOrder(TrialObjectParms.TargetChannel(CommonTarget));
         end
      else
         CommonTarget=1;
      end
   else
      CommonTarget=1;
   end
else
   CommonTarget=1;
end

if strcmpi(BehaviorParms.Light1,'OnTarget1Blocks') && CommonTarget==1,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light');
elseif strcmpi(BehaviorParms.Light2,'OnTarget1Blocks') && CommonTarget==1,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light2');
elseif strcmpi(BehaviorParms.Light3,'OnTarget1Blocks') && CommonTarget==1,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light3');
elseif strcmpi(BehaviorParms.Light1,'OnTarget2Blocks') && CommonTarget==2,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light');
elseif strcmpi(BehaviorParms.Light2,'OnTarget2Blocks') && CommonTarget==2,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light2');
elseif strcmpi(BehaviorParms.Light3,'OnTarget2Blocks') && CommonTarget==2,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light3');
end

if strcmpi(get(o,'ReferenceDuringPreTrial'),'Yes'),
   TrialObjectName=TrialObjectParms.descriptor;
   TrialFs=get(TrialObject,'SamplingRate');
   RefSet={};
   RefLen=[];
   if strcmpi(TrialObjectName,'TwoStreamRefTar'),
      TrialObject=set(TrialObject,'RelativeTarRefdB',-100);
      TrialObject=set(TrialObject,'PostTrialSilence',0);
      NumberOfTrials=get(TrialObject,'NumberOfTrials');
      while sum([0 RefLen])<NeutralDelay+NoLickTime.*2,
         RefCounter=RefCounter+1;
         RefSet{RefCounter}=waveform(TrialObject,ceil(rand.*NumberOfTrials));
         RefLen(RefCounter)=length(RefSet{RefCounter})./TrialFs;
      end
   else
      RefObject=get(TrialObject,'ReferenceHandle');
      RefMaxIdx=get(RefObject,'MaxIndex');
      RefFs=TrialFs;
      RefObject=set(RefObject,'SamplingRate',RefFs);
      while sum([0 RefLen])<NeutralDelay+NoLickTime.*2,
         RefCounter=RefCounter+1;
         RefSet{RefCounter}=waveform(RefObject,ceil(rand.*RefMaxIdx));
         RefLen(RefCounter)=length(RefSet{RefCounter})./TrialFs;
      end
   end
end  

% 
ClearSound=zeros(11000,1);
%IOStopSound(HW);
HW = IOLoadSound(HW, ClearSound);
IOStartSound(HW);
pause(0.1);
IOStopSound(HW);

NeutralDelayComplete=0;
if NeutralDelay>0,
    fprintf('Waiting fixed time (%.2f sec)\n',NeutralDelay);
end
NoLickTimeComplete=0;
RefIdx=0;
NextRefStart=-1;
tic;
NoLickStartTime=clock;
while ~NoLickTimeComplete && ~StopExperiment,
    if RefCounter && toc>NextRefStart,
        RefIdx=RefIdx+1;
        if RefIdx>RefCounter,
            RefIdx=1;  % loop around to first reference when depleted
        end
        IOStopSound(HW);
        HW = IOLoadSound(HW, RefSet{RefIdx});
        IOStartSound(HW);
        NextRefStart=toc+RefLen(RefIdx);
    end
    if ~NeutralDelayComplete,
        if toc>NeutralDelay,
            NeutralDelayComplete=1;
            NoLickStartTime=clock;
            fprintf('Waiting for no response time (%.2f sec)\n',NoLickTime);
        end
    else
        if IOLickRead(HW)
            % if animal licks, reset the timer
            NoLickStartTime = clock;
        end
        if etime(clock,NoLickStartTime)>NoLickTime
            NoLickTimeComplete=1;
        end
    end
    drawnow
end

if RefCounter,
    % make sure pre trial sound has stopped playing
    IOStopSound(HW);
end
