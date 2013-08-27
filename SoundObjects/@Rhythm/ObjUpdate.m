function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, november 2005
ICI=get(o, 'ICI');

%Rhythms seperated by NaN character
MaxIndex=sum(isnan(ICI))+1;
Names=cell(1,MaxIndex);
for ii=1:MaxIndex,
    Names{ii}=['Rhythm ',num2str(ii)];
end

o = set(o,'MaxIndex',length(Names));
o = set(o,'Names',Names);
