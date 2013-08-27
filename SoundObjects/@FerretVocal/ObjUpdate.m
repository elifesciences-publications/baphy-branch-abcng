function o = ObjUpdate (o);
%


object_spec = what('FerretVocal');
soundset=get(o,'Subsets');
if soundset>=10
    soundset=round(soundset/10); end
if soundset==1  %default 30 infant stimuli set
    soundpath = [object_spec(1).path filesep 'sounds'];
elseif soundset==2  %adult ferrets VC set (from 5 ferrets
    soundpath = [object_spec(1).path filesep 'Sounds_set2'];
elseif soundset==3  %new infiant ferret VC set
    soundpath = [object_spec(1).path filesep 'Sounds_set3'];
elseif soundset==4  %new infiant ferret VC set
   soundpath = [object_spec(1).path filesep 'Sounds_set4'];
elseif soundset==5  %new infiant ferret VC set
   soundpath = [object_spec(1).path filesep 'Sounds_set5'];
else
    disp('Wrong subset!!'); 
    return; 
end

temp = dir([soundpath filesep '*.wav']);
Names = cell(1,length(temp));
[Names{:}] = deal(temp.name);
o = set(o,'Names',Names);
o = set(o,'SoundPath',soundpath);
o = set(o,'MaxIndex', length(Names));
