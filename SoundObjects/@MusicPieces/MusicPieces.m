function o = MusicPieces(varargin)

% YB, June 2015

switch nargin
  case 0
    % if no input arguments, create a default object
    s = SoundObject('MusicPieces', 44100, 0, 0, 0, {}, 1, ...
      {'DatasetNum','edit','1',...
      });
    o.DatasetNum = 1;
    o.SoundPath = '';
    o.RunClass = 'MUS';
    o = class(o,'MusicPieces',s);
    o = ObjUpdate (o);
  case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'MusicPieces')
      o = varargin{1};
    else
      error('Wrong argument type');
    end
  otherwise
    error('Wrong number of input arguments');
end