function [x,sP] =  gentonecloud22(sP)
%{
function [x,sP] =  gentonecloud22(sP)
Generates (or re-generates) tone clouds

============================================
gentonecloud21.m (Trevor Agus, 15/09/2011)
gentonecloud22.m (Sundeep Teki, 12.01.2015)
============================================

To regenerate the same sound: EITHER include sP.freqs, sP.onsets and the
other important parameters OR use the same sP.seed.

To regenerate the sound with different phases, use sP.freqs, sP.onsets and
the other important parameters BUT set sP.phases=NaN.

v18: adapted so that phases repeat exactly
v19: same parameters as the pilot experiment
v20: general tidy-up and commenting
     large fields of sP get removed: rmfield(sP2,{'freqs' 'onsets' 'phases' 'lingain'}): just use sP.seed (and sP.soundgenerator!) to regenerate sounds
     all references to phaseseed commented out: it seems unlikely that I'll want control of phases, and I can easily add it back in. Otherwise it's an unnecessarily complicated.
v21: improved commenting
     defaults to Hanning pips (i.e., ramps that are half of the duration of the tones)
v22: modified for long-term tone cloud memory experiment (Sundeep Teki, 12.01.2015)
%}

%% Default values
if nargin == 0
    sP.fs               = 44100;        %sample-frequency
    sP.segdur           = 0.5;          %seconds
    sP.repetitionflag   = true;         %false for an equivalent unrepeated noise of the same duration
    sP.nrepeats         = 3;            %varies a lot
    sP.seed             = NaN;          %will be replaced with a random seed, or you can seed it
    sP.tonedur          = 0.05;         %the duration of each pure tone (in seconds)
    sP.mingapt          = 0;            %the smallest acceptable gap between tones (0 to not check)
    sP.mingapf          = 0;            %the smallest acceptable frequency between tones (0 to not check)
    sP.mingaplogf       = 0;            %1/12; %the smallest acceptable octave between tones (0 to not check)
    sP.tpersecond       = 20;           % number of tones per second (1/sP.tonedur?)
    sP.chperoctave      = 3;            % number of channels per octave
    sP.lowchan          = 22050/(2^8);  %lowest frequency is 8 octaves below Nyquist
    sP.highchan         = 22050;        %Hz
    sP.rtime            = sP.tonedur/2;
    sP.rmsnorm          = 0.05;         %the desired rms    
    sP.freqrampoctaves  = 2;            %octaves
    sP.freqrampdepth    = 60;           %dB
    sP.levelmapper      = 'default';
    %sP.levelmapper= @(freqs,sP) tfrequencyfade(freqs,sP); %dummy function; can also be referred to as 'default' to avoid clogging up a hard-disk
    %sP.scannernoise=999;               %the desired snr in scanner noise: 999 (or omission) represents no added scanner noise        
end

%%

if isfield(sP,'soundgenerator') && ~strcmp(sP.soundgenerator,mfilename);
    error('Incorrect sound generator (see sP.soundgenerator)')
end;

if isfield(sP,'levelmapper') && ischar(sP.levelmapper); %storing the function can take a lot of memory
    levelmappername=sP.levelmapper;
    switch sP.levelmapper
        case 'default'
            sP.levelmapper=@(freqs,sP) tfrequencyfade(freqs,sP); 
        case 'highpass'
            sP.levelmapper=@(freqs,sP) tlowfrequencyfade(freqs,sP); 
        otherwise
            error('Unknown levelmapping strategy');
    end;
end;

sP.soundgenerator=mfilename; %just in case there's any confusion after

%% to regenerate sounds, set these values in advance

if ~isfield(sP,'freqs'); sP.freqs=NaN; end;
if ~isfield(sP,'onsets'); sP.onsets=NaN; end;
if ~isfield(sP,'phases'); sP.phases=NaN; end;

if ~isfield(sP,'seed') || isempty(sP.seed) || any(isnan(sP.seed))
    sP.seed=rand('state');
    seededflag=false;
else
    seededflag=true;
end;

