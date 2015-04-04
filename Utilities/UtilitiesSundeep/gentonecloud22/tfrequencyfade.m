function lingain=tfrequencyfade(freqs,sP)
%takes a (matrix of) frequencies (freqs) and the parameters used to
%generate them (as fields of sP) and maps them to (linear) gains which
%could be multiplied to sine-waves of those frequencies
%
%
% To test:
% sP.lowchan=100; sP.highchan=10000; sP.freqrampoctaves=2; sP.freqrampdepth=60;
% freqs=sP.lowchan:sP.highchan; 
% plot(freqs,tfrequencyfade(freqs,sP))

%useful parameters
minfreq=sP.lowchan; %Hz
maxfreq=sP.highchan; %Hz
freqrampoctaves=sP.freqrampoctaves; %octaves
freqrampdepth=sP.freqrampdepth; %dB

pitches=log2(freqs/minfreq);
maxpitch=log2(maxfreq/minfreq); %minpitch = 0;

% levels=min([...
%     (pitches-freqrampoctaves)*freqrampdepth/freqrampoctaves;...
%     zeros(size(pitches));...
%     (maxpitch-freqrampoctaves-pitches)*freqrampdepth/freqrampoctaves...
%     ]);
levels=min(cat(3,...
    (pitches-freqrampoctaves)*freqrampdepth/freqrampoctaves,...
    zeros(size(pitches)),...
    (maxpitch-freqrampoctaves-pitches)*freqrampdepth/freqrampoctaves...
    ),[],3);

lingain=10.^(levels/20);