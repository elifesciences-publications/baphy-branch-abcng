function o = ObjUpdate (o);
%

% Nima, november 2005
BaseFrequency = ifstr2num(get(o,'BaseFrequency'));
OctaveBelow = ifstr2num(get(o,'OctaveBelow'));
OctaveAbove = ifstr2num(get(o,'OctaveAbove'));
TonesPerOctave = ifstr2num(get(o,'TonesPerOctave'));
LowdB = get(o,'LowdB');
HighdB = get(o,'HighdB');
Steps = get(o,'Steps');


% now, generate a list of all frequencies needed:
LowFrequency = (BaseFrequency / 2^OctaveBelow);
Frequencies = LowFrequency * 2.^(0:1/TonesPerOctave:OctaveBelow+OctaveAbove);
%
dBs = LowdB:Steps:HighdB;
count= 0;
for cnt1 = 1:length(Frequencies)-1
    for cnt2 = 1:length(dBs)
        count= count +1;
        %RandomFrequency = ceil(Frequencies(cnt1) + rand(1) * (Frequencies(cnt1+1)-Frequencies(cnt1)));
        Names{count,1} = [num2str(ceil(Frequencies(cnt1)))];
        Names{count,2} = dBs(cnt2);
    end
end
o = set(o,'Loudness',dBs);
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));