function o = ObjUpdate (o)
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% SVD 2015-03-05

par=get(o);

TotalCount=par.SequenceCount;
SeqPerRate=ceil(TotalCount./length(par.F1Rates));
Names=cell(1,TotalCount);
PipsPerTrial=floor(par.Duration./(par.PipDuration+par.PipInterval));
Sequences=zeros(PipsPerTrial,TotalCount);
s=rand('state');
rand('state',PipsPerTrial*TotalCount);
for ii=1:TotalCount,
    SeqNum=ceil(ii/SeqPerRate);
    Names{ii}=sprintf('Seq%03d+F1%.2f',ii,par.F1Rates(SeqNum));
    
    F1Rate=par.F1Rates(SeqNum);
    Sequences(:,ii)=double(rand(PipsPerTrial,1)>F1Rate)+1;
    
end

o = set(o,'SamplingRate',100000);
o = set(o,'MaxIndex',TotalCount);
o = set(o,'Names',Names);
o = set(o,'Sequences',Sequences);