if seededflag
    oldstate=rand('state');
    rand('state',sP.seed) %danger, danger, danger!
end;

maximumcollisions=1000; %after this many collisions, the program regenerates a tonecloud from scratch; only relevant if avoiding having toneclouds too close together

%% work out some useful values
% number of tones per channel per segment
if sP.repetitionflag
    ntones = floor(sP.segdur*sP.tpersecond); % 10
    segdur = sP.segdur;
else
    ntones = floor(sP.segdur*sP.tpersecond)*sP.nrepeats;
    segdur = sP.segdur*sP.nrepeats;
end;

nchannels=round( log2(sP.highchan/sP.lowchan) * sP.chperoctave); % 24

%% switch to a log2 scale for frequency

lowlogf=log2(sP.lowchan);
highlogf=log2(sP.highchan);

%% set up the grid

logfgridlines=( (0:nchannels)/nchannels) * (highlogf-lowlogf) + lowlogf; % (1/24) * 8 = 1/3 octave apart
logfspacing=(highlogf-lowlogf)/nchannels; % 1/3 
lowerlogf=logfgridlines(1:(length(logfgridlines)-1));

tgridlines=((0:ntones)/ntones)*(segdur); %+ nothing, since it starts at t = 0
tspacing = segdur/ntones; %ok, nearly the same as sP.tpersecond, but may be rounded (0.05)
lowert=tgridlines(1:(length(tgridlines)-1));

%% preliminary error-checking for situations not yet programmed...

if any(any(isnan(sP.freqs))) && ~any(any(isnan(sP.onsets)))
    error('Not programmed to generate random frequencies to given onsets');
end;
if ~any(any(isnan(sP.freqs))) && any(any(isnan(sP.onsets)))
    error('Not programmed to generate random onsets to give frequencies');
end;

%or are we regenerating a stimulus that was made before?
if ~any(any(isnan(sP.freqs)))&&~any(any(isnan(sP.onsets)))
    regenerationflag=true;
    
    %run some basic checks that the data is consistent before proceeding
    if ntones*sP.nrepeats^sP.repetitionflag~=size(sP.freqs,2);
        error('There are the wrong number of tones per channel provided')
    end;

    if nchannels~=size(sP.freqs,1)
        error('There are the wrong number of channels provided')
    end;
    
    if any(size(sP.freqs)~=size(sP.onsets))
        error('Different numbers of frequencies and onsets')
    end;
    %NB no check for collisions

else
    regenerationflag=false;
end;

%% creating a new tone (where necessary)

