function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, november 2005
ClickRates = ifstr2num(get(o,'ClickRate'));
JitterSD = ifstr2num(get(o,'JitterSD'));
if length(JitterSD)<length(ClickRates),
    JitterSD=repmat(JitterSD(1),size(ClickRates));
end

for cnt1 = 1:length(ClickRates)
    if JitterSD(cnt1),
        Names{cnt1} = ['[' num2str(ClickRates(cnt1)) '+/-', ...
            num2str(JitterSD(cnt1)), ']'];
    else
        Names{cnt1} = ['[' num2str(ClickRates(cnt1)) ']'];
    end
end
o = set(o,'MaxIndex',length(Names));
o = set(o,'Names',Names);
