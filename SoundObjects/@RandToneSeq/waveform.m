function [w, ev]=waveform (o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object TonesSequence
%
%Pingbo, Jan 2007.

fs = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
prestim=zeros(round(PreStimSilence*fs),1);
poststim=zeros(round(PostStimSilence*fs),1);
Names = get(o,'Names');
if strcmpi(get(o,'Type'),'Seq_Daniel')    
    sindex=2-mod(index,2);
    w=wavread([fileparts(which('randToneSeq')) '\sounds\' Names{sindex}]);
    if index>2  %for last rep of seq which same in seq1 and seq2
        sonset=[3 3 4 4 5]*0.875;
        n=round(sonset(index-2)*fs);
        w(1:n)=0;
    end    
    w=[prestim(:);w(:);poststim(:)];
    w = 5 * w/max(abs(w));
    Duration=length(w)/fs;
    %generate the event structure:
    ev= struct('Note',['PreStimSilence , ' Names{index}],...
        'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
    ev(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
        ,PreStimSilence, 'StopTime', PreStimSilence+Duration, 'Trial',[]);
    ev(3) = struct('Note',['PostStimSilence , ' Names{index}],...
        'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
        return;
elseif strcmpi(get(o,'Type'),'New_Daniel')
    [w0,ss]=extract_sub(fs);
    switch Names{index}
        case {'up','upr'};
            T2=2:12;               %increasing
        case {'dw','dwr'};
            T2=12:-1:2;            %decreasing
        case {'rd','rdr'}
            T2=randperm(11)+1;     %random
        case 'sig'                 
            T2=randperm(12);       %random single chrod
    end
    T1=ones(size(T2));
    if strcmpi(Names{index}(end),'r')
        T1=T2; T2=ones(size(T1)); end
    w=[];
    ev=[];
    for i=1:12
        if length(T2)==12 || i>1
            if length(T2)==12
                w=[w;w0(:,T2(i))];
                T2lab=NaN;
                T1lab=T2(i);
                Tscale=1;
            elseif i>1
                w=[w;w0(:,T1(i-1));zeros(size(w0,1),1)];
                w=[w;w0(:,T2(i-1))]; 
                T1lab=T1(i-1)-1;
                T2lab=T2(i-1)-1;
                Tscale=3;     %2(tones)+1 (interval)
            end

            if i<12   %1 sec onset-onset silence
                w=[w;zeros(fs-Tscale*size(w0,1),1)]; end
            if (i==2 && length(T2)==11) || ((i==1 && length(T2)==12))
                w=[prestim(:);w];
                ev=ev_struct(ev,sprintf('%s-%d-%d',Names{index},T1lab,T2lab),PreStimSilence,Tscale*size(w0,1)/fs,0);
            elseif i==12
                w=[w;poststim(:)];
                ev=ev_struct(ev,sprintf('%s-%d-%d',Names{index},T1lab,T2lab),1-Tscale*size(w0,1)/fs,Tscale*size(w0,1)/fs,PostStimSilence);
            else
                ev=ev_struct(ev,sprintf('%s-%d-%d',Names{index},T1lab,T2lab),1-Tscale*size(w0,1)/fs,Tscale*size(w0,1)/fs,0);
            end
        end
    end
    w = 5 * w/max(abs(w));
    return;
end

% the parameters of Stream_AB object
NoteDur = get(o,'NoteDur');
NoteGap = get(o,'NoteGap'); % duration is second

% now generate a tone with specified frequency:
t=0:1/fs:NoteDur-1/fs;
gap=zeros(round(NoteGap*fs),1);
NoteDur=length(t)/fs;
NoteGap=length(gap)/fs;
NoteNum=get(o,'NoteNumber');
w=[];ev=[];shift=[];

if strcmpi(get(o,'Type'),'oddball2');
    F=get(o,'CenterFrequency');
    F(2)=round(F*2^(0.5));     %two frequencis
    A=[0 -10];                 %two intensity level
    D=[1 0.5];                 %two durtions
    [s,r]=strread(Names{index},'%s%s','delimiter','_');  %standard
    d=strread(r{1},'%s','delimiter','+');                %deviants
    dd=[];
    for i=1:length(d)
        dpercnt=str2num(d{i}((d{i}<65)));   %divient percent
        dd=[dd;round(ones(NoteNum*dpercnt/100,1))*i];
    end
    ss=[dd;zeros(NoteNum-length(dd)-5,1)];   %0 for standard
    sstem=ss(randperm(NoteNum-5));
    n=diff(find(sstem));  %number of consecutive devient
    while sum(n==1)>5
        sstem=[ss(randperm(NoteNum-5))];
        n=diff(find(sstem));
    end
    ss=[zeros(5,1);sstem];
    for i=1:length(ss)
       if ss(i)==0  %standard
           stem=s{1};
       else  %deviants
           stem=d{ss(i)};
       end
       stem(stem<65)=[];
       ftem=F([stem(1)>=97]+1);  %freq
       atem=A([stem(2)>=97]+1);  %amp
       dtem=D([stem(3)>=97]+1);  %duration
       
       w0=addenv(10^(atem/20)*sin(2*pi*ftem*t(1:length(t)*dtem)),fs);      
       w=[w;w0(:);zeros(length(t)*(1-dtem),1)];
       if i<length(ss)
           w=[w;gap]; end
       
       evt_note=['Note ' sprintf('%d_%d_%3.1f',atem,ftem,dtem)];
       if i==1
          w=[prestim;w];
          ev=ev_struct(ev,evt_note,PreStimSilence,NoteDur,NoteGap);
       elseif i==length(ss)
          w=[w;poststim];
          ev=ev_struct(ev,evt_note,0,NoteDur,PostStimSilence); 
       else
          ev=ev_struct(ev,evt_note,0,NoteDur,NoteGap);
       end       
    end
    w = 5 * w/max(abs(w));    
    return; %end of oddball2
elseif strcmpi(get(o,'Type'),'3stream');  %added on 2/20/2012
    strm3=str2num(Names{index});
    NoteNum=floor(NoteNum/2); %tone note number for each stream
    for i=1:NoteNum
        tem1=addenv(sin(2*pi*strm3(1)*t),fs);
        tem2=addenv(sin(2*pi*strm3(2)*t),fs);
        if strm3(3)==1   %light stream
            tem3=[ones(length(t),1);]*5;
        else              %3rd tone stream
            tem3=addenv(sin(2*pi*strm3(3)*t),fs);
        end
        tem12=[tem1(:);gap(:)];
        if strm3(4)==1
            tem12(1:length(tem3),3)=tem3(:);
            tem12(end+[1:length(tem2)],2)=tem2(:);
            evt_note1=['Note ' sprintf('%d %d',strm3(1),strm3(3))];   %tone stream1 & 3 stream
            evt_note2=['Note ' sprintf('%d',strm3(2))];               %tone stream2
        elseif strm3(4)==2
            tem12(end+[1:length(tem2)],2:3)=[tem2(:) tem3(:)];
            evt_note1=['Note ' sprintf('%d',strm3(1))];               %tone stream1
            evt_note2=['Note ' sprintf('%d %d',strm3(2),strm3(3))];   %tone stream2 & 3rd stream
        else
            tem12(end+[1:length(tem2)],2)=tem2(:);
            tem12(:,3)=0;
            evt_note1=['Note ' sprintf('%d',strm3(1))];               %tone stream1
            evt_note2=['Note ' sprintf('%d',strm3(2))];   %tone stream2
        end
        w=[w;tem12];
        if i==1
            w=[prestim(:) prestim(:) prestim(:);w;gap(:) gap(:) gap(:)];
            ev=ev_struct(ev,evt_note1,PreStimSilence,NoteDur,NoteGap);
            ev=ev_struct(ev,evt_note2,0,NoteDur,NoteGap);
        elseif i==NoteNum
            ev=ev_struct(ev,evt_note1,0,NoteDur,NoteGap);
            ev=ev_struct(ev,evt_note2,0,NoteDur,PostStimSilence);
            w=[w;poststim(:) poststim(:) poststim(:)];
        else
            w=[w;gap(:) gap(:) gap(:)];
            ev=ev_struct(ev,evt_note1,0,NoteDur,NoteGap);
            ev=ev_struct(ev,evt_note2,0,NoteDur,NoteGap);
        end
    end
    if strm3(3)==1  %3rd stream is light
        w=[sum(w(:,1:2),2) w(:,3)];
        w(:,1) = 5 * w(:,1)/max(abs(w(:,1)));
        if max(w(:,2))>0
            w(:,2)=5 * w(:,2)/max(abs(w(:,2))); end
    else            %3rd stream is a tone
        w=sum(w,2);
        %this make each of tone streams has equal inter=nsity at 2- and 3- stream situation 
        if strm3(4)==0  %2 streams
            w = 2.5 * w/max(abs(w)); else
            w = 5 * w/max(abs(w));
        end
    end
    return;   %3 streams
end

if strcmpi(get(o,'Type'),'RShepard')
    [w0,ss]=extract_sub(fs);
    Rep=round(NoteNum/12); %repeats of 12 tones
    NoteNum=[];
    for i=1:Rep
        if index==1  %ascending
            NoteNum=[NoteNum 1:12];
        elseif index==2 %descending
            NoteNum=[NoteNum 12:-1:1];
        else  %random
            NoteNum=[NoteNum randperm(12)];
        end           
    end
    for i=1:length(NoteNum)
        w=[w;w0(:,NoteNum(i))];
        if i<length(NoteNum)
            %w=[w;gap];
            w=[w;zeros(size(w0,1),1)];  %interval
            if i==1
                w=[prestim;w];
                ev=ev_struct(ev,num2str(NoteNum(i)-1,'Shepard-%02d'),PreStimSilence,NoteDur,NoteGap);
            else
                ev=ev_struct(ev,num2str(NoteNum(i)-1,'Shepard-%02d'),0,NoteDur,NoteGap);
            end
        else
            w=[w;poststim];
            ev=ev_struct(ev,num2str(NoteNum(i)-1,'Shepard-%02d'),0,NoteDur,PostStimSilence);
        end
    end
    w = 5 * w/max(abs(w));
    return; end   %end of shepard seq

Frequency = str2num(Names{index});
if strcmpi(get(o,'Type'),'AddStream')
    stream=sin(2*pi*Frequency*t);  %add a stream frequency
    stream_idx=zeros(NoteNum,1);
    stream_idx(round(NoteNum/3):round(NoteNum*2/3))=1;
elseif strcmpi(get(o,'Type'),'AddStream2')   %new stream seq
    tem=1:length(Names); tem(index)=[];  %remove stream frequency
    for i=1:ceil(NoteNum/length(tem))
        stream_idx(i,:)=randperm(length(tem));
    end
    stream_idx=stream_idx';
    stream_idx=stream_idx(:);
    stream_idx=tem(stream_idx);
    stream_idx(round(NoteNum/3):round(NoteNum*2/3))=index;
    stream_idx=str2double(Names(stream_idx))';
else
    stream=0;  end %no stream

for i=1:ceil(NoteNum/2)
    shift=[shift;randperm(2)]; end
shift(shift==2)=-1;
shift=shift(:);
for i=1:NoteNum
    if i>1, index=index+shift(i); end
    cnt=0;
    while index<1 || index>length(Names)
        index=index-shift(i);
        if i==NoteNum && index==1
            index=index+1;
        elseif i==NoteNum && index==length(Names)
            index=index-1;
        else
            shift=shift([1:end i]);
            shift(i)=[];   %move current step to the end of the list
            index=index+shift(i);
            cnt=cnt+1;
            disp(['try-' num2str(cnt)]);
            if cnt==100
                disp('why?');
            end
        end
    end
    %if index<1, index=1;%length(Names);
    %elseif index>length(Names), index=length(Names); end%1; end        
    Frequency = str2num(Names{index});
    if strcmpi(get(o,'Type'),'AddStream')   %modified on 11/15/2010 by pby
%     if i>=round(NoteNum/3) && i<=round(NoteNum*2/3)  %added on 12/29/09 by pby
        w0=addenv(sin(2*pi*Frequency*t)+stream*stream_idx(i),fs);
    elseif strcmpi(get(o,'Type'),'AddStream2')   %modified on 11/15/2010 by pby
        w0=addenv(sin(2*pi*Frequency*t)+sin(2*pi*stream_idx(i)*t),fs);
    else
        w0=addenv(sin(2*pi*Frequency*t),fs);
    end
    w=[w;w0(:)];
    if i<NoteNum
       w=[w;gap(:)];       
       evt_note=['Note ' Names{index}];
       if strcmpi(get(o,'Type'),'AddStream2')
           evt_note=[evt_note num2str(stream_idx(i),'-%d')];
       end
       if i==1
          w=[prestim;w];
          ev=ev_struct(ev,evt_note,PreStimSilence,NoteDur,NoteGap);
       else
          ev=ev_struct(ev,evt_note,0,NoteDur,NoteGap);
       end
    else
       w=[w;poststim];
       ev=ev_struct(ev,evt_note,0,NoteDur,PostStimSilence);
    end
end
w = 5 * w/max(abs(w));

%add 5 ms rise/fall time ===================================
function s=addenv(s1,fs);
f=ones(size(s1));
pn=round(fs*0.005);    % 5 ms rise/fall time 
up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
f = [up ones(1,length(s1)-2*pn) down]';
s=s1(:).*f(:);

%create Event structure======================================
function ev=ev_struct(ev,Name,PreStim,Duration,PostStim);
N=length(ev);
if N==0
    offset=0;
    ev=struct(ev);
else
    offset=ev(end).StopTime; 
end
if N==0
    ev= struct('Note',['PreStimSilence , ' Name],...
              'StartTime',offset,'StopTime',offset+PreStim,'Trial',[]);
else
    ev(N+1)= struct('Note',['PreStimSilence , ' Name],...
              'StartTime',offset,'StopTime',offset+PreStim,'Trial',[]);
end
ev(N+2) = struct('Note',['Stim , ' Name],'StartTime',...
              offset+PreStim, 'StopTime', offset+PreStim+Duration,'Trial',[]);
ev(N+3) = struct('Note',['PostStimSilence , ' Name],...
              'StartTime',offset+PreStim+Duration, 'StopTime',offset+PreStim+Duration+PostStim,'Trial',[]);

%=================exctracting tone from daniel seq
function [w,ss]=extract_sub(fs);
ponset=round([250 1125 2000 2875 3750 4625]*fs/1000);   %onset for each Shepard tone pairs (msec);
tptime=round([0 125 250 375]*fs/1000);   %on1-off1-on2-off2 time for eahc tone pairs
[w1,fs0]=wavread([fileparts(which('randToneSeq')) '\sounds\seq1.wav']); %increasing seq
w2=wavread([fileparts(which('randToneSeq')) '\sounds\seq2.wav']); %decreasing seq
w1=resample(w1,fs,fs0);
w2=resample(w2,fs,fs0);
for i=1:12
    ss{i}=['Dan-' num2str(i-1,'%2d')];  %standard and test tone of daniel-seq
    if i==1
        w(:,i)=w1(ponset(i)+[tptime(1):tptime(2)]);
    elseif i<=7
        w(:,i)=w1(ponset(i-1)+[tptime(3):tptime(4)]);  %1-6 semitone
    else
        w(:,i)=w2(ponset(13-i)+[tptime(3):tptime(4)]);  %7-11 semitone
    end
end