if any(any(isnan(sP.freqs))) && any(any(isnan(sP.onsets)))
    
    %choose times and frequences for each box (relative to the bottom-left of each box)
    fi=rand(nchannels,ntones); %normalised log-frequency position for each tone within a box on the grid
    ti=rand(nchannels,ntones); %normalised onset-time position for each tone within a box on the grid

    %transform these values into times and frequencies
    for ichan=nchannels:-1:1
        logfreqs(ichan,:) = fi(ichan,:)*logfspacing+lowerlogf(ichan);
    end
    
    for itone=ntones:-1:1
        onsets(:,itone) = ti(:,itone)*tspacing+lowert(itone);
    end
    freqs=2.^logfreqs;

    %------this large selection is only relevant if we're trying to leave gaps between frequencies
    if any([sP.mingapt~=0 sP.mingapf~=0 sP.mingaplogf~=0]) %then we need to done some anti-collision checks
        %here be the bit of code that preventeth the clashes.
        tonecheckflag=zeros(size(freqs))==1; %initialised "false" array
        alltonescheckedflag=false;
        collisioncount=0;
        while ~alltonescheckedflag

            uncheckedtones=find(tonecheckflag==false);
            tonecheckorder=randperm(length(uncheckedtones)); %so that no time or frequency channel is preferenced
            for itone=1:length(uncheckedtones)
                thistone=uncheckedtones(tonecheckorder(itone));
                thischan=mod(thistone-1,nchannels)+1; %which channel?
                thisslot=floor((thistone-1)/nchannels)+1; %which time-slot?
                freqdiff=freqs-freqs(thischan,thisslot);
                lfreqdiff=log2(freqs)-log2(freqs(thischan,thisslot));
                timediff=onsets-onsets(thischan,thisslot);
                timediffnextrep=onsets-onsets(thischan,thisslot)+segdur; %assuming a wrap-around right for repeats
                timedifflastrep=onsets-onsets(thischan,thisslot)-segdur; %assuming a wrap-around left for repeats
                mintimediff=min(min(abs(timediffnextrep),abs(timedifflastrep)),abs(timediff));
                problemtones=...
                    (abs(freqdiff)<sP.mingapf | abs(lfreqdiff)<sP.mingaplogf) &... %too close in frequency AND...
                    (abs(mintimediff)<(sP.mingapt+sP.tonedur));                    %too close in time
                problemtones(thischan,thisslot)=false;
                if any(any(problemtones))
                    collisioncount=collisioncount+1;
                    %are we just cycling round and round?
                    if collisioncount>=maximumcollisions
                        fprintf('!')
                        [x,sP] =  gentonescloud3(sP); %try again from scratch
                        return
                    end;

                    %swap it with something in the same channel or time-slot
                    if rand>0.5; %swap in channel 
                        swoptions=setdiff(1:size(freqs,1),thischan);
                        swapchan=swoptions(trand(length(swoptions)));
                        freqs([swapchan thischan],thisslot)=freqs([thischan swapchan],thisslot);
                        tonecheckflag(swapchan,thisslot)=false; %register that problems may have been created
                    else         %swap in time-slot
                        swoptions=setdiff(1:size(freqs,2),thisslot);
                        swapslot=swoptions(trand(length(swoptions)));
                        onsets(thischan,[swapslot thisslot])=onsets(thischan,[thisslot swapslot]);
                        tonecheckflag(thischan,swapslot)=false; %register that problems may have been created
                    end;

                    %potentially need to test another tone now
                    break
                else %no problems!
                    tonecheckflag(thischan,thisslot)=true;
                end;
            end;
            if itone==length(uncheckedtones)
                alltonescheckedflag=true;
            end;
        end;
    end;
    onsets(onsets==0)=1/sP.fs; %to avoid the small risk of something trying to start on the 0th sample
    
    %-----work out the phases
    if isnan(sP.phases) %we don't know the phases
        %if regenerationflag %then we're re-making the sound, but deliberately with different phases
        %    rand('state',oldstate) %so that we don't keep making the same phases over and over again
        %end;
        %sP.phaseseed=rand('state'); %theoretically no use, but could be useful to have the record for error-checking purposes later on
        
        phases=rand(size(onsets))*(2*pi);
        if regenerationflag
            oldstate=rand('state'); %so that we don't reuse the numbers later
        end;
    end;
    
    %------if the sound needs repeated, repeat it
	if sP.repetitionflag
        sP.freqs = tmulticatmat(freqs,sP.nrepeats);
        sP.onsets = tmulticatmat(onsets,sP.nrepeats);
        sP.phases = tmulticatmat(phases,sP.nrepeats);
        
        %at this stage, the segments are "repeated" (or not), but sit on top of each other: need to add delays to each subsequent segment.
        repetitiondelays=zeros(size(sP.onsets));
        for rep=1:sP.nrepeats
            repetitiondelays(:,((rep-1)*ntones+1):(rep*ntones))= segdur*(rep-1);
        end;
        sP.onsets = sP.onsets + repetitiondelays;
	else
        sP.freqs=freqs;
        sP.onsets=onsets;
        sP.phases=phases;
	end;

end


%%%
% generate sounds
%%%
    
% Set up the envelopes
t = 0:1/sP.fs:sP.tonedur-1/sP.fs;
lt = length(t);
tr = 0:1/sP.fs:sP.rtime-1/sP.fs;
lr = length(tr);
rampup = ((cos(2*pi*tr/sP.rtime/2+pi)+1)/2).^2; 
rampdown = ((cos(2*pi*tr/sP.rtime/2)+1)/2).^2;

