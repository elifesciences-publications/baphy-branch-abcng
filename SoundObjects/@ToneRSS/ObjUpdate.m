function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% Nima, 2008: more frequencies do not make a complex tone! for that use the
%   multitone object. Here it means more individual tones.
% Nima, november 2005
Freqs = get(o,'Frequencies');
Names = {};
FreqNames={};
RSSNames={};

for cnt1 = 1:length(Freqs)
    FreqNames{cnt1} = num2str(Freqs(cnt1));
end

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
        RSSNames = cell(1,length(temp));
        [RSSNames{:}] = deal(temp.name);
        %disp('SplitChannels=no'); 
    case 'no '
        RSSNames = cell(1,length(temp));
        [RSSNames{:}] = deal(temp.name);
        %disp('SplitChannels=no'); 
    case 'yes'
        %this puts RSS 1-400 on ch1 and RSS 400:-1:1 on ch2 in random order
       RSSNames = cell(1,2*length(temp));
       RSSNamesCh1 = cell(1,length(temp));
       RSSNamesCh2 = cell(1,length(temp));
       [RSSNamesCh1{1:400}] = deal(temp.name);
       [RSSNamesCh2{1:400}] = RSSNamesCh1{400:-1:1};
       for kn=1:400
           [RSSNamesCh1{kn}] = strcat(RSSNamesCh1{kn},':1');
           [RSSNamesCh2{kn}] = strcat(RSSNamesCh2{kn},':2');
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
               RSSNames{jn}=RSSNamesCh1{ch1i};
               ch1i=ch1i+1;
           elseif chnlIndex(jn)==0
               RSSNames{jn}=RSSNamesCh2{ch2i};
               ch2i=ch2i+1;
           end
       end
end

Names=cell(length(FreqNames)*length(RSSNames),1);
for ii=1:length(FreqNames),
    for jj=1:length(RSSNames),
        Names{jj+(ii-1)*length(RSSNames)}=[FreqNames{ii} '+' RSSNames{jj}];
    end
end

o = set(o,'SoundPath',soundpath);
o = set(o,'FreqNames',FreqNames);
o = set(o,'RSSNames',RSSNames);
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));

