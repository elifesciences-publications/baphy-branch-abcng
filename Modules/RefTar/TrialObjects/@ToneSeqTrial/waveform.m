function [TrialSound, events , o] = waveform (o,idx);
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. 
% Idx stimulus index or Serial Trial Number
% Pingbo, last modified at 2/01/2006

TrialIndex = get(o,'TrialIndices');     % 
if isempty(TrialIndex)
    o=randomizeSequence(o);
    TrialIndex = get(o,'TrialIndices');     end
o=ObjUpdate(o);
fs = get(o, 'SamplingRate');
RefObject = get(o,'ReferenceHandle');        % get reference object
TarObject=get(o,'TargetHandle');             % get target object
TorcObject=get(o,'TorcHandle');
pretrial=get(o,'PreTrialSilence');
posttrial=get(o,'PostTrialSilence');

gaplist=get(o,'MultipleGap');   %add on 12/15.06 for multiple tone gap varied by trials.
if length(gaplist)>1 | (length(gaplist)==1 & gaplist>0)
    ToneGapIdx=get(o,'ToneGapIndices');
    TarObject=set(TarObject,'NoteGap',gaplist(ToneGapIdx(idx)));
    RefObject=set(RefObject,'NoteGap',gaplist(ToneGapIdx(idx)));
end

isigap=get(o,'InterStimInterval');
Refnames = get(RefObject,'Names');
refAttenDB=get(o,'RefAttenDB');
refAttenDB=10^(-refAttenDB/20);     %convert DB into amplitude ratio

if length(TorcObject)>0
    torclist=get(o,'TorcList');
    DBatten=get(o,'TorcAttenDB');
    DBatten=10^(-DBatten/20);     %convert DB into amplitude ratio
    torcseq=[];
    for i=1:length(TrialIndex)
        torcseq(i)=TrialIndex{i}(1)+1;
    end
    torcstart=sum(torcseq(1:idx-1))+1;   %torc index number
end

LastEvent=pretrial;  %in sec. silence before the sound start
presilence=zeros(fs*pretrial,1);
postsilence=zeros(fs*posttrial,1);
refw=[];refeve=[];
for j=1:TrialIndex{idx}(1)
    [refw1,refeve1]=waveform(RefObject,TrialIndex{idx}(j+1));          %ref Tone Sequence
    refw1=refw1*refAttenDB;
    refeve1(2).Note=[refeve1(2).Note '$'];                             %'$' mark the begin of the Tone sequence
    refstr=['reference, ' num2str(TrialIndex{idx}(j+1))];
    if length(TorcObject)>0
        [torcw,torcev]=waveform(TorcObject,torclist(torcstart+j-1));   %make TORC
        torcw=torcw*DBatten;
        torcstr=['reference, ' num2str(torclist(torcstart+j-1))];
        if j==1
            refw1=[presilence;torcw;refw1];                            %add pre-silence and combine with TORC
            torcev(1).StartTime=torcev(1).StartTime-pretrial;        %shift the trial start time 
        else
            refw1=[torcw;refw1];
        end
        [torcev,LastEvent]=updateEvtime(torcev,torcstr,LastEvent,idx);
        [refeve1,LastEvent]=updateEvtime(refeve1,refstr,LastEvent,idx);
        refeve1=[torcev refeve1];
    else
        torcw=zeros(fs*isigap,1);                                      %silence period if without TORC
        if j==1
            refw1=[presilence(:);refw1(:);torcw(:)];
            refeve1(1).StartTime=refeve1(1).StartTime-pretrial; else
            refw1=[refw1(:);torcw(:)];
        end
        refeve1(end).StopTime=refeve1(end).StopTime+isigap;
        [refeve1,LastEvent]=updateEvtime(refeve1,refstr,LastEvent,idx);
    end    
    if j==1
        refw=refw1;
        refeve=refeve1;
    else
        refw=[refw(:);refw1(:)];
        refeve=[refeve refeve1];
    end
end
freqRange=lower(get(o,'FrequencyVaried'));
%reftype=get(RefObject,'Type');
if strcmp(freqRange,'bytrial-1')  %reference and target frequency should match
    reffreq=Refnames{TrialIndex{idx}(end-1)};
    reffreq=str2num(reffreq);
    tarfreq=get(TarObject,'Frequency');
    freqlow=find(tarfreq==min(tarfreq));
    freqhigh=find(tarfreq==max(tarfreq));
    tarfreq([freqhigh freqlow])=[max(reffreq) min(reffreq)];
    TarObject=set(TarObject,'Type','si');
    TarObject=set(TarObject,'Frequency',tarfreq);   
    TrialIndex{idx}(end)=1;
