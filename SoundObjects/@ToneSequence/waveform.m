function [w, ev]=waveform (o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object TonesSequence
%
%Pingbo, December 2005.

fs = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

% the parameters of Stream_AB object
NoteDur = get(o,'NoteDur');
NoteGap = get(o,'NoteGap'); % duration is second
Names = get(o,'Names');
Frequency = str2num(Names{index});
Type=get(o,'Type');
if strcmpi(Type,'Shepard')  %for Shepard tone sequence
    para=get(o,'Frequency');
    [x,sp]=genshepard;
    if length(para)>=3
        sp.f0=para(3);
    end
    sp.pad=0;
    sp.tonedur=NoteDur;
    sp.ioi=NoteGap;
    sp.fs=fs;
    sp.interval=Frequency(1);
    sigint=Frequency(2);
    [w,sp]=genshepard(sp,sigint);
    ev=[]; PreStimSilence=0; PostSimSilence=0;
    if sigint==1
        ev=ev_struct(ev,['Note 0'],0,NoteDur,NoteGap);  %standard
        ev=ev_struct(ev,['Note ' num2str(Frequency(1))],0,NoteDur,0);
    else
        ev=ev_struct(ev,['Note ' num2str(Frequency(1))],0,NoteDur,NoteGap);
        ev=ev_struct(ev,['Note 0'],0,NoteDur,0);
    end
    w = 5 * w/max(abs(w));
    return;
end

% now generate a tone with specified frequency:
t=0:1/fs:NoteDur;

gap=zeros(round(NoteGap*fs),1);
NoteDur=length(t)/fs;
NoteGap=length(gap)/fs;

w=[];ev=[];
prestim=zeros(round(PreStimSilence*fs),1);
poststim=zeros(round(PostStimSilence*fs),1);
for i=1:length(Frequency)
    w0=addenv(sin(2*pi*Frequency(i)*t),fs);
       w=[w;w0(:)];
       if i<length(Frequency)
           w=[w;gap(:)];
           if i==1
               w=[prestim;w];
               ev=ev_struct(ev,['Note ' num2str(Frequency(i))],PreStimSilence,NoteDur,NoteGap);
           else
               ev=ev_struct(ev,['Note ' num2str(Frequency(i))],0,NoteDur,NoteGap);
           end
       else
           w=[w;poststim];
           ev=ev_struct(ev,['Note ' num2str(Frequency(i))],0,NoteDur,PostStimSilence);
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
%         
% %flip evnt note =============================================
% function evt=flipevt(ev);
% N=length(ev);
% for i=1:N
%     evt(i)=ev(i);
%     tem=ev(N-i+1).Note;
%     if findstr(tem,'PostStimSilence')
%         tem=strrep(tem,'PostStimSilence','PreStimSilence');
%     elseif findstr(tem,'PreStimSilence')
%         tem=strrep(tem,'PreStimSilence','PostStimSilence');
%     end
%     evt(i).Note=tem;
% end

%=================================================
function [x,sP] = genshepard(sP,sigint);
if nargin == 0
    sP.f0 = [65.41];      % frequency of lowest tone
    sP.interval = [6];    % interval with highest tone (in semitones)
    sP.fc = 1046.5;       % center frequency of the spectral envelope
    sP.sigma = 1;         % spread of the spectral envelope
    sP.tonedur = 0.125;   % tone duration (s)
    sP.ioi = 0.125;       % inter-tone duration (s)
    sP.pad = 0.50;        % half-silence between tones (s)
    sP.ramptime = 0.005;  % ramp time (s)
	sP.nloop = 1;         % how many repeats (s)
    sP.preseq = 0;        % if 0, no presequence. If X=[1-11], goes from X to sP.interval in 1 st steps
    sP.preseqsigint = 0;  % not used here
    sP.reduced = 0;       % if 0: intervals in preseq, preseqsigint random; 1: only a scale; 2: intervals, preseqsigint fixed
    sP.hyst = NaN;        % not used here
    sP.fs = 44100;        % sampling frequency (s)
	sigint = 1;           % which tone comes first if 1: standard first, if 0: comparison first  
end

% Compute lots of octaves, to build shepard tone
h0 = 2.^[0:1:8];

% The actual frequencies
ff0 = sP.f0*h0;
if sP.interval <= 6
    h1 = h0;
    ff1 = sP.f0*h1*2^(sP.interval/12);
else
    h1 = 2.^[-1:1:8];
    ff1 = sP.f0*h1*2^(sP.interval/12);
end

% Find frequencies lower than half sampling rate
iok0 = find(ff0< (sP.fs/2) );
iok1 = find(ff1< (sP.fs/2) );

% spectral envelope shape: a Gaussion function
a0 = exp(-0.5*(log(ff0/sP.fc)/log(2)/sP.sigma).^2);  
a1 = exp(-0.5*(log(ff1/sP.fc)/log(2)/sP.sigma).^2);  

% produce the sounds, with cosine phase
x0 = dosynth(ff0(iok0),a0(iok0),zeros(size(iok0)),sP.tonedur,sP.fs);
x0 = ramp(x0,sP.ramptime,sP.fs);
x0 = x0/rms(x0)/20;

x1 = dosynth(ff1(iok1),a1(iok1),zeros(size(iok1)),sP.tonedur,sP.fs);
x1 = ramp(x1,sP.ramptime,sP.fs);
x1 = x1/rms(x1)/20;

% stuff
ioipts = floor(sP.ioi*sP.fs);
padpts = round(sP.pad*sP.fs);
zisi = zeros(1,ioipts);
zpad = zeros(1,round(padpts/2));


if sigint == 1
	oneloop = [x0 zisi x1];
elseif sigint == 0
	oneloop = [x1 zisi x0];
end
	
x = [];
oneloop = [zpad oneloop zpad];
for iloop = 1:1:sP.nloop;
	x = [ x oneloop];
end

%============================================= 
function [x] = dosynth(freqs,amps,phase,d,fs);
% function [x] = dosynth(freqs,amps,phase,d,fs);
% freqs: list of frequencies;
% amps: list of amplitudes
% phase: list of phases (in radian)
% d: duration
% fs: sampling frequency

t = [0:1/fs:d-1/fs];
x = zeros(size(t));
for i = 1:1:length(freqs);
	x = x+amps(i)*cos(2*pi*freqs(i)*t+phase(i));
end
    
%=============================================
function [xr] = ramp(x,rtime,fs);
% [xr] = ramp(x,rtime,fs);
% rtime in seconds!!

lt = length(x);
tr = [0:1/fs:rtime-1/fs];
lr = length(tr);
rampup = ((cos(2*pi*tr/rtime/2+pi)+1)/2).^2; 
rampdown = ((cos(2*pi*tr/rtime/2)+1)/2).^2; 
xr = x;
xr(:,1:lr) = rampup.*x(:,1:lr);
xr(:,lt-lr+1:lt) = rampdown.*x(:,lt-lr+1:lt);

%============================================================
function [r] = rms(x)

if size(x,1)>size(x,2)
  x = x';
end

if size(x,1) == 1
  r = sqrt(x*x'/size(x,2));
else
  r(1) = sqrt(x(1,:)*x(1,:)'/size(x,2));
  r(2) = sqrt(x(2,:)*x(2,:)'/size(x,2));
end


