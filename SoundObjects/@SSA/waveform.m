function [w, ev]=waveform (o,index,index0)
% function w=waveform(t);
% this function is the waveform generator for object TonesSequence
%
%Pingbo, Jan 2007.

fs = get(o,'SamplingRate');
Type= get(o,'Type');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
prestim=zeros(round(PreStimSilence*fs),1);
poststim=zeros(round(PostStimSilence*fs),1);
Names = get(o,'Names');
NoteDur = get(o,'NoteDur');
NoteGap = get(o,'NoteGap');
Frequency=str2num(Names{index});

if Frequency(2)<=100  %percentage
  tem=Frequency(2)/100.0;
  if tem<0
    Deviant=Frequency(1)/(1+abs(tem));
  else
    Deviant=Frequency(1)*(1+tem);
  end
else
  Deviant=Frequency(2); %in Hz
end
Deviant_pct=Frequency(3)/100.0;


t=0:1/fs:NoteDur-1/fs;
gap=zeros(round(NoteGap*fs),1);
NoteDur=length(t)/fs;
NoteGap=length(gap)/fs;
NoteNum=get(o,'NoteNumber');
if strcmpi(Type,'tone')
    s=addenv(sin(2*pi*Frequency(1)*t),fs);  %standard stimulus
    d=addenv(sin(2*pi*Deviant*t),fs);    %deviant stimulus
elseif strcmpi(Type,'bpn')
    ff=get(o,'Standard');
    if length(ff)==2   %2nd paramter is the bandwidth in octave
        bw=ff(2); else
        bw=1; 
    end
    f1 = [Frequency(1) Deviant]*2^(-bw/2);
    f2 = [Frequency(1) Deviant]*2^(bw/2);
    f1 = f1/fs*2;
    f2 = f2/fs*2; 

    [z,p,k] = ellip(8,1,80,[f1(1) f2(1)]);
    [sos,g]=zp2sos(z,p,k);
    hd1=dfilt.df2sos(sos,g);
    [z,p,k] = ellip(8,1,80,[f1(2) f2(2)]);
    [sos,g]=zp2sos(z,p,k);
    hd2=dfilt.df2sos(sos,g);
    
    w0=rand(length(t)*2,1);
    s=filter(hd1,w0); s(1:length(t))=[];
    d=filter(hd2,w0); d(1:length(t))=[];
    s=addenv(s,fs);
    d=addenv(d,fs);
else
    disp('xxx');
    return;
end

%make random sequence
deviant_num=round(NoteNum*Deviant_pct);  %total number of deviant
seq=randperm(NoteNum);
xx=round(1/Deviant_pct);
dd=ceil(rand(deviant_num,1)*xx);
dd(:,2)=[0:length(dd)-1]'*xx;
dd=sum(dd,2);
disp(sprintf('%d-%d-%d',min(dd),min(diff(dd)),max(diff(dd))));
while any(diff(dd)==0)
    dd=ceil(rand(deviant_num,1)*xx);
    dd(:,2)=[0:length(dd)-1]'*xx;
    dd=sum(dd,2);
    disp(sprintf('%d-%d-%d',min(dd),min(diff(dd)),max(diff(dd))));
end

w=[];ev=[];
for i=1:NoteNum
    if ismember(i,dd)   %deviant
        w=[w;d(:)];
        evt_note=['Note ' num2str(Deviant)];
    else
        w=[w;s(:)];
        evt_note=['Note ' num2str(Frequency(1))];
    end
    
    if i==1
        w=[prestim;w;gap(:)];
        ev=ev_struct(ev,evt_note,PreStimSilence,NoteDur,NoteGap);
    elseif i==NoteNum
        w=[w;poststim];
        ev=ev_struct(ev,evt_note,0,NoteDur,PostStimSilence);
    else
        w=[w;gap(:)];
        ev=ev_struct(ev,evt_note,0,NoteDur,NoteGap);
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







