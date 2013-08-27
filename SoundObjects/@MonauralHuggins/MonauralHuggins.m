function O = MonauralHuggins(varargin)
% MonauralHuggins produces a single instance of a Huggins Pitch
%
% The parameters are listed in the code.
%
% benglitz 2011

switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'Frequencies','edit','250 500 1000',... %
      'AngularFrequency','edit','2',...
      'Density','edit','0.5',...
      'ModulationDepth','edit','0.9',...
      'StimDur','edit','1',... % Results in the number of indices
      };
    s = SoundObject ('MonauralHuggins', 40000, 0,0.4, 0.4, {''}, 1, Fields);
    for i=1:length(Fields)/3 O.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    O.Fields = Fields;
    O.FieldNames = Fields(1:3:end-2); 
    O.FieldTypes = Fields(2:3:end-1);
    O.MaxIndex = 0; O.Names = {}; O.Par = [];
    O.RunClass = 'MHP'; O.Duration = NaN;
    O = class(O,'MonauralHuggins',s);
    O = ObjUpdate(O);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end