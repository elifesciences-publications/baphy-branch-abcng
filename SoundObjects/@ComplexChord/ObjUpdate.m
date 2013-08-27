function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% SVD 2007-03-30

Frequencies=get(o,'Frequencies');
AM=get(o,'AM');
FM=get(o,'FM');
ModDepth=get(o,'ModDepth');
ForcePaired=strcmpi(get(o,'ForcePaired'),'Yes');

% number of AMs or Frequencies (whichever is larger) controls total number of tones
if length(Frequencies)<length(AM),
    Frequencies=repmat(Frequencies(1),1,length(AM));
end
ToneCount=length(Frequencies);
FirstToneSubset=get(o,'FirstToneSubset');
if isempty(FirstToneSubset),
    FirstToneSubset=1:length(Frequencies);
elseif ~isnumeric(FirstToneSubset),
    FirstToneSubset=str2num(FirstToneSubset);
end
FirstToneCount=length(FirstToneSubset);

if isempty(FM),
    FM=zeros(1,ToneCount);
elseif length(FM)<ToneCount,
    FM=repmat(FM(1),1,ToneCount);
end
if isempty(AM),
    AM=zeros(1,ToneCount);
elseif length(AM)<ToneCount,
    AM=repmat(AM(1),1,ToneCount);
end
if isempty(ModDepth),
    ModDepth=zeros(1,ToneCount);
elseif length(ModDepth)<ToneCount,
    ModDepth=repmat(ModDepth(1),1,ToneCount);
end

FirstToneAtten=get(o,'FirstToneAtten');
if isempty(FirstToneAtten),
    FirstToneAtten=zeros(1,FirstToneCount);
elseif length(FirstToneAtten)<FirstToneCount,
    FirstToneAtten=repmat(FirstToneAtten(1),1,FirstToneCount);
end

if get(o,'SecondToneAtten')>-1,
    SecondToneSubset=get(o,'SecondToneSubset');
    if isempty(SecondToneSubset),
        SecondToneSubset=1:length(Frequencies);
    elseif ~isnumeric(SecondToneSubset),
        SecondToneSubset=str2num(SecondToneSubset);
    end
else
    SecondToneSubset=[];
end
SecondToneCount=length(SecondToneSubset);

if get(o,'ThirdToneAtten')>-1,
    ThirdToneSubset=get(o,'ThirdToneSubset');
    if isempty(ThirdToneSubset),
        ThirdToneSubset=1:length(Frequencies);
    elseif ~isnumeric(ThirdToneSubset),
        ThirdToneSubset=str2num(ThirdToneSubset);
    end
    if isempty(ThirdToneSubset),
        ThirdToneSubset=1:length(Frequencies);
    end
else
    ThirdToneSubset=[];
end
ThirdToneCount=length(ThirdToneSubset);

LightSubset=get(o,'LightSubset');
LightPhase=get(o,'LightPhase');
if isempty(LightSubset),
    LightSubset=-1;  % -1 means no light
elseif ~isnumeric(LightSubset),
    LightSubset=str2num(LightSubset);
end
LightCount=length(LightSubset);
if length(LightPhase)==0,
    LightPhase=zeros(1,LightCount);
elseif length(LightPhase)<LightCount,
    LightPhase=repmat(LightPhase(1),1,LightCount);
end

count=0;

if SecondToneCount==0 || ForcePaired,
    TotalTones=FirstToneCount;
    if length(FirstToneSubset(:))== length(SecondToneSubset(:)),
        if length(FirstToneSubset(:))== length(ThirdToneSubset(:)),
            ToneIdxSet=[FirstToneSubset(:) SecondToneSubset(:) ThirdToneSubset(:)];
        else
            ToneIdxSet=[FirstToneSubset(:) SecondToneSubset(:)];
        end
    else
        ToneIdxSet=[FirstToneSubset(:)];
    end
    
elseif ThirdToneCount==0;
    TotalTones=FirstToneCount*SecondToneCount;
    ToneIdxSet=cat(2,...
        reshape(repmat(FirstToneSubset,[SecondToneCount 1]),[],1),...
        reshape(repmat(SecondToneSubset',[1 FirstToneCount]),[],1));
else
    TotalTones=FirstToneCount*SecondToneCount*ThirdToneCount;
    ToneIdxSet=cat(2,...
        reshape(repmat(FirstToneSubset,[SecondToneCount*ThirdToneCount 1]),[],1),...
        reshape(repmat(reshape(repmat(SecondToneSubset',[1 FirstToneCount]),1,[]),ThirdToneCount,1),[],1),...        reshape(repmat(SecondToneSubset',[1 FirstToneCount]),[],1));
        reshape(repmat(ThirdToneSubset',[1 FirstToneCount*SecondToneCount]),[],1));
end

LightIdxSet=repmat(LightSubset(:)',[TotalTones 1]);
LightIdxSet=LightIdxSet(:);
LightPhaseSet=repmat(LightPhase(:)',[TotalTones 1]);
LightPhaseSet=LightPhaseSet(:);
TotalTones=TotalTones.*LightCount;
ToneIdxSet=repmat(ToneIdxSet,[LightCount 1]);

%ToneIdxSet
Names=cell(1,TotalTones);
for ii=1:TotalTones,
    for jj=1:size(ToneIdxSet,2),
        tidx=ToneIdxSet(ii,jj);
        Name1=[num2str(Frequencies(tidx))];
        if AM(tidx)>0,
            Name1=[Name1 , ':A:',num2str(AM(tidx))];
        end
        if ModDepth(tidx)>0 && ModDepth(tidx)<1,
            Name1=[Name1 , ':D:',num2str(ModDepth(tidx))];
        end
        if FM(tidx)>0,
            Name1=[Name1 , ':F:',num2str(FM(tidx))];
        end
        if jj==1 && length(unique(FirstToneAtten))>1,
            Name1=[Name1 , ':V:',num2str(FirstToneAtten(ii))];
        end
        if jj>1,
            Names{ii}=[Names{ii} '+' Name1];
        else
            Names{ii}=Name1;
        end
    end
    lidx=LightIdxSet(ii);
    if lidx>0,
        Names{ii}=[Names{ii} ':L:',num2str(AM(lidx))];
        if LightPhaseSet(ii)~=0,
            Names{ii}=[Names{ii} ':Ph:',num2str(LightPhaseSet(ii))];
        end
    end
end

o = set(o,'MaxIndex',TotalTones);
o = set(o,'ToneIdxSet',ToneIdxSet);
o = set(o,'LightIdxSet',LightIdxSet);
o = set(o,'LightPhaseSet',LightPhaseSet);
o = set(o,'Names',Names);
