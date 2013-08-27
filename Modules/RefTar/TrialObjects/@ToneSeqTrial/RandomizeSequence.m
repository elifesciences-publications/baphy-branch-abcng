function [exptparams] = RandomizeSequence (o, exptparams, globalparams, repetition, RepOrTrial)
%Randomizing trial sequence for TrialObject.
%
if nargin<5, RepOrTrial = 1;end   % default is its a trial call
if nargin<4, repetition = 1;end
% ToneSequence is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial call, return:
if ~RepOrTrial, return; end

o=ObjUpdate(o);
MaxRefNumPerTrial=get(o,'MaxRefNumPerTrial');  %add option for fix trialLen @1-19-2013 when 2 elements
refmax=get(o,'ReferenceMaxIndex');
tarmax=get(o,'TargetMaxIndex');
gaplist=get(o,'MultipleGap');
type=get(o,'FrequencyVaried');
torch=get(o,'Torchandle');
if ~isempty(torch)
    torclist=get(o,'TorcList');
    torclist=randperm(length(torclist));
    o=set(o,'TorcList',torclist); end

totalRefNum=0;
if isempty(torch)
    %for i=1:MaxRefNumPerTrial+1   %if include the trai with zero reference
    %refobj=
    if isfield(get(get(o,'referencehandle')),'Type') && strcmpi(get(get(o,'referencehandle'),'Type'),'Shepard')
        tar=get(o,'targethandle');
        ref=get(o,'referencehandle');
        tar_dir=get(tar,'Frequency'); %target perceived direction match with ref (1) or not(0)
        if length(tar_dir)<4
            tar_dir=1; else
            tar_dir=tar_dir(4); end
        tarlist=str2num(char(get(tar,'Names')));
        reflist=str2num(char(get(ref,'Names')));
        sham=find(reflist(:,1)==tarlist(1,1));
        
        N1=find(reflist(:,1)<tarlist(1,1));
        N1=nchoosek(N1,MaxRefNumPerTrial(1));
        N1(:,end+1)=find(tarlist(:,2)~=reflist(N1(1),2));   %add target
        N1=[ones(size(N1,1),1)*MaxRefNumPerTrial(1) N1];       %warning trials-1   perceveid direction changed
        
        N2=flipud(find(reflist(:,1)>tarlist(1,1)));
        N2=nchoosek(N2,MaxRefNumPerTrial(1));
        N2(:,end+1)=find(tarlist(:,2)~=reflist(N2(1),2));   %add target 
        N2=[ones(size(N2,1),1)*MaxRefNumPerTrial(1) N2];       %warning trials-1   perceveid direction changed
        
        tem=[N1;N2];
        %now for making sham trial
        N1(:,1)=N1(:,1)+1; N1(:,end)=sham(reflist(sham,2)==reflist(N1(1,2),2));   %add sham;
        N2(:,1)=N2(:,1)+1; N2(:,end)=sham(reflist(sham,2)==reflist(N2(1,2),2));   %add sham;
        tem=[tem;N1;N2];
        tem=tem(randperm(size(tem,1)),:);
        for i=1:size(tem,1)
           TrialIndices{i}=tem(i,:);
        end
        for i=1:length(TrialIndices)     %randomly pick target
            RefIndices{i} = ones(1,TrialIndices{i}(1));
        end
        Gaprand=[];       %add this block to make a rand tonegap in the sequence by trial
        if length(gaplist)>0
            i=length(TrialIndices);
            while i>0
                Gaprand=[Gaprand randperm(length(gaplist))];
                i=i-length(gaplist);
            end
            Gaprand=Gaprand(1:length(TrialIndices));
        end
        
        o=set(o,'ReferenceIndices',RefIndices);
        o=set(o,'TrialIndices',TrialIndices);
        o=set(o,'NumberOfTrials',length(TrialIndices));
        o=set(o,'ToneGapIndices',Gaprand);
        if nargin==1
            exptparams=o; else
            exptparams.TrialObject= o;
        end
        return;
    else
        if length(MaxRefNumPerTrial)>1 && MaxRefNumPerTrial(2)==0  %for fixed length
            reflen=ones(tarmax,1)*MaxRefNumPerTrial(1);   %
            %add sham trial for fixed trial length
            for i=1:length(reflen)
                tem=reflen(i)+1;  %1: number of references per trial
                totalRefNum=totalRefNum+tem;
                tem=[tem ones(1,reflen(i)+1)];            %following reference index number
                TrialIndices_sham{i}=tem;
            end
        else            
            reflen=mklookuptable(MaxRefNumPerTrial(1),0.25);   %make a rough equal chance for each position.
            TrialIndices_sham=[];
        end
        for i=1:length(reflen)
            tem=reflen(i);  %1: number of references per trial
            totalRefNum=totalRefNum+tem;
            tem=[tem ones(1,reflen(i))];  %following reference index number
            tem=[tem tarmax(1)];                    %the last one id target index
            TrialIndices{i}=tem;
        end
        TrialIndices=[TrialIndices(:);TrialIndices_sham(:)];
        TrialIndices=TrialIndices(randperm(size(TrialIndices,1)));
    end