end
if length(TrialIndex{idx})-1>TrialIndex{idx}(1)
    [tarw,tareve]=waveform(TarObject,TrialIndex{idx}(end));
    tareve(2).Note=[tareve(2).Note '$'];                             %'$' mark the begin of the Tone sequence
    tarstr=['target,' num2str(TrialIndex{idx}(end))];
else
    tarw=[];
    tareve=[];
    tarstr='';
end

if ~isempty(TorcObject)
    [torcw,torcev]=waveform(TorcObject,torclist(torcstart+TrialIndex{idx}(1)));   %make TORC on the list
    torcw=torcw*DBatten;
    tartorc=ceil(rand(1)*length(torclist));
    [torcwTar,torcevTar]=waveform(TorcObject,tartorc); %Torc random pick
    torcwTar=torcwTar*DBatten;
    [torcev,LastEvent]=updateEvtime(torcev,['reference,' num2str(torclist(torcstart+TrialIndex{idx}(1)))],LastEvent,idx);   %Torc before target
    [tareve,LastEvent]=updateEvtime(tareve,tarstr,LastEvent,idx);      %target sequence
    [torcevTar,LastEvent]=updateEvtime(torcevTar,['target,' num2str(tartorc)],LastEvent,idx);   %torc after target
    tarw=[torcw(:);tarw(:);torcwTar(:)];
    tareve=[torcev tareve torcevTar];
elseif ~isempty(tareve)
    [tareve,LastEvent]=updateEvtime(tareve,tarstr,LastEvent,idx);
    tarw=[tarw(:);zeros(fs*isigap,1)];  %add one ISI
    tareve(end).StopTime=tareve(end).StopTime+isigap;
end
if ~isempty(tareve)
    tareve(end).StopTime=tareve(end).StopTime+posttrial; else
    refeve(end).StopTime=refeve(end).StopTime+posttrial;
end
if TrialIndex{idx}(1)==0   %this block for the trial without reference only
    refw=presilence;
    tareve(1).StartTime=tareve(1).StartTime-pretrial;        %shift the trial start time
end
TrialSound=[refw(:);tarw(:);postsilence(:)];
TrialSound=5*TrialSound/max(TrialSound);  %re-normalizing the scale
% if strcmpi(get(RefObject,'Type'),'Shepard')
%     rlist=str2num(char(get(RefObject,'Names')));
%     tfreq=get(TarObject,'Frequency');
%     rfreq=rlist(TrialIndex{idx}(end-1),:);
%     if TrialIndex{idx}(end)==1 && rfreq(2)==tfreq(4)  
%         %sham: ref & tar percevied the same direction
%         tareve=subfun_STR_modify(tareve,'target','reference');
%     elseif isempty(tareve)
%         tfreq=rlist(TrialIndex{idx}(end),:);  %last reference
%         if rfreq(2)~=tfreq(2)
%             refeve(end-5:end)=subfun_STR_modify(refeve(end-5:end),'reference','target');
%         end
%     end
% end
events=[refeve tareve];

%=============================================================
function [ev,LastEvent]=updateEvtime(ev,tagSTR,LastEvent,idx)
if isempty(ev), return; end
for i=1:length(ev)
    ev(i).Note = [ev(i).Note ' ,' tagSTR];
    ev(i).Trial = idx;
    ev(i).StartTime=ev(i).StartTime+LastEvent;
    ev(i).StopTime=ev(i).StopTime+LastEvent;    
end
LastEvent = ev(end).StopTime;

%=========================================
function e=subfun_STR_modify(e,s1,s2)
for i=1:length(e)
    e(i).Note=strrep(e(i).Note,s1,s2);
end

% %============================================================
% function [r] = rms(x)
% if size(x,1)>size(x,2)
%   x = x';
% end
% 
% if size(x,1) == 1
%   r = sqrt(x*x'/size(x,2));
% else
%   r(1) = sqrt(x(1,:)*x(1,:)'/size(x,2));
%   r(2) = sqrt(x(2,:)*x(2,:)'/size(x,2));
% end
