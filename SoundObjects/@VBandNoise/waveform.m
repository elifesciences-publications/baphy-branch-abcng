function [w, ev]=waveform (o,index,~)
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
NoteDur = get(o,'Duration');
Frequency=str2num(Names{index});
ToneNum=get(o,'ToneDensity');

t=0:1/fs:NoteDur-1/fs;
NoteDur=length(t)/fs;
if Frequency(2)==0  %pure tone
    w=addenv(sin(2*pi*Frequency(1)*t),fs);  %standard stimulus
else
    bw=Frequency(2)/12;   %ocatve bandwidth
    if isinf(ToneNum)  %id the tone density is inf, we create a random white noise
        f1 = Frequency(1)*2^(-bw/2);
        f2 = Frequency(1)*2^(bw/2);
        f1 = f1/fs*2;
        f2 = f2/fs*2;
        [z,p,k] = ellip(8,1,80,[f1(1) f2]);
        [sos,g]=zp2sos(z,p,k);
        hd=dfilt.df2sos(sos,g);
        
        w0=rand(length(t)*2,1);  %double length to solve the delay probelm of the filter
        w=filter(hd,w0);
        w(1:length(t))=[];   %remove the first segment
    else
        s=RandStream('mt19937ar','seed',datenum(date));  %set rand seed 
        RandStream.setDefaultStream(s);
        
        fcomp=-bw/2:1/ToneNum:bw/2;
        fcomp=Frequency(1)*2.^fcomp;
        w=0;
        for i=1:length(fcomp)
            w=w+sin(2*pi*fcomp(i)*t+rand*2*pi);
        end
    end
    w=addenv(w,fs);
end
w=[prestim;w;poststim];
evt_note=['Note ' num2str(Frequency(1:2))];
ev=ev_struct([],evt_note,PreStimSilence,NoteDur,PostStimSilence);
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







