function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% SVD 2007-03-30
global FORCESAMPLINGRATE;

LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
Count=get(o,'Count');
Frequencies=round(exp(linspace(log(LowFreq),log(HighFreq),Count)));
SimulCount=get(o,'SimulCount');
TotalCount=Count.^SimulCount;

Names=cell(1,TotalCount);
for ii=1:TotalCount,
    if SimulCount==1,
        Names{ii}=num2str(Frequencies(ii));
    elseif SimulCount==2,
        i1=mod((ii-1),Count)+1;
        i2=floor((ii-1)./Count)+1;
        Names{ii}=[num2str(Frequencies(i2)) '+' num2str(Frequencies(i1))];
    else
        error('Sorry, SimulCount>2 not supported!')
    end
end

if isempty(FORCESAMPLINGRATE),
   if max(Frequencies)>16000,
      o = set(o,'SamplingRate',100000);
   else
      o = set(o,'SamplingRate',100000);
   end
end

o = set(o,'MaxIndex',TotalCount);
o = set(o,'Names',Names);
