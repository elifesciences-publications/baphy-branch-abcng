function [TrialSound, events , o] = waveform (o,TrialIndex)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. This is a generic script
% that works for all passive cases, all active cases that use a standard
% SoundObject (e.g. tone). You can overload it by writing your own waveform.m
% script and copying it in your object's folder.

% Nima Mesgarani, October 2005

global SPNOISE_EMTX

par = get(o); % get the parameters of the trial object
RefObject = par.ReferenceHandle; % get the reference handle
TarObject = par.TargetHandle; % getthe target handle
RefSamplingRate = ifstr2num(get(RefObject, 'SamplingRate'));
TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));

if (par.NumberOfTarPerTrial~=0) && ~strcmpi(par.TargetClass,'none')
   TarTrialIndex = par.TargetIndices{TrialIndex};
   if isempty(TarTrialIndex)  % if its a Sham
      % this means there is a target but this trial is sham. ALthough
      % there is no target, we need to adjust the amplitude based on
      % RefTardB.
      TarObject = -1;
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
RefTrialIndex1 = par.ReferenceIndices{TrialIndex,1};
RefTrialIndex2 = par.ReferenceIndices{TrialIndex,2};
TarIndex=par.TargetIndices{TrialIndex};
if ismember(TarIndex,par.Tar1Index),
   TarBand=1;
elseif ismember(TarIndex,par.Tar2Index),
   TarBand=2;
else
   error('Target has no stream??');
end
if ~isempty(par.SingleRefSegmentLen) && par.SingleRefSegmentLen>0,
   TarStartTime=(par.SingleRefDuration(TrialIndex)+...
      get(RefObject,'PreStimSilence'));
   TarStartBin=round(TarStartTime.*TrialSamplingRate);
   if OverlapRefTar,
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
RefObject1=RefObject;
RefObject2=RefObject;
if strcmpi(get(RefObject,'descriptor'),'SpNoise'),
   Ref1Parms=par.Ref1Parms;
   if length(Ref1Parms<3),
      Ref1Parms(3)=0;
   end
   RefObject1=set(RefObject1,'LowFreq',Ref1Parms(1));
   RefObject1=set(RefObject1,'HighFreq',Ref1Parms(2));
   RefObject1=set(RefObject1,'RelAttenuatedB',0);
   Ref2Parms=par.Ref2Parms;
   if length(Ref2Parms<3),
      Ref2Parms(3)=0;
   end
   RefObject2=set(RefObject2,'LowFreq',Ref2Parms(1));
   RefObject2=set(RefObject2,'HighFreq',Ref2Parms(2));
   RefObject2=set(RefObject2,'RelAttenuatedB',0);
   RelAttenuatedB=Ref1Parms(3)-Ref2Parms(3);
else
   error('TwoStreamRefTar: not prepared to handle this sound object as reference');
end

for cnt1 = 1:length(RefTrialIndex1)  % go through all the reference sounds in the trial
   if get(RefObject,'Duration')==AdjustRefDur,
      % simple case: Reference duration matches what we want it to be
      
      [w1,ev1]=waveform(RefObject1, RefTrialIndex1(cnt1));
      [w2,ev2]=waveform(RefObject2, RefTrialIndex2(cnt1));
      % svd 2009-06-29 make sure that sound is in a column
      if size(w1,2)>size(w1,1),
         w1=w1';
         w2=w2';
      end
      w=[w1 w2];
      te1=env(RefObject1, RefTrialIndex1(cnt1));
      te2=env(RefObject2, RefTrialIndex2(cnt1));
      refenv=[te1 te2];
      for ii=1:length(ev1),
         N1=strsep(ev1(ii).Note,',');
         N2=strsep(ev2(ii).Note,',');
         ev1(ii).Note=[N1{1},', ',strtrim(N1{2}),':',strtrim(N2{2})];
      end
      ev=ev1;
   else
      CumRefDur=0;
      fs=get(RefObject,'SamplingRate');
      RefObject1=set(RefObject1,'PostStimSilence',0);
      RefObject2=set(RefObject2,'PostStimSilence',0);
      rcount=0;
      w=[];ev=[];
      while CumRefDur<AdjustRefDur,
         if get(RefObject1,'Duration')>AdjustRefDur-CumRefDur,
            RefObject1=set(RefObject1,'Duration',AdjustRefDur-CumRefDur);
            RefObject2=set(RefObject2,'Duration',AdjustRefDur-CumRefDur);
         end
         fprintf('Adding ref seg %.2f sec\n',get(RefObject2,'Duration'));
         [tw1,tev1]=waveform(RefObject1, RefTrialIndex1(cnt1)); % 1 means its reference
         [tw2,tev2]=waveform(RefObject2, RefTrialIndex2(cnt1)); % 1 means its reference
         CumRefDur=CumRefDur+get(RefObject1,'Duration');
         % svd 2009-06-29 make sure that sound is in a column
         if size(tw1,2)>size(tw1,1),
            tw1=tw1';
            tw2=tw2';
         end
         w=cat(1,w,[tw1 tw2]);
         if TarMatchContour && ismethod(RefObject,'env'),
            te1=env(RefObject1, RefTrialIndex1(cnt1));
            te2=env(RefObject2, RefTrialIndex2(cnt1));
            refenv=cat(1,refenv,[te1 te2]);
         end
         for ii=1:length(tev1),
            N1=strsep(tev1(ii).Note,',');
            N2=strsep(tev2(ii).Note,',');
            tev1(ii).Note=[N1{1},', ',strtrim(N1{2}),':',strtrim(N2{2})];
         end
         if isempty(ev),
            ev=tev1;
            if par.OnsetRampTime>0,
               % add a ramp
               OnsetRampBins=round(par.OnsetRampTime.*fs);
               PreStimBins=round(rpre.*fs);
               w(PreStimBins+(1:OnsetRampBins),:)=...
                  linspace(0,1,OnsetRampBins)'.*w(PreStimBins+(1:OnsetRampBins),:);
            end
         else
            t0=ev(end).StopTime;
            for ii=1:length(tev1),
               tev1(ii).StartTime=tev1(ii).StartTime+t0;
               tev1(ii).StopTime=tev1(ii).StopTime+t0;
            end
            ev=cat(2,ev,tev1);
         end
         RefObject1=set(RefObject1,'PreStimSilence',0);
         RefObject2=set(RefObject2,'PreStimSilence',0);
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
% figure(1);
% clf
% subplot(3,1,1);
% plot(TrialSound);
% subplot(3,1,2);
% plot(refenv);


