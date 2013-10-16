function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% SVD 2012-10-19, generate sequences of References according to rules for
% sequences of repeated/varying targets/distracters
%

if nargin<3, RepIndex = 1;end
if nargin<4, RepOrTrial = 0;end   % default is its a trial call

% read the trial parameters
par = get(o);

if RepIndex==1 && RepOrTrial,
    disp('RepDetect: First trial, generating sequences');
    % if first run, generate o.Sequences:
    TargetIdx=par.TargetIdx;
    TrialCount=par.SequenceCount;
    ReferenceCountFreq=par.ReferenceCountFreq;
    ReferenceCountFreq=ReferenceCountFreq./sum(ReferenceCountFreq);
    
    if ~TrialCount || isempty(TargetIdx) || strcmp(par.ReferenceClass,'None'),
        o=set(o,'Sequences',{});
        o=set(o,'SequenceCategories',[]);
        o=set(o,'NumberOfTrials',TrialCount);
        return
    end
    
    RefPool=[];
    RefDuringTarPool=[];
    TarIdxSet=[];
    TargetIdxFreq=ones(size(TargetIdx))./length(TargetIdx);
    for ii=1:length(TargetIdxFreq),
        TarIdxSet=cat(2,TarIdxSet,ones(1,TrialCount.*TargetIdxFreq(ii)).*TargetIdx(ii));
    end
    TarIdxSet=shuffle(TarIdxSet);
    
    
    if strcmpi(par.Mode,'RepDetect'),
        TrialMult=2;
    else
        TrialMult=1;
    end
    Sequences=cell(TrialCount*TrialMult,1);
    SequenceCategories=zeros(1,TrialMult);
    ReferenceCount=zeros(1,TrialMult);
    
    for TrialIdx=1:(TrialCount*TrialMult)
        refcount=find(rand>[0 cumsum(ReferenceCountFreq)], 1, 'last' )-1;
        switch par.Mode,
            case 'RepDetect',
                if TrialIdx>TrialCount,
                    refcount=refcount+par.TargetRepCount;
                    tarcount=0;
                    SequenceCategory=1;
                else
                    tarcount=par.TargetRepCount;
                    SequenceCategory=0;
                end
                ThisSequence=zeros(refcount+tarcount,2);
                for rr=1:refcount,
                    if isempty(RefPool)
                        RefPool=shuffle(1:par.ReferenceMaxIndex);
                    end
                    ThisSequence(rr,:)=RefPool(1:2);
                    RefPool=RefPool(3:end);
                    if ismember(ThisSequence(rr,2),TargetIdx),
                        ThisSequence(rr,1:2)=ThisSequence(rr,[2 1]);
                    end
                end
                for tt=1:tarcount,
                    if isempty(RefDuringTarPool)
                        RefDuringTarPool=shuffle(1:par.ReferenceMaxIndex);
                    end
                    ThisSequence(refcount+tt,:)=...
                        [TarIdxSet(TrialIdx) RefDuringTarPool(1)];
                    RefDuringTarPool=RefDuringTarPool(2:end);
                end
            case 'RandOnly',
                refcount=refcount+par.TargetRepCount;
                ThisSequence=-ones(refcount,2);
                if TrialIdx<=TrialCount./2,
                    SequenceCategory=1;
                    RefPerSample=2;
                else
                    SequenceCategory=2;
                    RefPerSample=1;
                end
                for rr=1:refcount,
                    if length(RefPool)<RefPerSample,
                        RefPool=[RefPool shuffle(1:par.ReferenceMaxIndex)];
                    end
                    ThisSequence(rr,1:RefPerSample)=RefPool(1:RefPerSample);
                    RefPool=RefPool((1+RefPerSample):end);
                    if ismember(ThisSequence(rr,2),TargetIdx),
                        ThisSequence(rr,1:2)=ThisSequence(rr,[2 1]);
                    end
                end
            case 'RandAndRep',
                refcount=refcount+par.TargetRepCount;
                ThisSequence=-ones(refcount,2);
                if TrialIdx<=TrialCount./4,
                    SequenceCategory=1;
                    RefPerSample=2;
                    TarPerSample=0;
                elseif TrialIdx<=TrialCount./2,
                    SequenceCategory=2;
                    RefPerSample=1;
                    TarPerSample=0;
                elseif TrialIdx<=TrialCount.*3/4,
                    SequenceCategory=3;
                    RefPerSample=1;
                    TarPerSample=1;
                else
                    SequenceCategory=4;
                    RefPerSample=0;
                    TarPerSample=1;
                end
                for rr=1:refcount,
                    if TarPerSample,
                        ThisSequence(rr,1)=TarIdxSet(TrialIdx);
                    end
                    if length(RefPool)<RefPerSample,
                        RefPool=[RefPool shuffle(1:par.ReferenceMaxIndex)];
                    end
                    ThisSequence(rr,TarPerSample+(1:RefPerSample))=...
                        RefPool(1:RefPerSample);
                    RefPool=RefPool((1+RefPerSample):end);
                    if ~TarPerSample && ismember(ThisSequence(rr,2),TargetIdx),
                        ThisSequence(rr,1:2)=ThisSequence(rr,[2 1]);
                    end
                end
                if TarPerSample,
                    refcount=0;
                end
                % no more Modes
        end
        Sequences{TrialIdx}=ThisSequence;
        ReferenceCount(TrialIdx)=refcount;
        SequenceCategories(TrialIdx)=SequenceCategory;
    end
    
    o=set(o,'Sequences',Sequences);
    o=set(o,'ReferenceCount',ReferenceCount);
    o=set(o,'SequenceCategories',SequenceCategories);
    o=set(o,'NumberOfTrials',TrialCount);
