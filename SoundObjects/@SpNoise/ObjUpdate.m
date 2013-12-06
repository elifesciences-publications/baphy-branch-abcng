
function o = ObjUpdate (o);
%
% piggyback on top of speech object to get waveform
global FORCESAMPLINGRATE SPNOISE_EMTX

LowFreq = get(o,'LowFreq');
HighFreq = get(o,'HighFreq');
bmax=min(length(LowFreq),length(HighFreq));
SamplingRate = get(o,'SamplingRate');
TonesPerOctave = get(o,'TonesPerOctave');
TonesPerBurst=round(log2(HighFreq(1:bmax)./LowFreq(1:bmax)).*TonesPerOctave);
BaseSound=strtrim(get(o,'BaseSound'));
Subsets = get(o,'Subsets');
SetSizeMult = get(o,'SetSizeMult');
CoherentFrac = get(o,'CoherentFrac');
ShuffleOnset=get(o,'ShuffleOnset');  % if 1, randomly rotate stimulus waveforms in time
RepIdx=get(o,'RepIdx');
Duration=get(o,'Duration');  % if 1, randomly rotate stimulus waveforms in time

if ~TonesPerOctave,
    UseBPNoise=1;
else
    UseBPNoise=0;
end

object_spec = what(class(o));
envpath = [object_spec(1).path filesep 'envelope' filesep];

% eg "Speech.subset1.mat"   and "Speech1"
EnvFileName=[envpath BaseSound '.subset',num2str(Subsets),'.mat'];
EnvVarName=[BaseSound,num2str(Subsets)];
load(EnvFileName);

bandcount=min(length(HighFreq),length(LowFreq));
if bandcount>1,
    % force same carrier signal each time!!!!
    saveseed=rand('seed');
    rand('seed',Subsets*20);
    MaxIndex=round(Env.MaxIndex.*SetSizeMult);
    idxset=repmat((1:Env.MaxIndex)',[ceil(SetSizeMult) bandcount]);
    ShuffledOnsetTimes=zeros(MaxIndex,bandcount);
    coherentcount=round(MaxIndex.*CoherentFrac);
    incoherentset=1:(size(idxset,1)-coherentcount);
    for jj=2:bandcount,
        kk=0;
        % slight kludge, keep shuffling until there are no matches between
        % index values in columns 1 and column jj, except where intended.
        while sum(idxset(incoherentset,1)==idxset(incoherentset,jj))>0 && kk<20,
            ff=find(idxset(incoherentset,1)==idxset(incoherentset,jj));
            if length(ff)==1;
                ff=union(ff,[1;2]);
            end
            idxset(ff,jj)=shuffle(idxset(ff,jj));
            kk=kk+1;
        end
    end
    MaxIncoherent=MaxIndex-coherentcount;
    idxset=idxset([1:MaxIncoherent (end-coherentcount+1):end],:);
    
    if ShuffleOnset,
        if ShuffleOnset==1,
            d=Duration;
        elseif ShuffleOnset==2,
            % don't make it depend on the stimulus length!!!!
            % fixes bug in MultiRefTar that changes reference Duration
            d=3;
        end
        ShuffledOnsetTimes=floor(rand(size(ShuffledOnsetTimes))*d*2)./2;
        ShuffledOnsetTimes(MaxIncoherent:end,2:end)=...
            repmat(ShuffledOnsetTimes(MaxIncoherent:end,1),[1 bandcount-1]);
    end
    % return random seed to previous state
    rand('seed',saveseed);
else
    MaxIndex=Env.MaxIndex;
    idxset=(1:MaxIndex)';
    ShuffledOnsetTimes=zeros(size(idxset));
end

if length(RepIdx)>=2 && RepIdx(1)>0 && RepIdx(2)>1,
    RepSet=1:RepIdx(1);
    RepCount=RepIdx(2);
    idxset=cat(1,repmat(idxset(RepSet,:),[RepCount 1]),...
               idxset((RepIdx(1)+1):end,:));
    ShuffledOnsetTimes=cat(1,repmat(ShuffledOnsetTimes(RepSet,:),[RepCount 1]),...
               ShuffledOnsetTimes((RepIdx(1)+1):end,:));
    MaxIndex=size(idxset,1);
end
    

SPNOISE_EMTX.(EnvVarName)=Env.emtx;
%o=set(o,'emtx',Env.emtx);
o=set(o,'idxset',idxset);
o=set(o,'ShuffledOnsetTimes',ShuffledOnsetTimes);
o=set(o,'MaxIndex',MaxIndex);
o=set(o,'Phonemes',Env.Phonemes);
o=set(o,'SamplingRateEnv',Env.fs);
o=set(o,'UseBPNoise',UseBPNoise);
Names=Env.Names;

Names=cell(1,MaxIndex);
for ii=1:MaxIndex,
    Names{ii}=['BNB'];
    for bb=1:bandcount,
        Names{ii}=[Names{ii} '+' Env.Names{idxset(ii,bb)}];
    end
end

o = set(o,'Names',Names);
o = set(o,'TonesPerBurst',TonesPerBurst);

if isempty(FORCESAMPLINGRATE)
    while SamplingRate<max(HighFreq)*4,
        SamplingRate=SamplingRate+50000;
        o = set(o,'SamplingRate',SamplingRate);
    end
end
