function o = ObjUpdate (o)
% Update the changes of a Stream_AB object
% Pingbo, December 2005
% modified in Aprul, 2006

Type=lower(get(o,'Type'));
if strcmpi(Type(1),'t')
    o=set(o,'Type','Tone');
elseif strcmpi(Type(1),'b')
    o=set(o,'Type','BPN');
else
    error('Wrong Type!!! Stim Type must be: ''PsudoRand,Rand''');
end

fs = get(o,'SamplingRate');
Frequency = get(o,'Standard');
Deviant=get(o,'Deviant');
Deviant_pct=get(o,'Deviant_pct');
mFrequency=Frequency(1)*(1+max(Deviant/100));
if fs<(mFrequency*2)
    o=set(o,'SamplingRate',ceil(mFrequency*2/100)*100); end
MaxIndex=length(Deviant_pct);
for i=1:MaxIndex
    Names{i}=num2str([Frequency(1) Deviant Deviant_pct(i)]);
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',MaxIndex);
