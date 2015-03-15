function out = M_VolumeConversion(in,direction,Microphone)
% VolumeConversion converts between SPL [dB] and Voltage
% at the output of the Etymotic Research ER7C microphone amp.
%
%  The logarithmic relationship
%
%    SPL_1rel0 [dB] = 20 * log_10 (V1/V0)
%
%  between the relative Sound Pressure Level (SPL_1rel0) in dB units and V1 
%  with respect to the base voltage V0 is assumed. Absolute SPLs are attained 
%  by adding SPL_1rel0 and SPL(V0), which was 94dB in this case. 
%  The corresponding V0 = RMS of a Sine (@1000Hz,X dB), 
%   where X depends on the calibration system.
%
% Measurement Setup for:
% - Etymotic ER-7C
%  The well defined probe tone (1000Hz, 94dB)is generated 
%  in the little hole on the upper right hand.
%  The rubber recording tube has to be inserted into this tube for calibration.
%  The switch under "Output" produces two probe tones:
%   Setting:  '0'    :  corresponds to 94dB (Typical value for V0: 0.049)
%   Setting: '-20' :  corresponds to 74 dB (Typical value for V0: 0.005)
% 
% - BK 4944 A
%  Amplification set to 10x
%
%  The measured voltage was sent to a NIDAQ-card, 
%  where it was digitized and measured.
%
% see also: M_SpeakerCalibration
%
% This file is part of MANTA licensed under the GPL. See MANTA.m for details.

if ~exist('Microphone','var') Microphone = 'none'; end

switch Microphone
  case 'Didier';          dBSPL0 = 94; V0 = 0.0404;
  case 'Etymotic';      dBSPL0 = 94; V0 = 0.049;
  case 'BK4944A';      dBSPL0 = 94; V0 = 0.0085; % Measurements in Volts
  case 'GRAS46BE';   dBSPL0 = 94; V0 = 0.004; % Measurements in Volt  
  case 'PCB';              dBSPL0 = 114; V0 = 0.017; % SVD lab at OHSU
  case 'none';            dBSPL0 = 0; Pa0 = 20e-6; % Just for unit conversion Pa to dBSPL
  otherwise error('Microphone not tested yet.');
end
switch direction
  case 'dB2V';        out = V0*10^((in-dBSPL0)/20);
  case 'V2dB';    out = dBSPL0 + 20*log10(in/V0);
  case 'dB2Pa'; out =  Pa0*10^((in-dBSPL0)/20);
  case 'Pa2dB';  out =  dBSPL0 + 20*log10(in/Pa0);
  otherwise error('Not a valid conversion!');
end