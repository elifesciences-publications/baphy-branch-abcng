function o = ObjUpdate (o);
%


object_spec = what('RSS');
soundset=get(o,'Subsets');
if soundset>=10
    soundset=round(soundset/10); end
if soundset==1  %default 400 RSS stimuli (1.25-33 kHz,1/8th oct)
    soundpath = [object_spec(1).path filesep 'sounds'];
elseif soundset==2 %0 dB RSS stimuli
    soundpath = [object_spec(1).path filesep 'sounds2'];
else
    disp('Wrong subset!!'); 
    return; 
end

temp = dir([soundpath filesep '*.wav']);
spchnl=get(o,'SplitChannels');
switch spchnl
    case 'no'
        Names = cell(1,length(temp));
        [Names{:}] = deal(temp.name);
        %disp('SplitChannels=no'); 
    case 'no '
        Names = cell(1,length(temp));
        [Names{:}] = deal(temp.name);
        %disp('SplitChannels=no'); 
    case 'yes'
        %this puts RSS 1-400 on ch1 and RSS 400:-1:1 on ch2 in random order
       Names = cell(1,2*length(temp));
       NamesCh1 = cell(1,length(temp));
       NamesCh2 = cell(1,length(temp));
       [NamesCh1{1:400}] = deal(temp.name);
       [NamesCh2{1:400}] = NamesCh1{400:-1:1};
       for kn=1:400
           [NamesCh1{kn}] = strcat(NamesCh1{kn},':1');
           [NamesCh2{kn}] = strcat(NamesCh2{kn},':2');
       end
       %make random order to place stimuli in Ch1 or Ch2
       chnlIndex=[];
       chnlIndex=zeros(length(temp),1);
       chnlIndex(length(temp)+1:2*length(temp),1)=1;
       
       % save the current random seed
       saveseed=rand('seed');
       % force the same random seed each time
       rand('seed',13);
       chnlIndex=shuffle(chnlIndex);
       % return random seed to previous state
       rand('seed',saveseed);
       
       
       ch1i=1;
       ch2i=1;
       for jn=1:2*length(temp)
           if chnlIndex(jn)==1
               Names{jn}=NamesCh1{ch1i};
               ch1i=ch1i+1;
           elseif chnlIndex(jn)==0
               Names{jn}=NamesCh2{ch2i};
               ch2i=ch2i+1;
           end
       end
       %disp('SplitChannels=yes'); 
end

o = set(o,'Names',Names);
o = set(o,'SoundPath',soundpath);
o = set(o,'MaxIndex', length(Names));
