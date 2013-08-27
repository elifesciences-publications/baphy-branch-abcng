function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, 2008: more frequencies do not make a complex tone! for that use the
%   multitone object. Here it means more individual tones.
% Nima, november 2005

par=get(o);

SequenceCount=par.SequenceCount;
Frequencies=par.Frequencies;
ToneDuration=par.ToneDuration;
MinGap=par.MinGap;
MaxGap=par.MaxGap;
MeanGap=(MinGap+MaxGap)./2;
Duration=par.Duration;
ToneCount=floor(Duration./(ToneDuration+MeanGap));
RelativeAttenuation=par.RelativeAttenuation;

if RelativeAttenuation>0,
   MaxIndex=4*SequenceCount;
else
   MaxIndex=2*SequenceCount;
end

% force same carrier signal each time!!!!
saveseed=rand('seed');
rand('seed',SequenceCount*100);

GapSet=ones(ToneCount,1).*MeanGap;
for ii=1:floor(ToneCount./2),
    adjust=round(rand*(MaxGap-MinGap).*20)./20;
    GapSet(ii)=MinGap+adjust;
    GapSet(end-ii+1)=MaxGap-adjust;
end

Names = cell(MaxIndex,1);
ii=0;
OnsetTimes=cell(MaxIndex,1);
if RelativeAttenuation==0,
   AttenSet=1;
   AttenString={''};
else
   AttenSet=1:2;
   AttenString={sprintf(': C1 -%ddB',RelativeAttenuation),...
      sprintf(': C2 -%ddB',RelativeAttenuation)};
end

for cnt1 = 1:SequenceCount,
   for attidx=AttenSet,
      ii=ii+1;
      Names{ii}=['Coherent Seq ',num2str(cnt1),AttenString{attidx}];
      xx=cumsum(shuffle(GapSet+ToneDuration));
      OnsetTimes{ii}=repmat(xx-ToneDuration,[1 2]);
      AttenuateChan(ii)=attidx;
      
      ii=ii+1;
      Names{ii}=['Incoherent Seq ',num2str(cnt1),AttenString{attidx}];
      xx1=cumsum(shuffle(GapSet+ToneDuration));
      xx2=cumsum(shuffle(GapSet+ToneDuration));
      if mod(cnt1,2)==0,
         OnsetTimes{ii}=[xx1-xx1(1)  xx2-ToneDuration];
      else
         OnsetTimes{ii}=[xx1-ToneDuration  xx2-xx2(1)];
      end
      AttenuateChan(ii)=attidx;
   end
end

o = set(o,'AttenuateChan',AttenuateChan);
o = set(o,'OnsetTimes',OnsetTimes);
o = set(o,'Names',Names);
o = set(o,'MaxIndex',MaxIndex);

rand('seed',saveseed);