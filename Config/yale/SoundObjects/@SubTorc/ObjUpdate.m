function o = ObjUpdate (o);
%


object_spec = what('MouseVocal');
soundset=get(o,'Subsets');
if soundset>=10
    soundset=round(soundset/10); end
if soundset==1
    soundpath = [object_spec(1).path filesep 'Sounds_set1'];
elseif soundset==2
    soundpath = [object_spec(1).path filesep 'Sounds_set2'];
elseif soundset==3
    soundpath = [object_spec(1).path filesep 'Sounds_set3'];
elseif soundset==4
   soundpath = [object_spec(1).path filesep 'Sounds_set4'];
elseif soundset==5 
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
