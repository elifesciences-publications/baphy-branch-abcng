function Calibration = IOLoadCalibration(varargin)
% IOLoadCalibration loads the calibration file 
% for a certain combination of Speaker and Microphone

% PARSE ARGUMENTS
if length(varargin)==1 % Arguments provided as a struct
  P = varargin{1};
else
  P = parsePairs(varargin);
end
if ~isfield(P,'Speaker') error('A speaker must be specified!'); end
if ~isfield(P,'Microphone') error('A microphone must be specified'); end

Sep = HF_getSep; Path = which('baphy');
Path = [Path(1:find(Path==Sep,1,'last')),'Hardware',Sep,'Speakers',Sep];

if length(P)==1
  SpeakerNb = 1;
else SpeakerNb = length(P);
end

for SpeakerNum = 1:SpeakerNb
  FileName = [Path,'SpeakerCalibration_',P(SpeakerNum).Speaker,'_',P(SpeakerNum).Microphone,'.mat'];
  % Return what has been passed (Speaker and Microphone names)
  Calibration(SpeakerNum) = P(SpeakerNum);
end

for SpeakerNum = 1:SpeakerNb
  if exist(FileName,'file')==2
    tmp = load(FileName); R = tmp.R;
  else
    error(['Calibration File "',escapeMasker(FileName),'" does not exist.']);
  end
  
  % Inverse impulse response which is scaled to have a norm of 1
  % for translating white noise from the original signal to the speaker signal
  Calibration(SpeakerNum).IIR = R.IIR80dB;
  % SR is passed in case a different SR is used and downsampling is necessary
  Calibration(SpeakerNum).SR = R.SR;
  % Calibration delay is used to shift the stimulus according to the time due to calibration
  Calibration(SpeakerNum).Delay = R.ConvDelay;
  % The LoudnessMethod is the Method used for assessing loudness of a stimulus
  Calibration(SpeakerNum).Loudness.Method = R.Loudness.Method;
  % The Parameters struct contains the parameters of the loudness method
  Calibration(SpeakerNum).Loudness.Parameters = R.Loudness.Parameters;
end




% OLD VERSION
%   FileName = [Path,'SpeakerCalibration_',P.Speaker,'_',P.Microphone,'.mat'];
%   if exist(FileName,'file')==2
%     tmp = load(FileName); R = tmp.R;
%   else
%     error(['Calibration File "',escapeMasker(FileName),'" does not exist.']);
%   end
%   
%   % Return what has been passed (Speaker and Microphone names)
%   Calibration = P;
%   % Inverse impulse response which is scaled to have a norm of 1
%   % for translating white noise from the original signal to the speaker signal
%   Calibration.IIR = R.IIR80dB;
%   % SR is passed in case a different SR is used and downsampling is necessary
%   Calibration.SR = R.SR;
%   % Calibration delay is used to shift the stimulus according to the time due to calibration
%   Calibration.Delay = R.ConvDelay;
%   % The LoudnessMethod is the Method used for assessing loudness of a stimulus
%   Calibration.Loudness.Method = R.Loudness.Method;
%   % The Parameters struct contains the parameters of the loudness method
%   Calibration.Loudness.Parameters = R.Loudness.Parameters;