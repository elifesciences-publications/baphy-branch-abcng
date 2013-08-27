function O = BiasedShepardPair(varargin)
% BiasedShepardPair produces a sequence of Shepard tones with a preceding bias
%
% The parameters are:
% - Durations : Duration [s], if only one value, all are the same length
%
% benglitz 2010

% Technical Note:
% - edit fields contain strings
% - Object fields of parameter names contain cells
%
% Initial Set of Trials:
% Index selects between 16 conditions
% 4 Pitchclasses
% 2 Biasdirections
% 2 Different sequences for each 
% 1 Set of frozen random phases
% 5 Repetitions
% i.e. requires 80 correct Behaviortrials
%
% Second Set of Trials (allows for different Trial lengths)
% Index selects between 32 conditions
% 2 Different # of Biases (NBiasStims)
% 4 Pitchclasses (PitchClasses)
% 2 Biasdirections (BiasDirections)
% 2 Different sequences for each (NBiases) 
% 1 Set of frozen random phases
% 5 Repetitions
% i.e. requires 160 correct Behaviortrials


switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'PitchClasses','edit','0 3 6 9',...
      'PairDurations','edit','0.1',...
      'BetweenPairPause','edit','0.05',...
      'NBiasStims','edit','10 5',...
      'NBiases','edit','2',...
      'BiasDurations','edit','0.1',...
      'BetweenBiasPause','edit','0.05',...
      'AfterBiasPause','edit','0.05',...
      'BiasPitchRange','edit','5',...
      'BiasDirections','edit','-1 1',...
      'BaseFreqs','edit','440',...
      'BaseSeps','edit','1',...
      'ComponentJitter','edit','0',...
      'EnvStyle','popupmenu','Constant|Gaussian|Tones',...
      'EnvCenters','edit','440',...
      'EnvWidths','edit','4',...
      'Amplitudes','edit','70',...
      };
    S = SoundObject ('BiasedShepardPair', 40000, 0,0.4, 0.4, {''}, 1, Fields);
    for i=1:length(Fields)/3 O.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    O.Fields = Fields;
    O.LastBiasDirection = [ ];
    O.FieldNames = Fields(1:3:end-2); 
    O.FieldTypes = Fields(2:3:end-1);
    O.MaxIndex = 0;
    O.LastShifts = [];
    O.Names = {};
    O.NBiasStimByIndex = [];
    O.PitchClassByIndex = [];
    O.BiasByIndex = [];
    O.BiasDirectionByIndex = [];
    O.NStreams = []; O.Ranges = {}; O.VarFieldNames = {};  O.VarFieldInds = []; O.Par = [];
    O.RunClass = 'BSP'; O.Duration = NaN;
    O = class(O,'BiasedShepardPair',S);
    O = ObjUpdate(O);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end