function o = ObjUpdate (o);
%

%
object_spec = what('PfCSoundSet');
soundset=get(o,'Subsets');
if soundset==1  %default 50 stimuli set
    soundpath = [object_spec.path filesep 'Sounds'];
elseif soundset==2  %adult ferrets VC set (from 5 ferrets
    soundpath = [object_spec.path filesep 'Sounds_set2'];
elseif soundset==3  %new infiant ferret VC set
    soundpath = [object_spec.path filesep 'Sounds_set3'];
else
    disp('Wrong subset!!'); return; end
temp = dir([soundpath filesep '*.wav']);
Names = cell(1,length(temp));
[Names{:}] = deal(temp.name);
o = set(o,'Names',Names);
o = set(o,'MaxIndex', length(Names));