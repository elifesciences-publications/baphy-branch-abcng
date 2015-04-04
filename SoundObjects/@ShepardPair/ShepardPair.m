function o = ShepardPair(varargin)
% ShepardPair produces a sequence of two Shepard tones
%
% benglitz 2010

switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'PitchClasses','edit','0 3 6 9',...
      'PitchSteps','edit','-3 -1 1 3 6'...
      'PairDurations','edit','0.1',...
      'BetweenPairPause','edit','0.05',...
      'BaseFreqs','edit','440',...
      'BaseSeps','edit','1',...
      'EnvStyle','popupmenu','Constant|Gaussian|Tones',...
      'EnvCenters','edit','440',...
      'EnvWidths','edit','4',...
      'Amplitudes','edit','70',...
      'Spatialization','edit','1',...
      };
    s = SoundObject ('ShepardPair', 100000, 0,0.4, 0.4, {''}, 1, Fields);
    for i=1:length(Fields)/3 o.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    o.Fields = Fields;
    o.LastBiasDirection = [ ];
    o.FieldNames = Fields(1:3:end-2); 
    o.FieldTypes = Fields(2:3:end-1);
    o.MaxIndex = 0;
    o.Names = {};
    o.Ranges = {}; o.VarFieldNames = {};  o.VarFieldInds = []; o.Par = [];
    o.RunClass = 'SHP'; o.Duration = NaN;
    o.AllTargetPositions = [];
    o.CurrentTargetPositions = [];
    o.LastPitchSequence = [];
    o = class(o,'ShepardPair',s);
    o = ObjUpdate(o);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end