function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% SVD 2012-10-19, generate sequences of References according to rules for
% sequences of repeated/varying targets/distracters
%

global REPDETECT_NOISE_SAMPLES

if nargin<3, RepIndex = 1;end
if nargin<4, RepOrTrial = 0;end   % default is its a trial call

% read the trial parameters
par = get(o);

if RepIndex==1 && RepOrTrial,
    
    % if first run, generate o.Sequences:
    disp('RepDetect: First trial, generating sequences');
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
    TargetIdxFreq=ones(size(TargetIdx))./length(TargetIdx);
    TarIdxSet=[];
    for ii=1:length(TargetIdxFreq),
        TarIdxSet=cat(2,TarIdxSet,ones(1,ceil(TrialCount.*TargetIdxFreq(ii))).*TargetIdx(ii));
    end
    for ii=1:(length(TarIdxSet)-1),
        % evenly distribute targets
        n=hist(TarIdxSet(ii:end),TargetIdx);
        mm=find(n==max(n), 1);
        mmm=find(TarIdxSet(ii:end)==TargetIdx(mm), 1)+ii-1;
        TarIdxSet([ii mmm])=TarIdxSet([mmm ii]);
    end
    
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
            case {'RepDetect','RdtWithSingle'},
                if TrialIdx>TrialCount,
                    refcount=refcount+round(par.TargetRepCount./2);
                    tarcount=0;
                    SequenceCategory=1;
                else
                    tarcount=par.TargetRepCount;
                    SequenceCategory=0;
                end
                if TrialIdx<=TrialCount./2 && strcmpi(par.Mode,'RdtWithSingle'),
                    RefPerSample=1;
                else
                    RefPerSample=2;
                end
                ThisSequence=-ones(refcount+tarcount,2);
                for rr=1:refcount,
                    if length(RefPool)<3,
                        RefPool=[RefPool shuffle(1:par.ReferenceMaxIndex)];
                    end
                    if rr>1,
                        cc=0;
                        while cc<10 && any(RefPool(1)==ThisSequence(rr-1,:)),
                            % move repeating sample to end of RefPool;
                            RefPool=[RefPool(2:end) RefPool(1)];
                            cc=cc+1;
                        end
                        cc=0;
                        while cc<10 && any(RefPool(2)==ThisSequence(rr-1,:)),
                            % move repeating sample to end of RefPool;
                            RefPool=[RefPool(1) RefPool(3:end) RefPool(2)];
                            cc=cc+1;
                        end
                    end
                    
                    ThisSequence(rr,1:RefPerSample)=RefPool(1:RefPerSample);
                    RefPool=RefPool((1+RefPerSample):end);
                    if ismember(ThisSequence(rr,2),TargetIdx),
                        ThisSequence(rr,1:2)=ThisSequence(rr,[2 1]);
                    end
                end
                for tt=1:tarcount,
                    if RefPerSample==2,
                        if isempty(RefDuringTarPool)
                            RefDuringTarPool=shuffle(1:par.ReferenceMaxIndex);
                        end
                        ThisSequence(refcount+tt,:)=...
                            [TarIdxSet(TrialIdx) RefDuringTarPool(1)];
                        RefDuringTarPool=RefDuringTarPool(2:end);
                    else
                        ThisSequence(refcount+tt,1)=TarIdxSet(TrialIdx);
                    end
                end
                
            case {'RandOnly','RandSingle'},
                refcount=refcount+par.TargetRepCount;
                ThisSequence=-ones(refcount,2);
                if strcmpi(par.Mode,'RandOnly') && TrialIdx<=TrialCount./2,
                    SequenceCategory=1;
                    RefPerSample=2;
                else
                    % RandSingle always just one Reference
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

    disp('RepDetect: generating background noise samples');
    ReferenceDuration=get(par.ReferenceHandle,'Duration');
    fs=get(par.ReferenceHandle,'SamplingRate');
    LowFreq=get(par.ReferenceHandle,'LowFreq');
    HighFreq=get(par.ReferenceHandle','HighFreq');
    REPDETECT_NOISE_SAMPLES=zeros(round(ReferenceDuration.*fs),...
        par.ReferenceMaxIndex);
    saverandstate=rand('state');
    rand('state',2);
    saverandnstate=randn('state');
    randn('state',3);
    for sampleidx=1:par.ReferenceMaxIndex,
        % gnoise(duration_ms,l_co[Hz],h_co[Hz],[Level(dB)],[circular(0/1)],[SAMPLERATE])
        tw=gnoise(ReferenceDuration*1000,LowFreq,HighFreq,-25,0,fs);
        REPDETECT_NOISE_SAMPLES(:,sampleidx)=tw./max(abs(tw));
    end
    
   % restore random number generator to previous state
   rand('state',saverandstate);
   randn('state',saverandnstate);
    
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
        if strcmpi(exptparams.Performance(end).ThisTrial,'Miss')||...
                strcmpi(exptparams.Performance(end).ThisTrial,'Corr.Rej.'),
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
