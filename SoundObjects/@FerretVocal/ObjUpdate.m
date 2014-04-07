function o = ObjUpdate (o);
%

soundset=get(o,'Subsets');
RepIdx=get(o,'RepIdx');

object_spec = what('FerretVocal');
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
UNames = cell(1,length(temp));
[UNames{:}] = deal(temp.name);

MaxIndex=length(UNames);
idxset=(1:MaxIndex)';
if length(RepIdx)>=2 && RepIdx(1)>0 && RepIdx(2)>1,
    RepSet=1:RepIdx(1);
    RepCount=RepIdx(2);
    idxset=cat(1,repmat(idxset(RepSet,:),[RepCount 1]),...
               idxset((RepIdx(1)+1):end,:));
    MaxIndex=size(idxset,1);
end

Names=cell(1,MaxIndex);
for ii=1:MaxIndex,
    Names{ii}=UNames{idxset(ii)};
end

o = set(o,'Names',Names);
o = set(o,'idxset',idxset);
o = set(o,'SoundPath',soundpath);
o = set(o,'MaxIndex', length(Names));
