function o = ObjUpdate (o)
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% clear temp waveform variables because object parameters are changing.
% these need to be global since they're generated by wavform(), which
% doesn't seem to have a good way of updating the orginal object
global STREAMNOISEWAV STREAMNOISESPECGRAM

Duration=get(o,'Duration');
Count=get(o,'Count');

SamplingRate=get(o,'SamplingRate');
LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
SampleIdentifier=get(o,'SampleIdentifier');

MaxIndex=Count;
Names=cell(1,Count);

for ii=1:Count,
    Names{ii}=sprintf('%02d',ii);
end

o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Names',Names);

if SamplingRate<HighFreq.*2,
   o = set(o,'SamplingRate',HighFreq.*2);
end

testidentifier=[Duration Count LowFreq HighFreq 0 SamplingRate];
if sum(abs(SampleIdentifier-testidentifier))>0,
  o = set(o,'SampleIdentifier',testidentifier);
  STREAMNOISEWAV=[];
  STREAMNOISESPECGRAM=[];
end
