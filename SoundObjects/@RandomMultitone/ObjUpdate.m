function o = ObjUpdate (o);
%

% Nima, november 2005
BaseFundamental = ifstr2num(get(o,'BaseFundamental'));
OctaveBelow = ifstr2num(get(o,'OctaveBelow'));
OctaveAbove = ifstr2num(get(o,'OctaveAbove'));
TonesPerOctave = ifstr2num(get(o,'TonesPerOctave'));
NumberOfHarmonics = ifstr2num(get(o,'NumOfHarmonics'));
% now, generate a list of all frequencies needed:
LowFrequency = (BaseFundamental / 2^OctaveBelow);
Frequencies = LowFrequency * 2.^(0:1/TonesPerOctave:OctaveBelow+OctaveAbove);
% now specify the harmonics that have to be added.
HarPerRep = ceil((length(Frequencies)-1) / length(NumberOfHarmonics));
Harmonics = [];
for cnt1 = 1:length(NumberOfHarmonics)
    Harmonics = [Harmonics repmat(NumberOfHarmonics(cnt1),[1 HarPerRep])];
end
% now shuffle the number of harmonics:
Harmonics = Harmonics(randperm(length(Harmonics)));
Harmonics(end+1:length(Frequencies)-1) = Harmonics(1:length(Frequencies)-1-length(Harmonics));
%
for cnt1 = 1:length(Frequencies)-1
    RandomFrequency = ceil(Frequencies(cnt1) + rand(1) * (Frequencies(cnt1+1)-Frequencies(cnt1)));
    for cnt2 = 1:Harmonics(cnt1)
        RandomFrequency = [RandomFrequency RandomFrequency(1)*(cnt2+1)];
    end
    Names{cnt1} = num2str(RandomFrequency);
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));