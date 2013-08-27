function o = ObjUpdate (o);
%
% piggyback on top of speech object to get waveform
global FORCESAMPLINGRATE;

PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
LowFreq = get(o,'LowFreq');
HighFreq = get(o,'HighFreq');
SamplingRate = get(o,'SamplingRate');
TonesPerOctave = get(o,'TonesPerOctave');
TonesPerBurst=round(log2(HighFreq./LowFreq).*TonesPerOctave);
BaseSound=get(o,'BaseSound');
SpDuration=get(o,'SpDuration');
RhDuration=get(o,'RhDuration');

Subsets = get(o,'Subsets');
spnoiseobj=get(o,'spnoiseobj');


if SamplingRate~=get(spnoiseobj,'SamplingRate'),
   spnoiseobj=set(spnoiseobj,'SamplingRate',SamplingRate);
end
if PreStimSilence~=get(spnoiseobj,'PreStimSilence'),
   spnoiseobj=set(spnoiseobj,'PreStimSilence',PreStimSilence);
end
if 0~=get(spnoiseobj,'PostStimSilence'),
   spnoiseobj=set(spnoiseobj,'PostStimSilence',0);
end
if LowFreq~=get(spnoiseobj,'LowFreq'),
   spnoiseobj=set(spnoiseobj,'LowFreq',LowFreq);
end
if HighFreq~=get(spnoiseobj,'HighFreq'),
   spnoiseobj=set(spnoiseobj,'HighFreq',HighFreq);
end
if TonesPerOctave~=get(spnoiseobj,'TonesPerOctave'),
   spnoiseobj=set(spnoiseobj,'TonesPerOctave',TonesPerOctave);
end
if ~strcmp(BaseSound,get(spnoiseobj,'BaseSound')),
   spnoiseobj=set(spnoiseobj,'BaseSound',BaseSound);
end
if Subsets~=get(spnoiseobj,'Subsets'),
   spnoiseobj=set(spnoiseobj,'Subsets',Subsets);
end
if SpDuration~=get(spnoiseobj,'Duration'),
   spnoiseobj=set(spnoiseobj,'Duration',SpDuration);
end
spnoiseobj=ObjUpdate(spnoiseobj);

% in case sampling rate was readjusted internally in SpNoise...
SamplingRate=get(spnoiseobj,'SamplingRate');


% Click Train-specific parameters
Count = get(o,'Count');
ICI = get(o,'ICI');
Level = get(o,'Level');
ClickWidth = get(o,'ClickWidth');
rhythmobj=get(o,'rhythmobj');

if SamplingRate~=get(rhythmobj,'SamplingRate'),
   rhythmobj=set(rhythmobj,'SamplingRate',SamplingRate);
end
if 0~=get(rhythmobj,'PreStimSilence'),
   rhythmobj=set(rhythmobj,'PreStimSilence',0);
end
if PostStimSilence~=get(rhythmobj,'PostStimSilence'),
   rhythmobj=set(rhythmobj,'PostStimSilence',PostStimSilence);
end
if ClickWidth~=get(rhythmobj,'ClickWidth'),
   rhythmobj=set(rhythmobj,'ClickWidth',ClickWidth);
end
if Count~=get(rhythmobj,'Count'),
   rhythmobj=set(rhythmobj,'Count',Count);
end
if ICI~=get(rhythmobj,'ICI'),
   rhythmobj=set(rhythmobj,'ICI',ICI);
end
if Level~=get(rhythmobj,'Level'),
   rhythmobj=set(rhythmobj,'Level',Level);
end
if RhDuration~=get(rhythmobj,'Duration'),
   rhythmobj=set(rhythmobj,'Duration',RhDuration);
end
rhythmobj=ObjUpdate(rhythmobj);

Names=get(spnoiseobj,'Names');
RhNames=get(rhythmobj,'Names');

for ii=1:length(Names),
   Names{ii}=[Names{ii} '+' RhNames{1}];
end

o = set(o,'spnoiseobj',spnoiseobj);
o = set(o,'rhythmobj',rhythmobj);
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));
o = set(o,'Duration',SpDuration+RhDuration);
o = set(o,'SamplingRate',SamplingRate);

% sr=SpNoiseRhythm;
% sr=set(sr,'PreStimSilence',0.5);
% sr=set(sr,'PostStimSilence',0.5);    
% sr=set(sr,'BaseSound','FerretVocal'); 
% sr=set(sr,'Subsets',4);       
% sr=set(sr,'Count',12);
% sr=set(sr,'ICI',[0.1 0.05]);
% sr=set(sr,'SpDuration',1);
