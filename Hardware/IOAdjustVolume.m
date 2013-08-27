function Signal = IOAdjustVolume(Signal,dBSPL,varargin)
% IOAdjustVolume is used adjust the volume of a given signal,
% by scaling it to a level, which after convolution with the
% inverse impulse response and feeding through the speaker
% will correspond to the specified level in dB.
%
% Signal = IOAdjustVolume(Signal,dBSPL,varargin)
% Arguments: 
% - Signal       : the sound signal to be played
% - dBSPL      :  the target volume
% - varargin   : either a struct with the following fields, or a 
%  - Method  : {'Peak2Peak' | 'RMS'} different Methods for computing the volume
%         Peak2Peak : appropriate for strongly modulated sounds (transient volume)
%         RMS  :  appropriate for continuous noiselike sounds (ambient volume)      
%  - dBSPLRef : Level for which calibration was performed
%  - VRef         : Voltage chosen to represent the calibrated level
%
% MORE DETAILS ON CALIBRATION
%
% Since calibration is a delicate process, a schematic is profided here: 
% 
%  S_original : Original Signal (unscaled) with target dB SPL 
%                      This signal can in principle be unlimited. 
%   ||                 We choose ||IIR||=1, so that ||S_conv| = ||S_orig * IIR||
%   ||                 for a white gaussian noise input signal S_orig.
%   || 
%   ||   S_IIR = conv(S_original,IIR)
%   ||
%   V
%
%  S_IIR : Signal convolved with IIR
%             This signal is sent out to the amplifier, hence is limited to [-10,10]V
%   ||        The impulse response (IR) depends on the speaker and the amplifier,
%   ||        where ideally the amplifier only scales the speakers impulse response.
%   ||        The scaling by the amplifier sets the level and therefore has to be fixed
%   ||        from calibration to presentation.
%   ||
%   ||   S_speaker = conv(S_IIR,IR)
%   ||
%   V
%
%  S_speaker : Original Signal (ideally), scaled to target SPL
%                      (for the given Speaker, Booth, and setting of the Amplifier)
%                     The units of S_speaker could be measured in Pa.
%                     We only obtain indirect access via the Micophone which 
%                     has an internal scaling, which we measured at some point.
%
% To stay loosely compatible with the previous system of adjusting volume
% two choices were made here:
%
% - Reference level: 
%   - A sinus ranging [-5,5] outputs at 80dB (Method  : Peak2Peak)
%   - Consistently, a signal with RMS = 5/sqrt(2) outputs at 80dB (Method : RMS)
% - Methods for Scaling
%   - Peak2Peak : Scaling is based on the range of the signal (useful for speech etc.)
%   - RMS : Scaling is based on the RMS of the signal (useful for continuous signals, e.g. TORCs)
%
% Using the different methods will generally lead to different output volume 
% (one (among a number of) exception(s) is the pure tone).
% 
% Maximal Volume:
%  - Peak2Peak : here a maximal output volume can be specified independent 
%             of the signal, namely a factor of 2 in Volts above the standard volume
%             (usually 80 dB), i.e. 86dB.
%  - RMS : here the maximal volume depends on the signal, since the peaks
%                of the signal have to remain within [-10,10] Volts. To enlarge this range
%                the standard volume can be made variable and set above 80 dB.
%
% See also : M_SpeakerCalibration, IOLoadSound, InitializeHW

% PARSE ARGUMENTS
if length(varargin)==1 % Arguments provided as a struct
  P = varargin{1};
else
  P = parsePairs(varargin);
end
if ~isfield(P,'Method') P.Method = 'Peak2Peak'; end
% By making dBSPLRef a variable, one can also calibrate for louder sounds.
if ~isfield(P,'dBSPLRef') P.dBSPLRef = 80; end
% Since VRef here refers to the onesided peak voltage of a pure tone
% the VRef for RMS would be VRef/sqrt(2). This is corrected below by scaling
% the signal's RMS voltage with sqrt(2).
if ~isfield(P,'VRef') P.VRef = 5; end

% GET CURRENT VOLTAGE LEVEL
% note that Vcurrent is scaled by sqrt(2) for RMS to match 
% the scaling of both methods for a pure tone
switch P.Method
  case 'Peak2Peak';    Vcurrent = max(abs(Signal));
  case 'RMS';               Vcurrent = sqrt(2)*std(Signal);
  otherwise error('Unknown Method specified!');
end

% COMPUTE SCALING FACTOR
Factor = P.VRef/Vcurrent * 10^((dBSPL - P.dBSPLRef)/20);
Signal = Signal * Factor;