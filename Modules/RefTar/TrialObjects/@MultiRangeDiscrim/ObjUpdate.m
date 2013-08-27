function o = ObjUpdate (o);
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds
% pinbo, April 2006

ref = get(o,'ReferenceHandle');
refatten=get(o,'RefAttenDB');
fs=[];
if ~isempty(ref)
    o=set(o,'ReferenceClass',class(ref));
    Type=deblank(get(ref,'Type'));
    
    if any(strcmpi(Type,{'Amtone2','Amtone2a'}))
        setnum=2; 
    elseif strcmpi(Type,'Amtone2c')
        setnum=get(ref,'MaxIndex')/get(ref,'ToneNumber');
    else
        setnum=1;
    end
    tonenum=get(ref,'ToneNumber');
    refmax=tonenum*setnum;

    fs=get(ref,'SamplingRate');
    tindex=[1:refmax]';
    tindex=[tindex(:) tindex(:)];

    numrange=get(ref,'NumFreqRange');
    tar=get(ref,'TarRange');
    if setnum>1
        tindex(:,2)=rem(tindex(:,2)-1,tonenum)+1;
    end
    tindex(:,2)=2-mod(ceil(tindex(:,2)/(tonenum/numrange)),2);
    tindex(tindex(:,2)~=tar,2)=0;   %0 for negative trials
    if strcmpi(Type,'Amtone2c')
       tindex(ceil(ceil([1:end]/tonenum)/(tonenum/numrange))==tar,2)=2;  %target range for 2nd feature (AM)
    end
    if length(refatten)>1           %for multiple intensity levels
      tindex0=[];
      for i=1:length(refatten)
        tindex(:,3)=refatten(i);
        tindex0=[tindex0;tindex];
      end
      tindex=tindex0;
      refmax=size(tindex,1);
    end
    o=set(o,'Refindices',tindex);
    o=set(o,'SamplingRate',fs);
    o=set(o,'NumberofTrials',refmax);
    if isempty(get(o,'TrialIndices')) || size(get(o,'TrialIndices'),1)~=size(tindex,1)
      o=set(o,'TrialIndices',tindex);
    end
    
    ref=set(ref,'MaxIndex',refmax);
    ref=ObjUpdate(ref);
    o=set(o,'ReferenceHandle',ref);
elseif isempty(ref)
  o=set(o,'TrialIndices',[]);
end



    
    


