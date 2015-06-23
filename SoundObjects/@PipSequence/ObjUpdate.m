function o = ObjUpdate(o)

par=get(o);

TotalPips=par.PipsEachPerRep*par.BandCount;
TotalDuration=TotalPips./par.PipRate;
MaxIndex=ceil(TotalDuration./par.Duration);
if isempty(par.AttenuationLevels),
   par.AttenuationLevels=0;
end
par.AttenuationLevels=par.AttenuationLevels(:);

Frequencies=round(2.^linspace(log2(par.LowFrequency),log2(par.HighFrequency),par.BandCount));
%MaxIndex=1000;
Names=cell(MaxIndex,1);
for ii=1:MaxIndex
   Names{ii}=sprintf('Pips-%.0f-%.0f-%d-%d-%03d',...
      par.LowFrequency,par.HighFrequency,par.BandCount,par.PipRate,ii);
end

% each row contains: [Index Time Pip#]
saveseed=rand('seed');
if par.UserRandSeed>0,
   rand('seed',par.UserRandSeed);
else
   rand('seed',mod(par.LowFrequency*par.HighFrequency*par.MaxIndex,5550));
end

AdjustedTotalDuration=TotalDuration-MaxIndex.*par.PipDuration;
if par.SimultaneousCount<=1,
   PipTimes=round(sort(rand(TotalPips,1).*AdjustedTotalDuration)*10000)./10000;
else
   PipTimes=round(sort(rand(ceil(TotalPips./par.SimultaneousCount),1).*AdjustedTotalDuration)*10000)./10000;
   PipTimes=repmat(PipTimes,[par.SimultaneousCount 1]);
   PipTimes=sort(PipTimes(1:TotalPips));
end

PipIndex=ones(size(PipTimes));
for ii=1:(MaxIndex-1),
   ff=find(PipTimes>ii*par.Duration-par.PipDuration);
   PipTimes(ff)=PipTimes(ff)+par.PipDuration;
   PipIndex(ff)=ii+1;
end

ToneList=[mod((1:TotalPips)'-1,par.BandCount)+1 ...
   par.AttenuationLevels(mod(floor(((1:TotalPips)'-1)./par.BandCount),length(par.AttenuationLevels))+1)];
[~,sh]=sort(rand(TotalPips,1));
PipSet=[PipIndex mod(PipTimes,par.Duration) ToneList(sh,:)];

rand('seed',saveseed);
if par.HighFrequency>32000,
   o = set(o,'SamplingRate',par.HighFrequency*4);
else
   o = set(o,'SamplingRate',100000);
end

o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Names',Names);
o = set(o,'PipSet',PipSet);
o = set(o,'Frequencies',Frequencies);
