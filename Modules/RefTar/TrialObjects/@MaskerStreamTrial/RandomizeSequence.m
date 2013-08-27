function [exptparams] = RandomizeSequence (o, exptparams, globalparams, repetition, RepOrTrial)
%Randomizing trial sequence for TrialObject.
% By Ling Ma, 10/2006

if nargin<5, RepOrTrial = 1;end   % default is its a trial call
if nargin<4, repetition = 1;end
% streaming is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial call, return:
% if ~RepOrTrial, return; end
if ~RepOrTrial,
%     if (isfield(exptparams,'Performance'))&& (~strcmp(exptparams.Performance(end).ThisTrial,'Hit'))%----added by Ling Ma
%         curtrial = repetition % "repetition" here actually is current trial in this repetition when "RepOrTrial" is 0;
%         TrialIndex = get(o, 'TrialIndices');
%         TrialIndices = [TrialIndex(1:curtrial-1,:);TrialIndex(curtrial,:);TrialIndex(curtrial:end,:)];
%         ReferenceIdx = get(o, 'ReferenceIdx');
%         ii = sum(TrialIndex(1:curtrial-1,1))+1:sum(TrialIndex(1:curtrial,1));
%         ReferenceIdx = [ReferenceIdx(1:ii(1)-1,:);ReferenceIdx(ii,:);ReferenceIdx(ii,:);ReferenceIdx(ii(end)+1:end,:)];
%         ReferenceIndices = get(o, 'ReferenceIndices');
%         ReferenceIndices = {ReferenceIndices{1:curtrial-1},ReferenceIndices{curtrial},ReferenceIndices{curtrial:end}};
%         
%         o = set(o,'TrialIndices',TrialIndices);
%         o = set(o,'ReferenceIdx',ReferenceIdx);
%         o = set(o,'ReferenceIndices',ReferenceIndices);
%         o=set(o,'NumberOfTrials',size(TrialIndices,1));
%         exptparams.TrialObject= o;
%     end
    return;
end
            

