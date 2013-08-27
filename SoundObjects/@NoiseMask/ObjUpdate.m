function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, november 2005
ProbeNames = num2str(get(o,'ProbeFreq'));
NotchWidthNames= get(o,'NotchWidth');
Names= strcat(ProbeNames, '|', NotchWidthNames);
o = set(o,'Names',{['[' strrep(Names, ',', ' ') ']']});
o = set(o,'MaxIndex', 30);