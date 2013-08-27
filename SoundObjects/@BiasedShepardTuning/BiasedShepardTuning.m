function o = BiasedShepardTuning(varargin)
% BiasedShepardTuning produces a sequence of Shepard tones with a preceding bias
%
% The parameters are explained in the code.
%
% benglitz 2011

% Technical Note:
% - edit fields contain strings
% - Object fields of parameter names contain cells
%
% Initial Set of Trials:
% Index selects between 20 Indices
% 4 Pitchclasses for the Biasing Region
% 5 Randomizations
% 24 TestPitches
% 10 Repetitions
%
% Length of each presentation 5*24*0.15 = 18s

switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'PitchSteps','edit','24',...
      'BiasDur','edit','0.1',...
      'TestDur','edit','0.1',...
      'BetweenBiasPause','edit','0.05',...
      'AfterBiasPause','edit','0.05',...
      'NBiasStim','edit','5',...
      'NBiasLeadIn','edit','10',...
      'Randomizations','edit','5',...
      'BiasPitchRange','edit','3',...
      'BiasBasePitches','edit','0 3 6 9',...
      'BaseFreqs','edit','440',...
      'BaseSeps','edit','1',...
      'EnvStyle','popupmenu','Constant|Gaussian|Tones',...
      'EnvCenters','edit','440',...
      'EnvWidths','edit','4',...
      'Amplitudes','edit','70',...
      };
    s = SoundObject ('BiasedShepardTuning', 40000, 0,0.4, 0.4, {''}, 1, Fields);
    for i=1:length(Fields)/3 o.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    o.Fields = Fields;
    o.FieldNames = Fields(1:3:end-2); 
    o.FieldTypes = Fields(2:3:end-1);
    o.MaxIndex = 0;
    o.LastBiasBasePitch = [];
    o.LastBiasPitches = [];   
    o.LastTestPitches = [];
    o.LastRandomization = []; 
    o.LastSeeds = [];
    o.Names = {};
    o.Par = [];
    o.RunClass = 'BST'; o.Duration = NaN;
    o = class(o,'BiasedShepardTuning',s);
    o = ObjUpdate(o);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end