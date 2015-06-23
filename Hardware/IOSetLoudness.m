function HW=IOSetLoudness(HW, dB);
% IOSetLoudness adjusts the loudness given the input value
% For most recent setups this just means setting a variable, 
% whereas in older setups the hardware attenuator is contacted
%
% The concept for setting loudness is such that the soundobjects prepare 
% all their sound objects at a nominal level of 80 dB, which corresponds to
% ->  5 V = 80 dB (this applies to NSL and most other labs) 
% -> local std (computed via maxLocalStd.m) = 1V = 80dB (for ABCNG)
% Since outside of the sound objects, baphy just attenuates by a certain amount,
% baphy does not need to know about the difference between these two
% computations, however, the individual sound objects have to be aware of it.
% For backward compatibility, a sound object sets a parameter, if it makes
% this computation itself, otherwise it is performed in IOLoadSound.

% SVD add for multi-lab configuration:
if isfield(HW.params,'SoftwareAtten') && HW.params.SoftwareAtten,
  HW.SoftwareAttendB=dB;
  return;
end

% BE: THESE SETUP NUMBER ONLY PERTAIN TO THE NSL CONFIGS
switch HW.params.HWSetup
  case {0,2,4}              % Test mode
    % how do you know??
    % Attenuation should just be applied to the signal before it's
    % loaded.  Is this happening now???
  case {1,3,5,8,11}
    Attenuate(HW.Atten,dB);
  case {7,9,12,10}
    HW.SoftwareAttendB = dB;
end