% Add target to TrialSound
if isobject(TarObject)
   TarTrialIndex = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
   RelativeTarRefdB=par.RelativeTarRefdB;
   if isempty(RelativeTarRefdB),
      RelativeTarRefdB=0;
   elseif length(RelativeTarRefdB)<TarTrialIndex,
      RelativeTarRefdB=RelativeTarRefdB(1);
   else
      RelativeTarRefdB=RelativeTarRefdB(TarTrialIndex);
   end
   TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
   % generate the target sound:
   [w, ev] = waveform(TarObject, TarTrialIndex, 0); % 0 means its target
   
   % svd 2009-06-29 make sure that sound is in a column
   if size(w,2)>size(w,1),
      w=w';
   end
   
   w=w*10^(RelativeTarRefdB/20);
   if OverlapRefTar,
      if TarMatchContour && ~isempty(refenv),
         tarenv=refenv(TarStartBin-1+(1:size(w,1)),TarBand);
         tarenv=tarenv.*0.75+0.25;
         w=w.*tarenv;
      end
      TrialSound(TarStartBin-1+(1:size(w,1)),TarBand)=TrialSound(TarStartBin-1+(1:size(w,1)),TarBand)+w;
      LastEvent=TarStartTime;
      
   else
      if size(w,2)<2,
         w=[w w];
      end
      w(:,3-TarBand)=0;         
      TrialSound = [TrialSound ; w ];
   end
   % now, add Target to the note, correct the time stamp in respect to
   % last event, and add Trial
   for cnt2 = 1:length(ev)
      ev(cnt2).Note = [ev(cnt2).Note ' , Target'];
      ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
      ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
      ev(cnt2).Trial = TrialIndex;
   end
   LastEvent = ev(end).StopTime;
   events = [events ev];
   % normalize the sound, because the level control is always from attenuator.
   TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
elseif TarObject == -1
   % sham trial:
   if isfield(get(par.TargetHandle),'ShamNorm'),
      TrialSound = 5 * TrialSound / get(par.TargetHandle,'ShamNorm');
   else
      TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
      if get(o,'RelativeTarRefdB')>0
         TrialSound = TrialSound / (10^(get(o,'RelativeTarRefdB')/20));
      end
   end
end

% figure(1);
% subplot(3,1,3);
% plot(TrialSound);
% drawnow

if RelAttenuatedB > 0,
   %if > 0, decrease channel 1 by RelAttenatedB
   TrialSound(:,1)=TrialSound(:,1)*10^(-RelAttenuatedB/20);
elseif RelAttenuatedB < 0,
   %if < 0, decrease channel 2
   TrialSound(:,2)=TrialSound(:,2)*10^(RelAttenuatedB/20);
end

if PostTrialBins>0,
   TrialSound=cat(1,TrialSound,zeros(PostTrialBins,chancount));
   events(end).StopTime=events(end).StopTime+PostTrialSilence;
   
end

%% loadness stuff disabled 
% Refloudness = get(RefObject,'Loudness');
% if isobject(TarObject)
%    Tarloudness = get(TarObject,'Loudness');
% else
%    Tarloudness = 0;
% end
% %disp(['outWFM:' num2str(max(abs(TrialSound)))])
% 
% loudness = max(Refloudness,Tarloudness);
% if loudness(min(RefTrialIndex1(1),length(loudness)))>0
%    o = set(o,'OveralldB', loudness(min(RefTrialIndex1(1),length(loudness))));
% end

o = set(o, 'SamplingRate', TrialSamplingRate);


