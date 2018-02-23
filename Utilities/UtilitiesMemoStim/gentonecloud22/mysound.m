function mysound(wave,fs,waitflag)
%function mysound(wave,fs,waitflag)
%
%=========================================================================
% mysound.m      TA 17xi2010
%A function that presents sounds (like sound.m or wavplay.m) while working 
%around some of the bugs in the Matlab / Windows 7 / Fireface combination
%=========================================================================
%
%
% BACKGROUND
% To the best of my understanding, Windows 7 has changed the way that 
% programs can interact with soundcards. There seem to be two bugs, which
% may be a wider problem with soundcards
%   1. Sounds can get truncated (at the end, and sometimes the start)
%   2. When Matlab is waiting for a sound to finish, it can get confused by
%      unrelated sounds (e.g., warning beeps) coming from other programs,
%      meaning that it continues 
%
% These are solved in this function by (1) padding the sounds and (2) using the
% clock function to wait for the sound, if necessary.
%
% SOUNDCARD SETTINGS
% The default padding in this program (40 ms of silence at the end, 0 ms 
% of silence at the start) is based on the current set-up.
% 
% !!!!!NB For latencies > *** there is more trucation, including at the start
% of the sound. If you change the sound-card settings, you may need to tweak 
% this function!!!!!
%
% TESTING FOR NO TRUNCATION
% For testing whether mysound.m is successfully preventing truncations, the
% following line should generate two clicks, one at the start of the sound
% and one at the end
% >> wave=[1; zeros(44098,1); 1]; mysound(wave)
%
% MEASURING THE TIME LOST
% To find out how for how much time the function isn't playing sound...:
% >> duration=1; channels=2; fs=44100; wave=randn(round(duration*fs),channels)/20; tic; mysound(wave); totalduration=toc; fprintf('Additional time = %.1f ms\n',(totalduration-duration)*1000)
% Additional time = 112.5 ms
% This consists of 40 ms of padding. Most of the remaining approx. 70 ms is
% taken just by calling the 'sound' function -- i.e., the additional
% padding isn't the biggest source of delay.
%
% 
% Note that 40 ms of this is due to the sound's padding
%
% PARAMETERS
% wave     = one/two columns representing the of the mono/stereo waveform(s)
%            (one or two rows will be transformed to columns automatically)
% fs       = the sample-rate (default = 44100 Hz)
% waitflag = true to wait until the sound is finished (default); or 
%            false to continue straight on to the next line of programming; or
%            0<waitflag<1 to wait for a proportion of the sound; or
%            waitflag<0 to wait for (-waitflag) milliseconds less than the duration of the sound.
% EXAMPLES
%  

%hard-wired variables
defaultfs=44100; %Hz
defaultwaitflag=true;
startsilence=0; %ms
endsilence=40; %ms

%assign default values if necessary
if nargin==1
    fs=defaultfs;
    waitflag=defaultwaitflag;
end;

if nargin==2
    if fs<=1 %probably true or false; or negative
        waitflag=fs;
        fs=defaultfs;
    else
        waitflag=defaultwaitflag;
    end;
end;

if fs<=1; %parameters are back-to-front?
    tempvar=fs;
    fs=waitflag;
    waitflag=tempvar;
    clear tempvar;
end;

%correct the wave's orientation if necessary
if size(wave,2)>2
    if size(wave,1)>2
        error('No more than two channels')
    else
        wave=wave';
    end;
end;

%add silences to the start/end as required
totalchannels=size(wave,2);
paddedwave=[...
    zeros(round(startsilence*fs/1000),totalchannels);...
    wave;...
    zeros(round(endsilence*fs/1000),totalchannels)];


sound(paddedwave,fs);


if waitflag
    starttime=now;
    waittime=length(paddedwave)/fs/86400;
    if waitflag>0&&waitflag<1
        waittime=waittime*waitflag;
    elseif waitflag<0
        waittime=waittime-(-waitflag)/1000/86400;
    end;
    endtime=starttime+waittime;
    while now<=endtime; end;
end;