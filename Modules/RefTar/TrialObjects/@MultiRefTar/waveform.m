function [TrialSound, events , o] = waveform (o,TrialIndex)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. This is a generic script
% that works for all passive cases, all active cases that use a standard
% SoundObject (e.g. tone). You can overload it by writing your own waveform.m
% script and copying it in your object's folder.

% Nima Mesgarani, October 2005

global SPNOISE_EMTX BAPHY_LAB

par = get(o); % get the parameters of the trial object
RefObject = par.ReferenceHandle; % get the reference handle
TarObject = par.TargetHandle; % getthe target handle
RefSamplingRate = ifstr2num(get(RefObject,'SamplingRate'));
TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));

TarTrialIndex=[];
if (par.NumberOfTarPerTrial~=0) && ~strcmpi(par.TargetClass,'none')
    TarTrialIndex = par.TargetIndices{TrialIndex};
    if isempty(TarTrialIndex)  % if its a Sham
        % this means there is a target but this trial is sham. ALthough
        % there is no target, we need to adjust the amplitude based on
        % RefTardB.
        %TarObject = -1;
    end
end
CatchTrialIndex=par.CatchIndices{TrialIndex};

TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
OverlapRefTar=strcmpi(par.OverlapRefTar,'Yes');

refpar=get(RefObject);
rpre=get(RefObject,'PreStimSilence');
rdur=get(RefObject,'Duration');
rpos=get(RefObject,'PostStimSilence');

% get the index of reference sounds for current trial
RefTrialIndex = par.ReferenceIndices{TrialIndex};
if ~isempty(par.SingleRefSegmentLen) && par.SingleRefSegmentLen>0,
    if OverlapRefTar && ~isempty(TarTrialIndex),
        TarStartTime=(par.SingleRefDuration(TrialIndex)+...
          get(RefObject,'PreStimSilence'));
        TarStartBin=round(TarStartTime.*TrialSamplingRate);
        AdjustRefDur=par.SingleRefDuration(TrialIndex)+get(TarObject,'Duration')+...
            get(TarObject,'PreStimSilence')+get(TarObject,'PostStimSilence');
    else
        AdjustRefDur=par.SingleRefDuration(TrialIndex);
    end
else
    if OverlapRefTar,
        TarStartTime=(rpre+rdur+rpos).*(length(RefTrialIndex)-1);
    else
        TarStartTime=(rpre+rdur+rpos).*length(RefTrialIndex);
    end
    TarStartBin=round(TarStartTime.*TrialSamplingRate)+1;
    AdjustRefDur=get(RefObject,'Duration');
end
PostTrialSilence = par.PostTrialSilence;
PostTrialBins=round(PostTrialSilence.*TrialSamplingRate);

TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;
TarMatchContour=strcmpi(par.TargetMatchContour,'Yes');

% generate the reference sound
refenv=[];

% go through all the reference sounds in the trial
for cnt1 = 1:length(RefTrialIndex)
    if get(RefObject,'Duration')==AdjustRefDur,
        % simple case: Reference duration matches what we want it to be
        [w,ev]=waveform(RefObject, RefTrialIndex(cnt1),TrialIndex);
        % svd 2009-06-29 make sure that sound is in a column
        if size(w,2)>size(w,1),
            w=w';
        end
    else
        CumRefDur=0;
        fs=get(RefObject,'SamplingRate');
        RefObject=set(RefObject,'PostStimSilence',0);
        rcount=0;
        w=[];ev=[];
        while CumRefDur<AdjustRefDur,
            if get(RefObject,'Duration')>AdjustRefDur-CumRefDur,
                RefObject=set(RefObject,'Duration',AdjustRefDur-CumRefDur);
            end
            %fprintf('Adding ref seg %.2f sec\n',get(RefObject,'Duration'));
            [tw,tev]=waveform(RefObject, RefTrialIndex(cnt1),TrialIndex);
            CumRefDur=CumRefDur+get(RefObject,'Duration');
            
            % svd 2009-06-29 make sure that sound is in a column
            if size(tw,2)>size(tw,1),
                tw=tw';
            end
            w=cat(1,w,tw);
            if TarMatchContour && ismethod(RefObject,'env'),
              te=env(RefObject, RefTrialIndex(cnt1));
              refenv=cat(1,refenv,te);
            end
            if isempty(ev),
                ev=tev;
            else
                t0=ev(end).StopTime;
                for ii=1:length(tev),
                    tev(ii).StartTime=tev(ii).StartTime+t0;
                    tev(ii).StopTime=tev(ii).StopTime+t0;
                end
                ev=cat(2,ev,tev);
            end
            RefObject=set(RefObject,'PreStimSilence',0);
        end
        w=cat(1,w,zeros(round(rpos.*fs),size(w,2)));
        ev(end).StopTime=ev(end).StopTime+rpos;
    end
  % add "Reference" to the note, correct the time stamp in respect to
  % last event, and concatenate w onto TrialSound
  for cnt2 = 1:length(ev)
    ev(cnt2).Note = [ev(cnt2).Note ' , Reference'];
    ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
    ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
    ev(cnt2).Trial = TrialIndex;
  end
  LastEvent = ev(end).StopTime;
  TrialSound = [TrialSound ;w];
  events = [events ev];
