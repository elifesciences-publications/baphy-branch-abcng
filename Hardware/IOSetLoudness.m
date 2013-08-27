function HW=IoSetLoudness(HW, dB);
%
%

% SVD add for multi-lab configuration:
if isfield(HW.params,'SoftwareAtten') && HW.params.SoftwareAtten,
  HW.SoftwareAttendB=dB;
  return;
end

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
