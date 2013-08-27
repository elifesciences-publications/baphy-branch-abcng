function o = ObjUpdate (o);
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds
% pinbo, April 2006

ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
torc=get(o,'Torc');
isi=get(o,'InterStimInterval');
refnum=get(o,'MaxRefNumPerTrial');
fs=[];
if ~strcmp(lower(torc),'none') && length(strfind(lower(torc),'distractor'))==0
    torchandle=Torc;
    torchandle=set(torchandle,'FrequencyRange',torc);
    torchandle=set(torchandle,'Duration',isi);  
    torchandle=set(torchandle,'Rates','4:4:48');  %default TORC rates used for MTS
    torchandle=set(torchandle,'PreStimSilence',0.0);
    torchandle=set(torchandle,'PostStimSilence',0.0);
    fs=get(torchandle,'SamplingRate');
elseif length(strfind(lower(torc),'distractor'))>0
    torchandle=PfCsoundset;
    if strcmpi(torc,'C:distractor')
        dis_dur=isi;
        dis_pre=0;
        dis_post=0; else
        dis_dur=0.3;
        dis_pre=(isi-dis_dur)/2;
        dis_post=(isi-dis_dur)/2; end
    torchandle=set(torchandle,'Duration',dis_dur);
    torchandle=set(torchandle,'PreStimSilence',dis_pre);
    torchandle=set(torchandle,'PostStimSilence',dis_post);
    fs=get(torchandle,'SamplingRate');
else
    o=set(o,'Torchandle',[]);
    o=set(o,'TorcList',[]);
end
if ~isempty(tar)
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    o=set(o,'TargetClass',class(tar));
    fs=[fs get(tar,'SamplingRate')];
end
if ~isempty(ref)
    o = set(o,'ReferenceMaxIndex',get(ref,'MaxIndex'));
    o=set(o,'ReferenceClass',class(ref));
    fs=[fs get(ref,'SamplingRate')];
end
if length(fs)>0
    o=set(o,'SamplingRate',max(fs));
    if ~strcmp(lower(torc),'none')
        torchandle=set(torchandle,'SamplingRate',max(fs));
        torchandle=ObjUpdate(torchandle);
        o=set(o,'Torchandle',torchandle);
        %if isempty(get(o,'TorcList'))
            if strcmpi(torc,'A:distractor')
                o=set(o,'TorcList',1:20);
            elseif strcmpi(torc,'B:distractor') || strcmpi(torc,'C:distractor')   %
                o=set(o,'TorcList',1:10);
            else
                o=set(o,'TorcList',1:30); end
        %end
    else
        o=set(o,'Torchandle',[]);
        o=set(o,'TorcList',[]);
    end
end
if ~isempty(tar) & ~isempty(ref)
    ref=set(ref,'SamplingRate',max(fs));
    tar=set(tar,'SamplingRate',max(fs));
    if strcmp(get(o,'FrequencyVaried'),'fixed')
        if ~strcmpi(get(ref,'Type'),'Shepard')
            ref=set(ref,'Type','si'); ref=ObjUpdate(ref); end
        if ~strcmpi(get(tar,'Type'),'Shepard')
            tar=set(tar,'Type','si'); tar=ObjUpdate(tar); end
    end
    o=set(o,'ReferenceHandle',ref);
    o=set(o,'TargetHandle',tar);
    o=set(o,'runclass',RunClassTable(ref,tar));
    
%     if length(get(o,'TrialIndices'))==0
%         o=randomizesequence(o);  end
elseif isempty(ref) | isempty(tar)
    o=set(o,'TrialIndices',[]);
end



    
    


