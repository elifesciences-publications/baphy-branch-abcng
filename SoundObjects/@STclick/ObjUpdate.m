function o = ObjUpdate (o)
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user first changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, november 2005
ClickRates = ifstr2num(get(o,'ClickRate'));
for cnt1 = 1:length(ClickRates)
    Names{cnt1} = ['[' num2str(ClickRates(cnt1)) ']'];
end
o = set(o,'MaxIndex',length(Names));
o = set(o,'Names',Names);
