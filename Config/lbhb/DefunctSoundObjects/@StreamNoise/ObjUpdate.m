function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% clear temp waveform variables because object parameters are changing
global STREAMNOISEWAV STREAMNOISESPECGRAM

Duration=get(o,'Duration');
Count=get(o,'Count');

RepeatIdx=get(o,'RepeatIdx');
ShuffleCount=get(o,'ShuffleCount');
SamplingRate=get(o,'SamplingRate');
LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
GapDur=get(o,'GapDur');
SampleIdentifier=get(o,'SampleIdentifier');

o = set(o,'SampleDuration',Duration./Count-GapDur);

MaxIndex=(length(RepeatIdx)+1).*ShuffleCount;
Names=cell(1,ShuffleCount);
ii=0;
IdxSet=zeros(Count,2,MaxIndex);

% fix random state for deterministic shuffling
saverandstate=rand('state');
rand('state',1);

for repidx=[0 RepeatIdx(:)'],
   for shuffidx=1:ShuffleCount,
      ii=ii+1;
      Names{ii}=sprintf('Rep %d, Shuffle %d',repidx,shuffidx);
      
      IdxSet(:,1,ii)=shuffle((1:Count)');
      if repidx>0,
         IdxSet(:,2,ii)=repidx;
      elseif Count>1,
         % second idx is also random
         tidx=shuffle((1:Count)');
         % don't allow overlaps
         while sum(IdxSet(:,1,ii)==tidx)>0,
            tidx=shuffle((1:Count)');
         end
         IdxSet(:,2,ii)=tidx;
      end
   end
end

% restore random number generator to previous state
rand('state',saverandstate);

o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Names',Names);
o = set(o,'IdxSet',IdxSet);

if SamplingRate<HighFreq.*2,
   o = set(o,'SamplingRate',SamplingRate.*2);
end

testidentifier=[Duration Count LowFreq HighFreq GapDur SamplingRate];
if sum(abs(SampleIdentifier-testidentifier))>0,
  o = set(o,'SampleIdentifier',testidentifier);
  STREAMNOISEWAV=[];
  STREAMNOISESPECGRAM=[];
end