end


if ~RepOrTrial,
    % run after each trial to check if null trial should be subbed in
    
    trialidx=exptparams.InRepTrials;
    
    if strcmpi(exptparams.BehaveObjectClass,'Passive') || ...
            strcmpi(exptparams.Performance(end).ThisTrial,'Hit'),
        % either passive or last trial was a hit. either way,
        % we don't need to adjust anything
        InsertNull=0;
        RepeatLast=0;
    else
        if strcmpi(exptparams.Performance(end).ThisTrial,'Miss'),
            % no null trials after miss
            InsertNull=0;
        else            
            % insert a Null trial if NullTrials flag selected
            InsertNull=par.NullTrials;
        end
        if par.ThisRepIdx(trialidx)<par.SequenceCount,
            % repeat last trial if it was not a null trial
            RepeatLast=1;
        else
            RepeatLast=0;
        end
    end
    
    if RepeatLast,
        fprintf('Miss/FA: Repeating error trial sequence %d\n',...
            par.ThisRepIdx(trialidx));
        RemainingTrialCount=length(par.ThisRepIdx)-trialidx;
        RepeatAtIdx=ceil(rand*RemainingTrialCount)+trialidx;
        par.ThisRepIdx=[par.ThisRepIdx(1:RepeatAtIdx);
            par.ThisRepIdx(trialidx); ...
            par.ThisRepIdx((RepeatAtIdx+1):end)];
        par.NumberOfTrials=par.NumberOfTrials+1;
    end
    if InsertNull
        nullidx=ceil(rand*par.SequenceCount)+par.SequenceCount;
        fprintf('False Alarm: Inserting Null trial sequence %d\n',nullidx);
        
        par.ThisRepIdx=[par.ThisRepIdx(1:trialidx); nullidx; ...
            par.ThisRepIdx((trialidx+1):end)];
        par.NumberOfTrials=par.NumberOfTrials+1;
    end
    %par.ThisRepIdx
        
    o=set(o,'ThisRepIdx',par.ThisRepIdx);
    o=set(o,'NumberOfTrials',par.NumberOfTrials);
    
else
    % new repetition. reset ThisRepIdx, which indexes into par.SequenceIdx
    disp('RepDetect: New repetition, shuffling sequence order');
    TotalTrials=par.SequenceCount;
    ThisRepIdx=shuffle(1:TotalTrials)';
    o = set(o,'ThisRepIdx',ThisRepIdx);
    o = set(o,'SequenceIdx',[par.SequenceIdx;ThisRepIdx]);
    o = set(o,'NumberOfTrials',TotalTrials);
end


exptparams.TrialObject = o;
