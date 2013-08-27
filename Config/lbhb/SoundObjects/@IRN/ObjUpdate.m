function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, 2008: more frequencies do not make a complex tone! for that use the
%   multitone object. Here it means more individual tones.
% Nima, november 2005
LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
StepMS=get(o,'StepMS');
BandCount=min(length(LowFreq),length(HighFreq));
if length(StepMS)<BandCount,
    StepMS=repmat(StepMS(1),[1 BandCount]);
end

Names=cell(BandCount,1);
for cnt1 = 1:BandCount
    Names{cnt1} = sprintf('%d-%d(%d)',round(LowFreq(cnt1)),...
        round(HighFreq(cnt1)),round(StepMS(cnt1)));
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',BandCount);
