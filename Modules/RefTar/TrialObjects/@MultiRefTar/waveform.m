function [TrialSound, events , o] = waveform (o,TrialIndex)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. This is a generic script
% that works for all passive cases, all active cases that use a standard
% SoundObject (e.g. tone). You can overload it by writing your own waveform.m
% script and copying it in your object's folder.

% Nima Mesgarani, October 2005

global SPNOISE_EMTX BAPHY_LAB

par = get(o); % get the parameters of the trial object
FlipFlag = par.FlipFlag(TrialIndex);   % determine if ref and tar should be flipped
if ~FlipFlag,
  RefObject = par.ReferenceHandle; % get the reference handle
  TarObject = par.TargetHandle; % getthe target handle
else    %flip
  TarObject = par.ReferenceHandle;    % get the reference handle
  RefObject = par.TargetHandle;           % getthe target handle
end

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

FlipFlag = par.FlipFlag(TrialIndex); % get the index of reference sounds for current trial
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

chancount=size(TrialSound,2);
if ~isempty(TarTrialIndex)
    TarTrialIndex = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
    
    TargetChannel=par.TargetChannel;
    if isempty(TargetChannel),
      TargetChannel=1;
    elseif length(TargetChannel)<TargetChannel,
      TargetChannel=TargetChannel(1);
    else
      TargetChannel=TargetChannel(TarTrialIndex);
    end
    
    RelativeTarRefdB=par.RelativeTarRefdB;
    if isempty(RelativeTarRefdB),
      RelativeTarRefdB=0;
    elseif length(RelativeTarRefdB)<TarTrialIndex,
      RelativeTarRefdB=RelativeTarRefdB(1);
    else
      RelativeTarRefdB=RelativeTarRefdB(TarTrialIndex);
    end
    %if isfield(refpar,'RelAttenuatedB'),
    %    if length(refpar.RelAttenuatedB)>=TarTrialIndex,
    %        LevelAdjust=RelativeTarRefdB-refpar.RelAttenuatedB(TarTrialIndex);
    %    else
    %        LevelAdjust=RelativeTarRefdB-refpar.RelAttenuatedB(1);
    %    end
    %else
        LevelAdjust=RelativeTarRefdB;
    %end
    ScaleBy=10^(LevelAdjust/20);
    
    TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
    % generate the target sound:
    [w, ev] = waveform(TarObject, TarTrialIndex, 0); % 0 means its target
    
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
    
    fprintf('TarTrialIndex=%d (%d dB, channel %d)\n',TarTrialIndex,RelativeTarRefdB, TargetChannel);
    fprintf('Ref max: %.1f %.1f  Tar max: %.1f\n',max(abs(TrialSound)),max(abs(w(:,TargetChannel))));
    TrialSound0=TrialSound;
    if OverlapRefTar,
%         TarBins=TarStartBin+get(TarObject,'PreStimSilence').*TrialSamplingRate+....
%             (1:(get(TarObject,'Duration').*TrialSamplingRate));
        TarBins=TarStartBin+round(get(TarObject,'PreStimSilence').*TrialSamplingRate)+....
            (1:round((get(TarObject,'Duration').*TrialSamplingRate)));
        
        RefMaxDuringTar=max(abs(TrialSound(TarBins,TargetChannel)));
        fprintf('Ref max during tar: %.1f  Adjusting ScaleBy to compensate!\n',RefMaxDuringTar);
        ScaleBy=ScaleBy.*RefMaxDuringTar./5;
        fprintf('Adjusted Tar ScaleBy: %.2f\n',ScaleBy);
        w=w.*ScaleBy;
        
        if TarMatchContour && ~isempty(refenv),
            tarenv=refenv(TarStartBin-1+(1:size(w,1)),TarTrialIndex);
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
        end
        LastEvent=TarStartTime;
        
    else
        % no overlap
        fprintf('Tar ScaleBy: %.2f\n',ScaleBy);
        TrialSound = [TrialSound ; w*ScaleBy ];
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
    
    % normalize the sound, because the level control is always from attenuator.
    TrialSound = 5 * TrialSound / max(abs(TrialSound0(:)));
else
    TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
  
% elseif TarObject == -1
%     % sham trial:
%     if isfield(get(par.TargetHandle),'ShamNorm'),
%         TrialSound = 5 * TrialSound / get(par.TargetHandle,'ShamNorm');
%     else
%         TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
%         if get(o,'RelativeTarRefdB')>0
%             TrialSound = TrialSound / (10^(get(o,'RelativeTarRefdB')/20));
%         end
%     end
end

if PostTrialBins>0,
   TrialSound=cat(1,TrialSound,zeros(PostTrialBins,chancount));
   events(end).StopTime=events(end).StopTime+PostTrialSilence;

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






