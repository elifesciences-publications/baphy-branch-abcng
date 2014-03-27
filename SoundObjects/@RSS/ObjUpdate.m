function o = ObjUpdate (o);
%


object_spec = what('RSS');
soundset=get(o,'Subsets');
if soundset>=10
    soundset=round(soundset/10); end
if soundset==1  %default 400 RSS stimuli (1.25-33 kHz,1/8th oct)
    soundpath = [object_spec(1).path filesep 'sounds'];
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
