function o = ShepardTuning(varargin)
% ShepardTuning produces random sequences of 
%
% The parameters are listed in the code.
%
% benglitz 2011

% Technical Note:
% All Stimuli are presented in one sequence and then
% Randomization : controlled via the field randomizations 
% To make it compatible across different resolutions, 
% the initial sequences of 1/12, 1/24, 1/48 are the same

switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'PitchSteps','edit','48',... %
      'StimDur','edit','0.1',...
      'PauseDur','edit','0.05',...
      'Randomizations','edit','5',... % Results in the number of indices
      'BaseFreqs','edit','440',...
      'BaseSeps','edit','1',...
      'EnvStyle','popupmenu','Constant',...
      'EnvCenters','edit','440',...
      'EnvWidths','edit','4',...
      'Amplitudes','edit','70',...
      };
    s = SoundObject ('ShepardTuning', 40000, 0,0.4, 0.4, {''}, 1, Fields);
    for i=1:length(Fields)/3 o.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    o.Fields = Fields;
    o.FieldNames = Fields(1:3:end-2); 
    o.FieldTypes = Fields(2:3:end-1);
    o.MaxIndex = 0; o.Names = {}; o.Par = [];
    o.RunClass = 'SHT'; o.Duration = NaN;
    o.LastPitchSequence = [];
    o.LastSeeds = [];
    o = class(o,'ShepardTuning',s);
    o = ObjUpdate(o);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end