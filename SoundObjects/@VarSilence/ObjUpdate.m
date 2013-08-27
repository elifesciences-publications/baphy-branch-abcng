function o = ObjUpdate (o);
%

% Ling Ma, 08/2007
duration = get(o,'Duration');
% LowdB = get(o,'LowdB');
% HighdB = get(o,'HighdB');
% Steps = get(o,'Steps');


for cnt1 = 1:length(duration)
    Names{cnt1} = num2str(duration(cnt1));
end
% o = set(o,'Loudness',dBs);
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(duration));