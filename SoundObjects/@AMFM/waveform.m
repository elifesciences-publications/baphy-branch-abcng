function [w, event]=waveform (o,index,void)
% function w=waveform(amfm,index);
% this function is the waveform generator for object AMFM

% NIMA IS HACKING THIS CODE!! December 2008
% since JSimon doesn't seem to use this code anymore, and JBF want to use
% it, but only with the last FM and AM (1-1) case:
% index = get(o,'MaxIndex');
% Nima stops

event = [];
% the parameters of AMFM object
SamplingRate = ifstr2num(get(o,'SamplingRate'));
PreStimSilence = ifstr2num(get(o,'PreStimSilence'));
PostStimSilence = ifstr2num(get(o,'PostStimSilence'));
Names = get(o,'Names');
Duration = ifstr2num(get(o,'Duration')); % duration in seconds
Freq_Carrier = ifstr2num(get(o,'Freq_Carrier')); % carrier frequency in Hz
% Freq_AM_List = ifstr2num(get(o,'Freq_AM_List')); % list of AM frequencies in Hz
% Freq_FM_List = ifstr2num(get(o,'Freq_FM_List')); % list of FM frequencies in Hz
Modulation_AM = ifstr2num(get(o,'Modulation_AM')); % AM modulation depth (out of 1)
Modulation_FM = ifstr2num(get(o,'Modulation_FM')); % FM Modulation range in octaves
Ramp_Duration = ifstr2num(get(o,'Ramp_Duration')); % on and off ramp duration in seconds

FullAMList = get(o,'FullAMList'); % full list of AM frequencies in Hz
FullFMList = get(o,'FullFMList'); % full list of FM frequencies in Hz

% generate the AMFM Carrier
timesamples = [(0 : Duration*SamplingRate-1)].' / SamplingRate;

% Create FM
f_FM = FullFMList(index);
if (f_FM==0)
    w = cos(2*pi*Freq_Carrier*timesamples);
else
	mod_FM_sig = sin(2*pi*f_FM*timesamples);
	mod_FM_excursion=(2.^Modulation_FM-1)/(2.^Modulation_FM+1);
	w = modulate(mod_FM_sig,Freq_Carrier,SamplingRate,'fm',...
		2*pi*Freq_Carrier/SamplingRate*mod_FM_excursion);
end

% Add AM
f_AM = FullAMList(index);
if (f_AM~=0)
	mod_AM_sig =sin(2*pi*f_AM*timesamples);
	w = w.*(1+Modulation_AM*mod_AM_sig);
end


%  ramp at onset & offset
ramp = hanning(round(Ramp_Duration * SamplingRate * 2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);

% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,1) ; w ;zeros(PostStimSilence*SamplingRate,1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

% Signal must be scaled to fit within +/- 5 (volts?)
w = 4.99 * w/max(abs(w));

% Signals without AM have too much variance/power when scaled by their max,
% relative to signals with strong modulation depth.
if (f_AM==0)
    w = w * 0.6250; 
end

