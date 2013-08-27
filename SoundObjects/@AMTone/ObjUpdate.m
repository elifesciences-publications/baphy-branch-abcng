function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% SVD 2007-03-30
global FORCESAMPLINGRATE;

LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
SamplingRate=get(o,'SamplingRate');
AM=get(o,'AM');
ModDepth=get(o,'ModDepth');
FirstSubsetIdx=get(o,'FirstSubsetIdx');
SecondSubsetIdx=get(o,'SecondSubsetIdx');
Count=get(o,'Count');
SilentStimPerRep=get(o,'SilentStimPerRep');

if ~isnumeric(FirstSubsetIdx),
    FirstSubsetIdx=str2num(FirstSubsetIdx);
end
if ~isnumeric(SecondSubsetIdx),
    SecondSubsetIdx=str2num(SecondSubsetIdx);
end

lfset=linspace(log2(LowFreq),log2(HighFreq),2.*Count+1);
% boundaries between noise bands:
Frequencies=round(2.^(lfset(1:2:end)));

% log2 centers of noise bands:
MidFreqs=round(2.^(lfset(2:2:end)));

if isempty(AM),
   AM=0;
end
if isempty(ModDepth),
   ModDepth=1;
end
if length(ModDepth)<length(AM),
   ModDepth=ones(size(AM)).*ModDepth(1);
end
NBCount=Count*length(AM);

if isempty(FirstSubsetIdx),
   FirstSubsetIdx=1:NBCount;
end

if isempty(SecondSubsetIdx) || ~ismember(SecondSubsetIdx(1),1:NBCount),
   Count1=length(FirstSubsetIdx);
   Count2=0;
   TotalCount=Count1;
else
   Count1=length(FirstSubsetIdx);
   Count2=length(SecondSubsetIdx);
   TotalCount=Count1*Count2;
end

Names=cell(1,TotalCount);

for ii=1:TotalCount,
   i1=FirstSubsetIdx(mod((ii-1),Count1)+1);
   i1freq=mod(i1-1,Count)+1;
   i1AM=floor((i1-1)./Count)+1;
   
   Names{ii}=num2str(MidFreqs(i1freq),'%05d');
   if AM(i1AM)>0,
      Names{ii}=[Names{ii} ':A:' num2str(AM(i1AM))];
      if ModDepth(i1AM)<1,
         Names{ii}=[Names{ii} ':D:' num2str(ModDepth(i1AM))];
      end
   end
   if Count2>0,
      i2=SecondSubsetIdx(floor((ii-1)./Count1)+1);
      i2freq=mod(i2-1,Count)+1;
      i2AM=floor((i2-1)./Count)+1;
      Names{ii}=[Names{ii} '+' num2str(MidFreqs(i2freq),'%05d')];
      if AM(i2AM)>0,
         Names{ii}=[Names{ii} ':A:' num2str(AM(i2AM))];
         if ModDepth(i2AM)<1,
            Names{ii}=[Names{ii} ':D:' num2str(ModDepth(i2AM))];
         end
      end
   end
end

if SilentStimPerRep,
   for ii=(TotalCount+1):(TotalCount+SilentStimPerRep),
      Names{ii}='SILENCE';
   end
   TotalCount=TotalCount+SilentStimPerRep;
end

o = set(o,'LoBounds',Frequencies(1:(end-1)));
o = set(o,'HiBounds',Frequencies(2:end));
o = set(o,'NBCount',NBCount);
o = set(o,'MaxIndex',TotalCount);
o = set(o,'Names',Names);
if isempty(FORCESAMPLINGRATE) && HighFreq>SamplingRate/4,
  o = set(o,'SamplingRate',HighFreq*4);
end
