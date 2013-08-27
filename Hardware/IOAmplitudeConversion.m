function out = IOAmplitudeConversion(in,direction)
% StimConversion  converts between SPL [dB] and Voltage for fixed relationship on the stimulating machine 
%  The logarithmic relationship
%
%    SPL_1rel0 [dB] = 20 * log_10 (V1/V0)
%
%  between the relative Sound Pressure Level (SPL_1rel0) in dB units and V1 
%  with respect to the base voltage V0 is assumed. Absolute SPLs are attained 
%  by adding SPL_1rel0 and SPL(V0), which was 80dB in this case. 
%  The corresponding S0 was 1/sqrt(2) = rms of a Sine.
% 
%  Data for this conversion was measured using a B&K 2160 Measurement Amplifier
%  equipped with a B&K 4135 Condensor Microphone.
%  The Calibration Tones were produced by a B&K 4231 Tone Generator 
% 
%  Settings on the B&K 2160 were: 
%   Input Gain: 20 dB
%   Cal Gain: 0 dB
%   Output Gain: 0 dB
%
%   Input: Preamp
%   Ref: off
%   Polarisation Voltage: 200 V
%
%   Ext&A Filters : off
%   22.4Hz High Passfilter: On
%   Averaging Time: Fast
%   Detector: RMS
%
%  Settings on the B&K Microphone were: 
%   plugged into the frontal direct input.
%   0 dB Amplification
%
%  The measured voltage was sent to a RP2 RTP via the front AC 1V BNC connector.
% 
% see also: SpeakerCalib, SpeakerCalibBare, VolumeConversion

dBSPL0 = 80; S0 = 5/sqrt(2);
%Pa0 = 0.00002; %20uPa [Pa]
switch direction
  case 'dB2S'
    out = S0*10.^((in-dBSPL0)/20);
%  case 'S2dB'
%   out = dBSPL0 + 20*log10(in/S0);  
%  case 'dB2Pa'
%   out = Pa0*10.^(in/20);
%  case 'Pa2dB'
%   out = 20*log10(in/Pa0);
  otherwise error('Not a valid conversion!');
end