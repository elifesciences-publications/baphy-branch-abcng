function o = ObjUpdate (o);
%

% Nima, november 2005
BaseFrequency = get(o,'BaseFrequency');
LowdB = get(o,'LowdB');
HighdB = get(o,'HighdB');
Steps = get(o,'Steps');

% now, generate a list of all dBs needed:
dBs = LowdB:Steps:HighdB;

for cnt1 = 1:length(dBs)
    Names{cnt1} = num2str(dBs(cnt1));
end
o = set(o,'Loudness',dBs);
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(dBs));