else
    reflen=randperm(MaxRefNumPerTrial(1));     %ref number each trial
    torcused=0;i=0;trialnum=0;
    reflen=reflen+1;   %change into Torcnum per trial
    while torcused<length(torclist)
        i=i+1;trialnum=trialnum+1;
        if i>length(reflen)
            reflen=randperm(MaxRefNumPerTrial(1))+1;     %re-randomize ref number
            %reflen(reflen==MaxRefNumPerTrial(1))=[];
            i=1; end
        if length(torclist)-torcused-reflen(i)<=1
            if reflen(i)==max(reflen) & length(torclist)-torcused-reflen(i)>=0
                 tem=1;
            elseif length(torclist)-torcused==MaxRefNumPerTrial(1)
                tem=1;
            else
                 tem=length(torclist)-torcused-1;  %Ref#
            end
        else
            tem=reflen(i)-1;                          %1: number of references per trial
        end
        totalRefNum=totalRefNum+tem;
        tem=[tem ones(1,tem)];    %following reference index number
        tem=[tem 1];                    %the last one id target index
        TrialIndices{trialnum}=tem;
        torcused=torcused+tem(1)+1;          %need (refnum+1) TORCs per trial during reference period
    end
end

%reflen=randperm(MaxRefNumPerTrial(1));     %ref number for each trial
i=totalRefNum;
REFrand=[];
while i>0
    REFrand=[REFrand randperm(refmax)];
    i=i-refmax;
end
switch lower(type)
    case 'fixed'
        % leave as is.
    case 'withintrial'   %reference changed by location
        s=1;
        for i=1:length(TrialIndices)
            TrialIndices{i}([1:TrialIndices{i}(1)]+1)=REFrand([1:TrialIndices{i}(1)]+s-1);  %
            s=s+TrialIndices{i}(1);
        end
    case {'bytrial-1','bytrial-2'}   %reference changed trial by trial
        for i=1:length(TrialIndices)
            TrialIndices{i}([1:TrialIndices{i}(1)]+1)=REFrand(i);  %
        end
    otherwise
        error('wrong TrialType');
        return;
end
i=length(TrialIndices);
TARrand=[];
while i>0
    TARrand=[TARrand randperm(tarmax)];
    i=i-tarmax;
end
for i=1:length(TrialIndices)     %randomly pick target
    if length(TrialIndices{i})>TrialIndices{i}(1)
        if strcmpi(type,'bytrial-1')
            TrialIndices{i}(end)=TrialIndices{i}(end-1);  %added on 6/27/2013
        else
            TrialIndices{i}(end)=TARrand(i);
        end
    end
    RefIndices{i} = ones(1,TrialIndices{i}(1));
end
Gaprand=[];       %add this block to make a rand tonegap in the sequence by trial
if length(gaplist)>0
    i=length(TrialIndices);    
    while i>0
        Gaprand=[Gaprand randperm(length(gaplist))];
        i=i-length(gaplist);
    end
    Gaprand=Gaprand(1:length(TrialIndices));
end

o=set(o,'ReferenceIndices',RefIndices);
o=set(o,'TrialIndices',TrialIndices);
o=set(o,'NumberOfTrials',length(TrialIndices));
o=set(o,'ToneGapIndices',Gaprand);
if nargin==1
    exptparams=o; else
    exptparams.TrialObject= o;
end