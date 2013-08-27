function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.
%
% SVD 2013-04-09
%
Freqs = get(o,'Frequencies');
Levels = get(o,'Levels');
Names = [];
for cnt1 = 1:length(Freqs)
    for cnt2=1:length(Levels),
        Names{(cnt1-1)*length(Levels)+cnt2} = [num2str(Freqs(cnt1)) '-' num2str(Levels(cnt2))];
    end
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Freqs).*length(Levels));

