function o = ObjUpdate (o)
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% SVD 2013-03-22
global FORCESAMPLINGRATE;

LowFreq1=get(o,'LowFreq1');
HighFreq1=get(o,'HighFreq1');
AM1=get(o,'AM1');
LowFreq2=get(o,'LowFreq2');
HighFreq2=get(o,'HighFreq2');
AM2=get(o,'AM2');
SamplingRate=get(o,'SamplingRate');
ModDepth=get(o,'ModDepth');
SyncBands=get(o,'SyncBands');
if isempty(AM1),
  AM1=0;
end
if isempty(AM2),
  AM2=0;
end

BandCount1=min(length(HighFreq1),length(LowFreq1));
BandCount2=min(length(HighFreq2),length(LowFreq2));
AMCount1=length(AM1);
AMCount2=length(AM2);

if strcmpi(SyncBands,'Yes'),
   BandCount=min(BandCount1,BandCount2);
   AMCount=min(AMCount1,AMCount2);
   MaxIndex=BandCount*AMCount;
   
   Names = cell(1,MaxIndex);
   idx=0;
   for cnt1 = 1:BandCount,
      for cnt2=1:AMCount,
         idx=idx+1;
         Names{idx}=sprintf('%05d-%05d:A:%.1f:%05d-%05d:A:%.1f',...
            LowFreq1(cnt1),HighFreq1(cnt1),AM1(cnt2),...
            LowFreq2(cnt1),HighFreq2(cnt1),AM2(cnt2));
      end
   end
   
else
   MaxIndex=(BandCount1*AMCount1)+(BandCount2*AMCount2);
   IdxMtx=zeros(MaxIndex,4);
   Names = cell(1,MaxIndex);
   idx=0;
   for cnt1 = 1:BandCount1,
      for cnt2=1:AMCount1,
          idx=idx+1;
          Names{idx}=sprintf('1:%05d-%05d:A:%.1f',...
              LowFreq1(cnt1),HighFreq1(cnt1),AM1(cnt2));
          IdxMtx(idx,:)=[1 cnt1 cnt2];
      end
   end
    for cnt1 = 1:BandCount2,
      for cnt2=1:AMCount2,
          idx=idx+1;
          Names{idx}=sprintf('2:%05d-%05d:A:%.1f',...
              LowFreq2(cnt1),HighFreq2(cnt1),AM2(cnt2));
          IdxMtx(idx,:)=[2 cnt1 cnt2];
      end
   end
end

o = set(o,'Names',Names);
o = set(o,'MaxIndex',MaxIndex);
o = set(o,'IdxMtx',IdxMtx);

if isempty(FORCESAMPLINGRATE)
    while SamplingRate<max([HighFreq1(:);HighFreq2(:)])*4,
        SamplingRate=SamplingRate+50000;
        o = set(o,'SamplingRate',SamplingRate);
    end
end
