function o = ObjUpdate (o);
%
% sporc update. piggyback on top of speech and torc objects

Subsets = get(o,'Subsets');
ospeech=get(o,'speechobj');
ospeech=set(ospeech,'Loudness',get(o,'Loudness'),...
    'PreStimSilence',get(o,'PreStimSilence'),...
    'PostStimSilence',get(o,'PostStimSilence'),...
    'Subsets',Subsets,...
    'SNR',get(o,'SNR'),...
    'Duration',get(o,'Duration'));
ospeech=ObjUpdate(ospeech);
o=set(o,'speechobj',ospeech);

%o = set(o,'Names',get(ospeech,'Names'));
o = set(o,'Phonemes',get(ospeech,'Phonemes'));
o = set(o,'Words',get(ospeech,'Words'));
o = set(o,'Sentences',get(ospeech,'Sentences'));
o = set(o,'MaxIndex',get(ospeech,'MaxIndex'));

%get(ospeech,'Subsets')
n=get(ospeech,'Sentences');

FrequencyRange = get(o,'FrequencyRange');
Rates = get(o,'Rates');
otorc=get(o,'torcobj');
otorc=set(otorc,'Loudness',get(o,'Loudness'));
otorc=set(otorc,'PreStimSilence',get(o,'PreStimSilence'));
otorc=set(otorc,'PostStimSilence',get(o,'PostStimSilence'));
otorc=set(otorc,'FrequencyRange',get(o,'FrequencyRange'));
otorc=set(otorc,'Rates',get(o,'Rates'));
otorc=set(otorc,'Duration',get(o,'Duration'));
otorc=ObjUpdate(otorc);

o=set(o,'torcobj',otorc);

o = set(o,'Params',get(otorc,'Params'));
o = set(o,'SamplingRate', get(otorc,'SamplingRate'));
Names=get(otorc,'Names');
for ii=1:length(Names),
   Names{ii}=strrep(Names{ii},'TORC',sprintf('SPORC-%d',Subsets));
end
o = set(o,'Names', Names);
