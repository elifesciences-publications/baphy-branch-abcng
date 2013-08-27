function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.
%
% SVD 2009-09-08


Duration=get(o,'Duration');
ModLow=get(o,'ModLow');
ModHigh=get(o,'ModHigh');
ModDepth=get(o,'ModDepth');
LightAmp=get(o,'LightAmp');
LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
NoiseCount=get(o,'NoiseCount');
TonesPerBurst=get(o,'TonesPerBurst');
RefRepCount=get(o,'RefRepCount');

LightCount=length(LightAmp);
TotalSounds=LightCount.*NoiseCount;
ff=linspace(log2(LowFreq),log2(HighFreq),NoiseCount+1);
Frequencies=round(2.^(ff(1:(end-1))+diff(ff)./2));

Names=cell(1,TotalSounds);
n=0;
for jj=1:LightCount,
    for ii=1:NoiseCount,
        n=n+1;
        Names{n}=num2str(Frequencies(ii));
        if ~isnan(LightAmp(jj)),
           Names{n}=[Names{n} ':L:' num2str(LightAmp(jj))];
        end
    end
end
Frequencies=repmat(Frequencies,[1 LightCount]);

o = set(o,'MaxIndex',TotalSounds);
o = set(o,'Frequencies',Frequencies);
o = set(o,'Names',Names);