%work out the appropriate multiplier of the pure tones to acheive a mean RMS of sP.rmsnorm
ramppower=...
    (35*sP.rtime)/128 ...
    -(7*sP.rtime*sin((pi*sP.rtime)/sP.rtime))/(16*pi)...
    +(7*sP.rtime*sin((2*pi*sP.rtime)/sP.rtime))/(64*pi)...
    -(sP.rtime*sin((3*pi*sP.rtime)/sP.rtime))/(48*pi)...
    +(sP.rtime*sin((4*pi*sP.rtime)/sP.rtime))/(512*pi); %integral of the ramp courtesy of Mathematica
tonermsuncorrected=sqrt((sP.tonedur-2*sP.rtime+2*ramppower)/sP.tonedur);
normalisationmultiplier=sP.rmsnorm/tonermsuncorrected*sqrt(sP.segdur*(sP.nrepeats^(1-sP.repetitionflag))/(ntones*nchannels*sP.tonedur));

%it gets worse: if the spectrum is shaped, then we'll need to correct for that too
if isfield(sP,'levelmapper')
    samplefrequencies=logspace(log10(sP.lowchan),log10(sP.highchan),10000); %take X frequencies evenly spread throughout the range
    samplemultipliers=sP.levelmapper(samplefrequencies,sP); %applies a spectrum
    averagemultiplier=rms(samplemultipliers);
    normalisationmultiplier=normalisationmultiplier/averagemultiplier;
end;

envelope=sqrt(2)*normalisationmultiplier*ones(size(t));
envelope(1:lr) = rampup.*envelope(1:lr);
envelope(lt-lr+1:lt) = rampdown.*envelope(lt-lr+1:lt);

% One way to apply a particular spectrum to the pure tones is to multiply
% each tone by a multiple (lingain) depending on its frequency.
if isfield(sP,'levelmapper')
    sP.lingain=sP.levelmapper(sP.freqs,sP); %applies a spectrum
end;

% finally, generate the tone cloud
x = zeros(1,round((sP.segdur*sP.nrepeats+sP.tonedur)*sP.fs)); %NB slightly longer, to allow trailing tones
for ichan = 1:1:size(sP.freqs,1)
    for itone = 1:1:size(sP.freqs,2)
        s = sin(2*pi*sP.freqs(ichan,itone)*t+sP.phases(ichan,itone)); %generate tone
        
        %ramp and attenuate the tones
        if isfield(sP,'lingain')
            s = sP.lingain(ichan,itone)*s.*envelope;
            %if ((ichan==20||ichan==21||ichan==22||ichan==23)&&itone<(size(sP.freqs,2)/2)); s=s*0; end; warning('Hacked')
            %if ((ichan==20)&&itone<(size(sP.freqs,2)/2)); s=s*0; end; warning('Hacked')
        else
            s = s.*envelope;
        end;
        
        %add it to the wave so far
        istart = ceil(sP.onsets(ichan,itone)*sP.fs); %rounding up to avoid zeros
        iend = istart+lt-1;
        x(istart:iend) = x(istart:iend)+s;
        
    end
end

if max(abs(x)>0.9999)
	error('Clipped!')
end

if seededflag
    rand('state',oldstate) %put the state back where it was found
end;

%NB this will be different even for the same seed!
if isfield(sP,'scannernoise')&&sP.scannernoise~=999
    x=taddscannernoise(x,sP.scannernoise);
end;

%sP can get too big. May as well get rid of unnecessarily large fields: can always reconstruct them from sP.seed if necessary
sP=rmfield(sP,{'freqs' 'onsets' 'phases'});
if isfield(sP, 'lingain'); sP=rmfield(sP, 'lingain'); end;
if exist('levelmappername','var')
    sP.levelmapper=levelmappername;
end;


function bigvector=tmulticatmat(littlevector,N) %Concatenates littlevector N times

[height,width]=size(littlevector); %#ok<NASGU>
bigvector=zeros(height,width*N);

%populate it with lots of littlevectors
for kk=1:N;
    bigvector(:,1+(kk-1)*width:kk*width)=littlevector;
end;