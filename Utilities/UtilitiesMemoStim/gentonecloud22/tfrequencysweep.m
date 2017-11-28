function wave=tfrequencysweep(centrefrequency,octavespersecond,duration,startphase,fs,tt)
%Optional "tt" can be included, the times at which samples are are required,
%This is to avoid recalculating these each time.

if ~exist('tt','var')
    tt = 0:1/fs:duration-1/fs;
end;
nsamples=length(tt);

%work out the series of frequencies (in Hz) or "pitches" (in octaves)
centrepitch=log2(centrefrequency); %from Hz to (relative) octaves
startpitch=centrepitch-octavespersecond*duration/2;
endpitch=centrepitch+octavespersecond*duration/2;

pitches=linspace(startpitch,endpitch,(nsamples-1));
frequencies=2.^pitches; %from (relative) octaves to Hz

% subplot(3,1,1)
% plot(frequencies)

phasechanges=frequencies*2*pi/fs;
phases=cumsum([startphase phasechanges]);

% subplot(3,1,2);
% plot(phases)

wave=sin(phases);

% subplot(3,1,3);
% plot(wave)
