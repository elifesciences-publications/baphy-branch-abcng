function o = ObjUpdate (o);
%

% Nima, november 2005
BaseFrequency = ifstr2num(get(o,'BaseFrequency'));
OctaveBelow = ifstr2num(get(o,'OctaveBelow'));
OctaveAbove = ifstr2num(get(o,'OctaveAbove'));
TonesPerOctave = ifstr2num(get(o,'TonesPerOctave'));

% now, generate a list of all frequencies needed:
LowFrequency = (BaseFrequency / 2^OctaveBelow);
Frequencies = LowFrequency * 2.^(0:1/TonesPerOctave:OctaveBelow+OctaveAbove);
%
Names=[];
for cnt1 = 1:length(Frequencies)-1
    RandomFrequency = ceil(Frequencies(cnt1) + rand(1) * (Frequencies(cnt1+1)-Frequencies(cnt1)));
    Names{cnt1} = num2str(RandomFrequency);
end
if isempty(Names)
    % I think this happens when only one frequency exists:
    Names{1} = num2str(Frequencies);
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));