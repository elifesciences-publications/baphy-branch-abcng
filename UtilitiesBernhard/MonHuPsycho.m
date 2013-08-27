function [wfm,profile] = MonHuPsycho(Pitch, Vel, Om, SDur, SampRate, ModDep, Display); 
% This function generates a waveform with a monaural huggins pitch at Pitch
% Pitch is in Hz
% Vel = for instance [2 4 8 16 32] Hz;
% Om = for instance [.25 0.5 1 2 4] cyc/oct;

% Direction... [-1 1]? For now, we use the same direction for the lower 
% & upper halves. Might consider what happens when 1st and 2nd halves are 
% in opposite directions. It would make the case that it's really the
% discontinuity and not something about the ST content that creates teh
% pitch. 

% Hard coded values. Could easily be put in argument list

% Lowest freq, bandwidth etc. Hard coded BW is 200Hz - Vel to 12800Hz + Vel
% +/- Vel because AM adds sidebands. 
baseF = 200; 
BW = 6; 
TonesPerOct = 100; 
PhaseAtEdge = pi;

RampDur = 60; %ms because of the way envel works

% Default values for arguments
if nargin < 1, Pitch = 800; end;
if nargin < 2, Vel = 4; end;
if nargin < 3, Om = 1; end;
if nargin < 4, SDur = 1; end;
if nargin < 5, SampRate = 1; end;
if nargin < 6, ModDep = 0.9; end;
if nargin < 7, Display = 1; end;

% Let's get computing
NumTones = BW*TonesPerOct + 1; 
topF = baseF*2.^BW;

% Remove: mel = 2000*2.^(0:.2:.2);
snd = [];
%Phase at t = 0, baseF. I am thinking that maybe we should set this to be a
%random number?
ph = 0;
BW1 = log2(Pitch/baseF);
Rips = [1, Om, Vel, ph, baseF, BW1, 1/TonesPerOct, ModDep, 1, 0];
s1 = bsmultiripfft(SampRate,Rips);
s1b = bsmultiripfft_profile(200,Rips);
ph = Om*log2(Pitch/baseF)*2*pi + PhaseAtEdge;
baseF2 = Pitch; BW2 = log2(topF/baseF2);
Rips = [1, Om, Vel, ph, baseF2, BW2, 1/TonesPerOct, ModDep, 1, 0];
s2 = bsmultiripfft(SampRate,Rips);%s2 = zeros(size(s2));
s2b = bsmultiripfft_profile(200,Rips);
snd = s1+s2;
% Add the RampDur here
snd = repmat(snd,1,SDur);
snd = envel(snd, RampDur, SampRate);

if Display
  figure(211), subplot(211),
  imagesc(linspace(0,SDur,size(s1b,2)),linspace(baseF,topF,size(s1b,1)+size(s2b,1)),[s1b;s2b]), axis xy
  xlabel('What it should be, logscale')
  %         subplot(212), specgram(decimate(snd,2), [], SampRate/2),
  subplot(212), specgram(snd, [], SampRate),
  xlabel('What it is, linear scale'),
  drawnow
  soundsc(snd, SampRate)
end


% Hence
wfm = snd;
profile = [s1b;s2b];