function [w, ev]=waveform (o,index, IsRef);
% function w=waveform(t);
% this function is the waveform generator for object FrequencyTuning


SamplingRate = ifstr2num(get(o,'SamplingRate'));
PreStimSilence = ifstr2num(get(o,'PreStimSilence'));
PostStimSilence = ifstr2num(get(o,'PostStimSilence'));
ToneNumber = ifstr2num(get(o,'ToneNumber'));
BaseFrequency = ifstr2num(get(o,'BaseFrequency'));

% the parameters of tone object
Duration = ifstr2num(get(o,'Duration')); % duration is second
ToneGap=ifstr2num(get(o,'ToneGap')); % duration is second
Names = get(o,'Names');
Frequency = ifstr2num(Names{index});
% now generate a tone with specified frequency:
if length(BaseFrequency)==1 && BaseFrequency(1)==0  %for shrard tone
    [x,sp]=genshepard;
    sp.pad=0;
    sp.tonedur=Duration;
    sp.fs=SamplingRate;
    shepard=1;
else
   shepard=0;
end

prestim=zeros(round(PreStimSilence*SamplingRate),1);
poststim=zeros(round(PostStimSilence*SamplingRate),1);
stimgap=zeros(round(ToneGap*SamplingRate),1);

switch ToneNumber
    case 0  %for FM
        t=0:1/SamplingRate:Duration;
        if Frequency(1)==Frequency(2)
            w=sin(2*pi*Frequency(1).*t);  %pure tone
        else
            w=chirp(t,Frequency(1),Duration,Frequency(2),'logarithmic'); end
        w=addenv(w,SamplingRate);
        w=[prestim; w(:); poststim];
        ev=ev_struct([],sprintf('FM %d-%d',Frequency),PreStimSilence,Duration,PostStimSilence);
    case 1
        if shepard==1
            sp.interval=Frequency;
            w0=genshepard(sp);
            w=[prestim;w0(:);poststim];
            ev=ev_struct([],sprintf('Note %d',Frequency),PreStimSilence,Duration,PostStimSilence);
        else
            t=Tone(SamplingRate, 0, get(o,'PreStimSilence'), get(o,'PostStimSilence'), ...
                Frequency(1), Duration,0);
            [w, ev] = waveform(t);
            if length(BaseFrequency)>1 && BaseFrequency(2)<=48   %bandpassed noise
                w0=rand(round(1.5*Duration*SamplingRate),1)*2-1;  %white noise
                Wn=[-1 1]*BaseFrequency(2)/2/12;
                Wn=Frequency(1)*2.^Wn;
                Wn=Wn/SamplingRate*2;
                [z,p,k] = ellip(8,1,80,Wn);
                [sos,g]=zp2sos(z,p,k);
                hd=dfilt.df2sos(sos,g);
                w=filter(hd,w0);
                w=w([1:round(Duration*SamplingRate)]+round(0.25*Duration*SamplingRate));
                w=addenv(w,SamplingRate);
                w=[prestim; w(:); poststim];
            end
        end
    case 2
        if length(Frequency)==3
            ToneGap=Frequency(3); end
        if shepard==1
            sp.interval=Frequency(1);
            w1=genshepard(sp);
            sp.interval=Frequency(2);
            w2=genshepard(sp);
            w=[prestim;w1(:);stimgap;w2(:);poststim];
            ev1=ev_struct([],sprintf('Note %d',Frequency(1)),PreStimSilence,Duration,ToneGap);
            ev2=ev_struct([],sprintf('Note %d',Frequency(2)),0,Duration,PostStimSilence);
        else
            t1 = Tone(SamplingRate, 0, get(o,'PreStimSilence'), ToneGap/2, ...
                Frequency(1), Duration);
            t2 = Tone(SamplingRate, 0, ToneGap/2, get(o,'PostStimSilence'), ...
                Frequency(2), Duration);
            [w1, ev1] = waveform(t1);
            [w2, ev2] = waveform(t2);
            clear t1 t2;
            w=[w1(:);w2(:)];
        end
        for i=1:length(ev2)
            ev2(i).StartTime=ev2(i).StartTime+ev1(end).StopTime;
            ev2(i).StopTime=ev2(i).StopTime+ev1(end).StopTime;
        end        
        ev=[ev1 ev2];
    otherwise
        disp('not ready yet!');
end
w = 5 * w/max(abs(w));
if length(BaseFrequency)==2 && ToneNumber<=2  %two tone chords
    if BaseFrequency(2)>48   %not bandpassd noise
        if ToneNumber==1     %chords
            t=Tone(SamplingRate, 0, get(o,'PreStimSilence'), get(o,'PostStimSilence'), ...
                BaseFrequency(2), Duration);
        elseif ToneNumber==2 %sequence
            t=Tone(SamplingRate, 0, get(o,'PreStimSilence'), ToneGap+Duration+get(o,'PostStimSilence'), ...
                BaseFrequency(2), Duration);
        end
        wc=waveform(t);
        wc=5*wc/max(abs(wc));
        w=w/2+wc(:)/2;
    end
end

if length(Frequency)>ToneNumber && ToneNumber==1
  w=w*10^(-Frequency(end)/20);
  for i=1:length(ev)
      ev(i).Note=[ev(i).Note ' -' num2str(Frequency(end))];
  end
end


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
         
%add 5 ms rise/fall time ===================================
function s=addenv(s1,fs);
%f=ones(size(s1));
pn=round(fs*0.005);    % 5 ms rise/fall time 
up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
f = [up ones(1,length(s1)-2*pn) down]';
s=s1(:).*f(:);

%==========================================
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

if sP.interval==0
    x=x0; else
    x=x1; end
return;

% % stuff
% ioipts = floor(sP.ioi*sP.fs);
% padpts = round(sP.pad*sP.fs);
% zisi = zeros(1,ioipts);
% zpad = zeros(1,round(padpts/2));
% 
% 
% if sigint == 1
% 	oneloop = [x0 zisi x1];
% elseif sigint == 0
% 	oneloop = [x1 zisi x0];
% end
% 	
% x = [];
% oneloop = [zpad oneloop zpad];
% for iloop = 1:1:sP.nloop;
% 	x = [ x oneloop];
% end
% 

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
