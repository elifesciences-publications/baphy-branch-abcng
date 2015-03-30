function [x,sP] = genmemoclicks(sP,sigint);
% 14/05-T/Y: We commented all the parts that regenerated seeds
% 15.02.15 - added sP.clicktimes to get time of individual clicks in a sequence. ST

if nargin == 0
    sP.mingap = 0.01; % minimum gap duration in seconds
    sP.maxgap = 0.2;  % maximum gap duration in seconds
    sP.replength = 1; % duration of a single repeat
    sP.nreps = 2; % number of repeats
    sP.stimtype = 2; % stimulus type: 0 is N, 1 is RN, 2 is RefRN
    sP.testtype = 1;
    sP.seed = [];
    sP.highpass = 2000; % high-pass filter cutoff
    sP.noiseSNR = 12; % add lowpass noise with given SNR. Cutoff is = highpass, noise is pink. Positive values means softer noise.
    sP.clickdur = 0.00005;
    sP.fs = 44100; % sampling rate
    sP.clicksamples = [];
    sP.clicktimes = [];
end

noise_lowcut = 50;
x_scalefactor = 100;

%% deal with random number generator
rng('default')
%if (~isempty(sP.seed) & sP.stimtype == 2)
    rng(sP.seed);
%else
%     rng('shuffle');
%     randstate = rng;
%     sP.seed = randstate.Seed;
% end

if sP.mingap > sP.maxgap/2 % check the actual value!
    error('Min and max gap seem too close!')
end

%% number of samples for a click
nclicksamp = floor(sP.clickdur*sP.fs);

%% highpass filter
if sP.highpass ~= 0
    [B,A] = butter(8,sP.highpass*2/sP.fs,'high');
end

%% main loop
x = [];
sP.clicktimes = [];

for irep = 1:1:sP.nreps
    
    if ( (irep == 1) | (sP.stimtype == 0) )
        % a zero vector with correct length
        xseg = zeros(1,floor(sP.fs*sP.replength));
        % draw a random number of interval until we are too long
        idx = 1;
        okflag = 1;
        clicktimes = [];
        clicktimes(1) = 1/sP.fs;

        while okflag
            zclicktimes = sP.mingap + rand(1)*(sP.maxgap-sP.mingap);
            idx = idx+1;
            clicktimes(idx) = clicktimes(idx-1)+zclicktimes;
            if clicktimes(idx) > sP.replength-sP.maxgap;
                okflag = 0;
            end
        end
        % convert to samples
        sP.clicksamples = ceil(clicktimes*sP.fs);
        for iclicksamp = 1:1:nclicksamp
          xseg(sP.clicksamples+iclicksamp-1) = 1;
        end
        if sP.highpass ~= 0
          xseg = filter(B,A,xseg);
        end
    end
    
    x = [x xseg];
    sP.clicktimes = [sP.clicktimes ((irep-1)*sP.replength + sP.clicksamples./sP.fs)];

end

% deal with level
x = x/rms(x)/x_scalefactor;

%% Add noise if necessary

if sP.noiseSNR < 99
%     rng('shuffle');
%     randstate = rng;
    
%     sP.seed = randstate.Seed;
    n = pinknoise2(length(x),noise_lowcut,sP.highpass,3);
    n = (n/rms(n)/x_scalefactor)*10^( (-sP.noiseSNR)/20 );
    x = x+n;
end

%% check that we did not clip

if max(abs(x))>0.999
    warning('Clipped!')
    pause(0.01);
    [x,sP] = genmemoclicks(sP,sigint);
end
    
% do a bit of zero-padding to be sure not to miss clicks
zpad = zeros(1,0.1*sP.fs);
x = [zpad x zpad];
%% finito

% debug 
% allclicks = [];
% for i = 1:1:1000
%     allclicks = [allclicks clicktimes+sP.replength*(i-1)];
% end
% hist(diff(allclicks))