end

TrialSound0=TrialSound;
chancount=size(TrialSound,2);
if ~isempty(TarTrialIndex)
    ThisTarIdx = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
else
    ThisTarIdx = par.TargetIndices{1};
end

TargetChannel=par.TargetChannel;
if isempty(TargetChannel),
  TargetChannel=1;
elseif length(TargetChannel)<TargetChannel,
  TargetChannel=TargetChannel(1);
else
  TargetChannel=TargetChannel(ThisTarIdx);
end

RelativeTarRefdB=par.RelativeTarRefdB;
if isempty(RelativeTarRefdB),
  RelativeTarRefdB=0;
elseif length(RelativeTarRefdB)<ThisTarIdx,
  RelativeTarRefdB=RelativeTarRefdB(1);
else
  RelativeTarRefdB=RelativeTarRefdB(ThisTarIdx);
end
ScaleBy=10^(RelativeTarRefdB/20);
    
TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
% generate the target sound:
[w, ev] = waveform(TarObject, ThisTarIdx, 0); % 0 means its target
ev_save=ev;

% svd 2009-06-29 make sure that sound is in a column
if size(w,2)>size(w,1),
    w=w';
end

% shift single-channel target to appropriate output channel
if size(w,2)==1 && TargetChannel>1,
    w=[repmat(zeros(size(w)),[1 TargetChannel-1]) w];
end
% pad higher channels with zero
w=[w zeros(length(w),chancount-size(w,2))];

