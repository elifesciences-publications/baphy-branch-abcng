function Eye = IOEyeFixate(HW,AllowedRadius,CalibrationTest)
% function Eye = IOEyeFixate (HW,AllowedRadius)
%
% This function reads the eye position and determines
% whether the animal fixates (Eye = 1) or not (Eye = 0).
%
% Yves, December 2015
        
SensorNames = {HW.Didx.Name};
SensorChannels=find(strcmp(SensorNames,'Fixation'));

options.WhichSamples = 'last';
if ~exist('CalibrationTest','var') || ~CalibrationTest
  options.Calibration = 0;
else
  options.Calibration = 1;
end

Eye = ~IOLickRead(HW,SensorChannels);

% EyePos = IOEyePosition(HW,options);
% Eye = (sqrt(sum((EyePos-HW.VisionHW.CenterCoordinates).^2))<AllowedRadius);