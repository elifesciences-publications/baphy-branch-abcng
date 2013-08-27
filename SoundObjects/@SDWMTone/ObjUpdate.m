function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, 2008: more frequencies do not make a complex tone! for that use the
%   multitone object. Here it means more individual tones.
% Nima, november 2005
Freqs = get(o,'Frequencies');
Names = [];
for cnt1 = 1:length(Freqs)
    Names{cnt1} = num2str(Freqs(cnt1));
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Freqs));
% o = set(o,'Names',{['[' strrep(Names, ',', ' ') ']']});
