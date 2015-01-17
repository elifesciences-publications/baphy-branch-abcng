function varargout=tdemo(tpersecond,cperoctave,repeatflag,nrepeats,segdur)
%function varargout=tdemo(tpersecond,cperoctave,repeatflag,nrepeats,segdur)
%
%
%========================================================================
% tdemo.m:                             TA 04/07/2012, trevor@recoil.org
%------------------------------------------------------------------------
% Shows how to use gentonecloud21 to generate a "tone cloud", which is a 
% lot of pure-tone pips that are relatively evenly spread over time and 
% frequency. The spread comes from a grid specified in time and 
% log-frequency, with a single tone pip starting in each box in the grid. 
% The tone-cloud parameters "tpersecond" and "cperoctave" specify the 
% spacing of the lines in the grid.
%========================================================================
% 
%
%Parameters:
%    tpersecond = the number of tones started in each frequency "channel" (default = 16)
%    cperoctave = the number of frequency "channels" per octave  (default = 8)
%           Thus "tone-cloud density" (in tones/octave/second) = tpersecond x cperoctave
%    repeatflag = true for a repeated noise, false for an unrepeated noise (default = true)
%    nrepeats   = the number of times each tone-cloud segment is repeated
%           (normally nrepeats = 2 in experiments, but more repetitions are used in training)
%           (demo's default = 10)
%    segdur     = The duration of each segment of a repeated tone cloud
%       Thus the total duration of the tone cloud is sP.segdur x sP.nrepeats
%
%Outputs:
%    wave = tdemo; %outputs the waveform
%    [wave,sP]=tdemo; %outputs the waveform and a structure, sP, that contains information about the tone cloud
%
%Examples:
%    If you haven't heard a repeated tone cloud before, you might want to
%    listen to one of medium density with lots of repetitions (10):
%    > tdemo(16,8,true,10);
%    Compare this to its unrepeated counterpart:
%    > tdemo(16,8,false,10);
%    Here the density is 16 tones per second per channel x 8 channels per octave = 128 tones/second/channel 
%
%    Repetitions are a lot easier to detect when they are very sparse 
%    > tdemo(8,4,true,2);
%    > tdemo(4,2,true,2);
%    The sparsity of these is even reasonably clear from the waveform
%    > wave=tdemo(4,2,true,2); plot((1:length(wave))/44100,wave)
%
%    Denser repetitions are as hard to detect as for noise:
%    > tdemo(16,8,true,2);
%    > tdemo(32,16,true,2);
%    > tdemo(64,32,true,2);
%    > tdemo(128,64,true,2);
%    although even at these densities (128 x 64 = 8192 tones/s/oct) the
%    tone clouds sound a little different from noise
%    
%    Eventually, the tone clouds seem indistinguishable from spectrally matched noise
%    > tdemo(256,128,true,2)
%    but these very-dense tone clouds are slow to generate (for me, about 30 seconds for a 1-second tone-cloud)
%
%    As a rule of thumb, increasing the tone-cloud density makes it harder
%    to detect repetitions up to around 128 tones/second/octave, greater
%    than which task difficult is relatively constantly hard. However,
%    there are some qualifications to this. There is actually a slight dip 
%    in performance (fewer repetitions detected relative to denser tone 
%    clouds) for
%    > tdemo(32,16,true,2);
%    Furthermore, at this density, the relatively even spread of the tone
%    pips seems to matter. The following tone cloud is equally dense on
%    average, yet it is a little easier to detect its repetitions:
%    > tdemo(2,256,true,2)

%set up default values in case any inputs are missing
if ~exist('tpersecond','var'); tpersecond=16; end;
if ~exist('cperoctave','var'); cperoctave=8; end;
if ~exist('repeatflag','var'); repeatflag=false; end;
if ~exist('nrepeats','var'); nrepeats=1; end;
if ~exist('segdur','var'); segdur=.5; end;

%=========set the specifications of the tone cloud
sP.fs              = 44100; %sample-frequency (Hz)
sP.segdur          = segdur; %the duration of each segment (in seconds): defaults to 0.5
sP.repetitionflag  = repeatflag; %true for a repeated tone-cloud, false for an equivalent unrepeated noise of the same duration
sP.nrepeats        = nrepeats; %the number of repetitions of the segment (or the duration multiplier for unrepeated tone clouds)
sP.seed            = NaN; %will be replaced with a random seed, or you can seed it (e.g., with trandseedrand) to generate a specific tone cloud
sP.tonedur         = 0.15; %the duration of each pure tone (in seconds)
sP.tpersecond      = tpersecond; % number of tones per second
sP.cperoctave      = cperoctave; % number of channels per octave
sP.lowchan         = 50; %Hz
sP.highchan        = 50*2^8; %Hz
sP.rtime           = sP.tonedur/2; %the duration of each ramp (in seconds!). Here, it's set to half of the tone duration, making a Hanning window.
sP.rmsnorm         = 0.05; %the desired rms
%sP.scannernoise    = 999; %the desired snr in scanner noise: 999 (or omission) represents no added scanner noise 
sP.levelmapper     = 'default'; %'default' fades out the top and bottom frequencies according to the following parameters [can be replaced by another dummy function]
sP.freqrampoctaves = 2; %octaves
sP.freqrampdepth   = 60; %dB
sP.sweepmean       = sign(randn)*1; %octaves/second
sP.sweepSD         = 2; %octaves/second

%these should probably always be set to 0
sP.mingapt         = 0; %the smallest acceptable gap between tones (0 to not check)
sP.mingapf         = 0; %the smallest acceptable frequency between tones (0 to not check)
sP.mingaplogf      = 0; %1/12; %the smallest acceptable octave between tones (0 to not check)

%========Generate the tone cloud
[wave,sP]=gentonecloud22(sP);  %#ok<NASGU>

%========Play the tone cloud (sound or wavplay would work equally...)
if nargout==0
    mysound(tramp(wave,sP.fs,sP.segdur/2*1000))
end;
if nargout>=1
    varargout{1}=wave;
end;
if nargout>=2
    varargout{2}=sP;
end;

disp(sP.sweepmean)

%========Display the tone cloud
%tplottonecloud21(sP);

% %=======To regenerate the same sound later, store sP then regenerate it: e.g.,
% wave2=gentonecloud21(sP);
% pause; mysound(wave2);
% fprintf('The difference between the two waves was no more than %f\n', max(abs(wave-wave2)))
