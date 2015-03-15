function o = WhiteNoise(varargin)
% WhiteNoise produces simple Gaussian White noise
%
% benglitz 2010

switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'StimDuration','edit','1',...
      };
    s = SoundObject ('WhiteNoise', 100000, 0,0.4, 0.4, {''}, 1, Fields);
    for i=1:length(Fields)/3 o.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    o.Fields = Fields;
    o.FieldNames = Fields(1:3:end-2); 
    o.FieldTypes = Fields(2:3:end-1);
    o.MaxIndex = 0;
    o.Names = {};
    o.Ranges = {}; o.VarFieldNames = {};  o.VarFieldInds = []; o.Par = [];
    o.RunClass = 'WHN'; o.Duration = NaN;
    o = class(o,'WhiteNoise',s);
    o = ObjUpdate(o);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end