function EyePos = IOEyePosition(HW,options)
% function EyePos = IOEyePosition (HW)
%
% This function reads the eye position signal from the daq card (connected to analog output 
% of the eye tracking system) and return it.
% if global.LickSign is one, the function return one if the DI is one,
% otherwise, it returns one when the DIO is zero.
%
% Yves, December 2015 (from IOLickRead)

names = []; Aux = [];
if ~exist('options','var')
  options.WhichSamples = 'end';
  options.Calibration = 0;
end
if HW.params.HWSetup==0,
    return
end

if strcmpi(IODriver(HW),'NIDAQMX'),
  AInum = find(~cell2mat(cellfun(@isempty,strfind({HW.AI.Names},'OnlineEye'),'UniformOutput',0)));
  d=niReadAIData(HW.AI(AInum));
  names=strsep(HW.AI(AInum).Names,',');
  EyeChannels=find(~cell2mat(cellfun(@isempty,strfind(names,'Eye'),'UniformOutput',0)));
  switch options.WhichSamples
    case 'last'
      EyePos = d(end,EyeChannels);
    case 'all'
      EyePos = d(:,EyeChannels);
  end
  if ~options.Calibration
    EyePos = min( sum( (HW.VisionHW.ET2ScreenMatrix{1}-EyePos(1)).^2 , (HW.VisionHW.ET2ScreenMatrix{2}-EyePos(2)).^2 ) );
  end
  EyePos = EyePos([2 1]);
  
  return
end