% trial length randomization
MaxRefNumPerTrial=get(o,'MaxRefNumPerTrial');
refmax=get(o,'ReferenceMaxIndex');
lookuptable = get(o,'Lookuptable');
refhandle = get(o,'ReferenceHandle'); 
stimlistcnt = get(refhandle,'StimListCnt');
while isempty(lookuptable)||length(lookuptable)<2*refmax
%     lookuptable=[lookuptable;mklookuptable(MaxRefNumPerTrial+1,0.25)-1];
%     lookuptable=[lookuptable;mklookuptable(MaxRefNumPerTrial,0.25)];
        lookuptable=[lookuptable;randperm(MaxRefNumPerTrial)'];
% lookuptable=[lookuptable;2;3;1;3;2;2;1;3;2;2;3;1;2;1;2;3;2;2;3;2;1;3;2];
% lookuptable=[lookuptable;2;3;1;3;2;2;1;3;2;4;2;3;1;2;1;2;3;2;4;2;3;2;1;3;2];
%         lookuptable=[lookuptable;[1,2,1,2,1,2,1,2]];
end
% while isempty(lookuptable)||length(lookuptable)<4*refmax
%     for i = 1:50
%       lookuptable=[lookuptable;ceil(rand*MaxRefNumPerTrial/6+random('exp',MaxRefNumPerTrial/6))]; 
%     end
% %     lookuptable=[lookuptable;mklookuptable(MaxRefNumPerTrial+1,0.25)-1];
% %     lookuptable=[lookuptable;mklookuptable(MaxRefNumPerTrial,0.25)];
% % lookuptable=[lookuptable;[1;zeros(20,1)]];
% end
% make sure protection zone is fixed within a trial;
temp = [];
for i = 1:refmax/stimlistcnt
    temp_1 = [];
    while sum(temp_1)<stimlistcnt
        temp_1 = [temp_1;lookuptable(1)];
        lastnum = lookuptable(1);
        lookuptable = lookuptable(2:end);
    end
    residue = sum(temp_1)-stimlistcnt;
    if residue~=0
        rightnum = stimlistcnt-sum(temp_1(1:end-1));
        rightidx = find(lookuptable==rightnum);
        while isempty(rightidx)==1
            lookuptable=[lookuptable;mklookuptable(MaxRefNumPerTrial,0.25)];
            rightidx = find(lookuptable==rightnum);
        end
        temp_1(end) = lookuptable(rightidx(1));
        lookuptable = [lastnum; lookuptable(1:rightidx(1)-1);lookuptable(rightidx(1)+1:end)];
    end
    temp = [temp;temp_1];
end
o = set(o,'Lookuptable',lookuptable);
trcnt = length(temp);
% about static percentage
staticpercent = get(o,'StaticPercent');
if staticpercent==100
    stattr = trcnt;
    toltr = trcnt;
else
    stattr = round(trcnt/(100-staticpercent)*staticpercent);
    toltr = trcnt+stattr;
end
o=set(o,'NumberOfTrials',toltr)

%----- target randomization
taridx = get(o,'TargetIdx');
tarmax=get(o,'TargetMaxIndex');
while isempty(taridx)||length(taridx)<4*tarmax
   taridx = [taridx;randperm(tarmax)'];
end
%----- referance randomization        
refidx1 = randperm(refmax);
refidx = [refidx1(:),ones(refmax,1)];
        
temp2 = ones(trcnt,1);
varied = get(o,'Varied');
switch varied
%     case 'WithinTrial'
%         %--------------
%         tarindex = taridx(1:trcnt);
%         taridx = taridx(trcnt+1:end);
%         %--------------
%         statictrnum = floor(staticpercent*(refmax+trcnt)/100);
%         staticindices = randperm(refmax+trcnt);
%         staticidx = staticindices(1:statictrnum);
%         %----------
%         tar_dynamic_static = find(staticidx>refmax);
%         if ~isempty(tar_dynamic_static)%if target is static;
%             tmpid = staticidx(tar_dynamic_static)-refmax;
%             temp2(tmpid) = 0;
%         end    
%         %----------
%         ref_dynamic_static = find(staticidx<=refmax);
%         ref_ds = staticidx(ref_dynamic_static);
%         idx2 = findvector(refidx,ref_ds);
%         refidx(idx2,2) = 0;
    case 'AcrossTrial'
        %-------------
        refidx2 = [];
        for i = 1:refmax/stimlistcnt
            ref_temp = refidx1(find(refidx1>(i-1)*stimlistcnt & refidx1<=i*stimlistcnt));
            ref_temp2 = [ref_temp',ones(length(ref_temp),1)*i];
            refidx2 = [refidx2; ref_temp2];
            % i = which protection zone;
        end
        for i = 1:trcnt
            refidx2(sum(temp(1:i-1))+1:sum(temp(1:i)),3)=i;%i = trial number
        end
        tr_idx2 = randperm(trcnt);
        temp(:,2) = 1:trcnt; %c1-tr length; c2-tr number;
        temp = temp(tr_idx2,:); temp2 = temp2(tr_idx2);
        
        tr_idx = findvector(refidx2(:,3),tr_idx2);
        refidx2 = refidx2(tr_idx,:); %c1-stim list; c2-which protection zone; c3-trial number;
        refidx = [refidx2(:,1), ones(refmax,1),refidx2(:,3)];%c1-stim list; c2-Dyn/Stat; c3-trial number;

        protectid = [];
        for i = 1:trcnt
            if temp(i,1)==0
                tt = randperm(refmax/stimlistcnt);
                protectid = [protectid; tt(1)];
            else
                protectid = [protectid; refidx2(sum(temp(1:i-1,1))+1,2)];
            end
        end
        %-------------        
%         statictrnum = floor(staticpercent*trcnt/100);
%         staticindices = randperm(trcnt);
%         staticidx = staticindices(1:statictrnum);
%         temp2(staticidx) = 0;
        %------------
%         for i = 1:statictrnum
%             if staticidx(i) ~= 0
%                 idx2 = sum(temp(1:staticidx(i)-1))+1:sum(temp(1:staticidx(i))); 
%                 refidx(idx2,2) = 0;
%             end
%         end 
        %-------for target to be in the same protect zone as in reference;
        tarindex = [];
        for i = 1:trcnt
            while (~(taridx(1)<=protectid(i)*stimlistcnt && taridx(1)>(protectid(i)-1)*stimlistcnt)) || ...
                    (ismember(taridx(1),tarindex))
                %             check if all target lists in certain condition have been used;
                catnum = ceil(taridx(1)/stimlistcnt);
                catmember = ((catnum-1)*stimlistcnt+1):(stimlistcnt*catnum);
                allcatidx = ismember(catmember,tarindex);
                lg = isequal(allcatidx,ones(1,length(allcatidx)));
                if lg %or (target list can be repeted only if all lists have been used)
                    break;
                end
                taridx = circshift(taridx,-1);
            end
            while (~(taridx(1)<=protectid(i)*stimlistcnt && taridx(1)>(protectid(i)-1)*stimlistcnt))
               taridx = circshift(taridx,-1);
            end
            tarindex = [tarindex;taridx(1)];
            taridx = taridx(2:end);
        end  
end

trialidx = [temp,temp2(:),tarindex(:)]; %c1-trial length;c2-trial number;
% c3-dynamic/static for target only;c4-target list index;

%-----add static trials;
if staticpercent==100
    refidx(:,2) = 0;
    refidx = refidx(:,1:2);
    trialidx(:,3) = 0;
    trialidx = trialidx(:,[1,3,4]);
elseif staticpercent>0 
    factor = ceil(stattr/trcnt);
    temp_ref = repmat(refidx,factor,1);
    temp_tar = repmat(trialidx,factor,1);
    stat_tar = temp_tar(1:stattr,:);
    stat_tar(:,2) = stat_tar(:,2)+trcnt; stat_tar(:,3) = 0;
    stat_ref = temp_ref(1:sum(stat_tar),:);
    stat_ref(:,2) = 0; stat_ref(:,3) = stat_ref(:,3)+trcnt;
    tar_temp = [trialidx;stat_tar];
    refidx = [refidx;stat_ref];
    idx6 = randperm(toltr);
    tt3 = findvector(tar_temp(:,2),idx6);
    tar_temp = tar_temp(tt3,:);
    tt3 = findvector(refidx(:,3),idx6);
    refidx = refidx(tt3,:);
    trialidx = tar_temp(:,[1,3,4]);
    refidx = refidx(:,1:2);
elseif staticpercent==0
    trialidx = trialidx(:,[1,3,4]);
end

o = set(o,'TargetIdx',taridx);
o=set(o,'TrialIndices',trialidx); %c1-trial length; c2-dynamic/static for target only; c3-target list index;
o=set(o,'ReferenceIdx',refidx); %c1-stim list index for reference; c2-dynamic/static for reference;
tt=[];
for cnt1 = 1:size(trialidx,1)
    tt{cnt1} = zeros(1,trialidx(cnt1,1));
end
o=set(o,'ReferenceIndices',tt);            
exptparams.TrialObject= o;
%----------------------------- subfunction -------------------------------
function idx = findvector(matrix,vector)
% by Ling Ma, 06/2006.

idx = [];
for i = 1:length(vector)
    idx = [idx; find(matrix==vector(i))];
end