if ~isempty(TarTrialIndex),
    % this trial has a regular target, save it
    fprintf('TarTrialIndex=%d (%d dB, channel %d)\n',TarTrialIndex,RelativeTarRefdB, TargetChannel);
    if OverlapRefTar,
        TarBins=TarStartBin+round(get(TarObject,'PreStimSilence').*TrialSamplingRate)+....
            (1:round((get(TarObject,'Duration').*TrialSamplingRate)));
        
        RefMaxDuringTar=max(abs(TrialSound(TarBins,TargetChannel)));
        ScaleBy=ScaleBy.*RefMaxDuringTar./5;
        fprintf('Ref max during tar: %.1f. Adjusted Tar ScaleBy: %.2f\n',RefMaxDuringTar,ScaleBy);
        RefMeanDuringTar=mean(abs(TrialSound(TarBins,TargetChannel)));
        %ScaleBy=ScaleBy.*RefMeanDuringTar./5;
        %fprintf('Ref mean during tar: %.1f. Adjusted Tar ScaleBy: %.2f\n',RefMeanDuringTar,ScaleBy);
        w=w.*ScaleBy;
        
        if TarMatchContour && ~isempty(refenv),
            tarenv=refenv(TarStartBin-1+(1:size(w,1)),ThisTarIdx);
            tarenv=tarenv.*0.75+0.25;
            w=w.*tarenv;
            TrialSound(TarStartBin-1+(1:size(w,1)),:)=...
                TrialSound(TarStartBin-1+(1:size(w,1)),:)+w;
        else
            if ScaleBy>1, ScaleBy=1; end
            if par.OnsetRampTime>0,
                % add a ramp
                PreZeros=round(get(TarObject,'PreStimSilence').*TrialSamplingRate);
                PostZeros=round(get(TarObject,'PostStimSilence').*TrialSamplingRate);
                
                TarRampBins=round(par.OnsetRampTime.*TrialSamplingRate);
                NonRampBins=length(w)-TarRampBins.*2-PreZeros-PostZeros;
                RefMod=repmat([ones(1,PreZeros) ...
                    linspace(1,1-ScaleBy,TarRampBins) ...
                    ones(1,NonRampBins).*(1-ScaleBy)...
                    linspace(1-ScaleBy,1,TarRampBins)...
                    ones(1,PostZeros)]',[1 size(w,2)]);
                TarMod=repmat([ones(1,PreZeros) ...
                    linspace(0,1,TarRampBins) ...
                    ones(1,NonRampBins)...
                    linspace(1,0,TarRampBins)...
                    ones(1,PostZeros)]',[1 size(w,2)]);
                zz= (std(w)==0);
                RefMod(:,zz)=1;
            else
                RefMod=1;
                TarMod=1;
            end
            
            TrialSound(TarStartBin-1+(1:size(w,1)),:)=...
                TrialSound(TarStartBin-1+(1:size(w,1)),:).*RefMod+...
                w.*TarMod;
            
        end
        LastEvent=TarStartTime;
        
    else
        % no overlap
        fprintf('Tar ScaleBy: %.2f\n',ScaleBy);
        w=w.*ScaleBy;
        TrialSound = [TrialSound ; w ];
    end
    
    % now, add Target to the event list, correct the time stamp with
    % respect to last event, and add Trial
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [ev(cnt2).Note ' , Target'];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    events = [events ev];
else
    w=w.*ScaleBy;
end

% if specified, tack a final "reminder target" on the end of the trial
% to provide an easy (low-reward) hit if the actual target was missed.
if par.ReminderTarget,
    % use same waveform as target
    ev=ev_save;
    
    ReminderStartTime=size(TrialSound,1)/TrialSamplingRate;
    TrialSound=[TrialSound ; w];
    for cnt2 = 1:length(ev),
        ev(cnt2).Note = [ev(cnt2).Note ' , Reminder'];
        ev(cnt2).StartTime = ev(cnt2).StartTime + ReminderStartTime;
        ev(cnt2).StopTime = ev(cnt2).StopTime + ReminderStartTime;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    events = [events ev];
end    
    
% normalize the sound, because the level control is always from attenuator.
if ~isempty(TarTrialIndex)
    TrialSound = 5 * TrialSound / max(abs(TrialSound0(:)));
else
    %TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
end

if max(abs(TrialSound(:)))>10,
    error('TrialSound too loud');
end

if ~isempty(CatchTrialIndex)
    CatchChannel=par.TargetChannel;
    if isempty(CatchChannel),
      CatchChannel=1;
    elseif length(CatchChannel)<CatchTrialIndex,
      CatchChannel=CatchChannel(1);
    else
      CatchChannel=CatchChannel(CatchTrialIndex);
    end
    
    RelativeTarRefdB=par.RelativeTarRefdB;
    if isempty(RelativeTarRefdB),
      RelativeTarRefdB=0;
    elseif length(RelativeTarRefdB)<CatchTrialIndex,
      RelativeTarRefdB=RelativeTarRefdB(1);
    else
      RelativeTarRefdB=RelativeTarRefdB(CatchTrialIndex);
    end
    ScaleBy=10^(RelativeTarRefdB/20);
    
    TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
    % generate the target sound:
    [w, ev] = waveform(TarObject, CatchTrialIndex, 0); % 0 means its target
        
    CatchStartTime=(par.SingleRefSegmentLen*par.CatchSeg(TrialIndex)+...
       get(RefObject,'PreStimSilence'));
    CatchStartBin=round(CatchStartTime.*TrialSamplingRate);
    
    % svd 2009-06-29 make sure that sound is in a column
    if size(w,2)>size(w,1),
        w=w';
    end
    
    % shift single-channel target to appropriate output channel
    if size(w,2)==1 && CatchChannel>1,
        w=[repmat(zeros(size(w)),[1 CatchChannel-1]) w];
    end
    % pad higher channels with zero
    w=[w zeros(length(w),chancount-size(w,2))];
    
    fprintf('CatchTrialIndex=%d (%d dB, channel %d)\n',CatchTrialIndex,RelativeTarRefdB, CatchChannel);
    
    if OverlapRefTar,
        CatchBins=CatchStartBin+round(get(TarObject,'PreStimSilence').*TrialSamplingRate)+....
            (1:round((get(TarObject,'Duration').*TrialSamplingRate)));
        RefMaxDuringCatch=max(abs(TrialSound(CatchBins,CatchChannel)));
        ScaleBy=ScaleBy.*RefMaxDuringCatch./5;
        fprintf('Ref max during catch: %.1f. Adjusted Catch ScaleBy: %.2f\n',RefMaxDuringCatch,ScaleBy);
        %RefMeanDuringCatch=mean(abs(TrialSound(CatchBins,CatchChannel)));
        %ScaleBy=ScaleBy.*RefMeanDuringCatch./5;
        %fprintf('Ref mean during catch: %.1f. Adjusted Catch ScaleBy: %.2f\n',RefMeanDuringCatch,ScaleBy);
        w=w.*ScaleBy;
        
        if par.OnsetRampTime>0,
           % add a ramp
           PreZeros=round(get(TarObject,'PreStimSilence').*TrialSamplingRate);
           PostZeros=round(get(TarObject,'PostStimSilence').*TrialSamplingRate);
           
           TarRampBins=round(par.OnsetRampTime.*TrialSamplingRate);
           NonRampBins=length(w)-TarRampBins.*2-PreZeros-PostZeros;
           RefMod=repmat([ones(1,PreZeros) ...
              linspace(1,1-ScaleBy,TarRampBins) ...
              ones(1,NonRampBins).*(1-ScaleBy)...
              linspace(1-ScaleBy,1,TarRampBins)...
              ones(1,PostZeros)]',[1 size(w,2)]);
           TarMod=repmat([ones(1,PreZeros) ...
              linspace(0,1,TarRampBins) ...
              ones(1,NonRampBins)...
              linspace(1,0,TarRampBins)...
              ones(1,PostZeros)]',[1 size(w,2)]);
           zz= (std(w)==0);
           RefMod(:,zz)=1;
        else
           RefMod=1;
           TarMod=1;
        end
        
        w = 5 * w / max(abs(TrialSound0(:)));
        
        TrialSound(CatchStartBin-1+(1:size(w,1)),:)=...
           TrialSound(CatchStartBin-1+(1:size(w,1)),:).*RefMod+...
           w.*TarMod;
    else
       error('non-overlapping catch stimuli not supported');
    end
    LastEvent=CatchStartTime;
    
    % now, add Target to the event list, correct the time stamp with
    % respect to last event, and add Trial
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [ev(cnt2).Note ' , Catch'];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    events = [events(1:(end-3)) ev events((end-2):end)];
    LastEvent = max(cat(1,events.StopTime));
end

if PostTrialBins>0,
   TrialSound=cat(1,TrialSound,zeros(PostTrialBins,chancount));
   events(end).StopTime=events(end).StopTime+PostTrialSilence;
end

if strcmp(BAPHY_LAB,'lbhb'),
   % debug code
   sfigure(1);
   clf
   dfs=50000;
   
   subplot(3,1,2);
   tw=resample(TrialSound,dfs,TrialSamplingRate);
   plot((1:length(tw))./dfs,tw);
   aa=axis;
   axis([0 length(tw)./dfs aa(3:4)]);
   
   subplot(3,1,1);
   tw=resample(TrialSound0,dfs,TrialSamplingRate);
   plot((1:length(tw))./dfs,tw);
   axis([0 length(tw)./dfs aa(3:4)]);
   
   subplot(3,1,3);
   h = spectrum.welch;        % Create a Welch spectral estimator.
   Hpsd = psd(h,tw,'Fs',dfs); % Calculate the PSD
   plot(Hpsd);                % Plot the PSD.
   
   drawnow
end

Refloudness = get(RefObject,'Loudness');
if isobject(TarObject)
    Tarloudness = get(TarObject,'Loudness');
else
    Tarloudness = 0;
end
%disp(['outWFM:' num2str(max(abs(TrialSound)))])

loudness = max(Refloudness,Tarloudness);
if loudness(min(RefTrialIndex(1),length(loudness)))>0
    o = set(o,'OveralldB', loudness(min(RefTrialIndex(1),length(loudness))));    
end
o = set(o, 'SamplingRate', TrialSamplingRate);

%2nd AO channel use for control MASTEWRFLEX flow rate.....pby added 10/06/2011
if isfield(par,'PumpProfile'),
    pumppro=ifstr2num(par.PumpProfile);
    if length(pumppro)==1 & pumppro(1)==0
        return;  %not required for pump control
    else
        pumppro(2:end)=10*pumppro(2:3)/6  %convert the flow rate (ml/min)to VDC. 10 V= 6.0 ml/min
        TrialSound(:,2)=pumppro(2);    %set constant speed
        if length(pumppro)==3
            if pumppro(1)==1     %low flow rate inter_trial_interval
                delay1=events(1).StopTime/2;                %high flow rate start before stimulus on
                delay1=(delay1*TrialSamplingRate);
                delay2=ev(3).StopTime;  %high flow rate extended during post-silence
                delay2=round(delay2*TrialSamplingRate)-10;   %10 samples for set flow rate back to low
                TrialSound(delay1:delay2,2)=pumppro(3);
            else pumppro(1)==2   %low flow arte during both ISI ans ITI, high during stimulus
                TrialSound(find(TrialSound(:,1)),2)=pumppro(2); %high speed during sound
            end
        end
    end
end






