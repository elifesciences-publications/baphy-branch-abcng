function o = PfCSoundSet (varargin)

% PBY, Aug 2007

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('PfCSoundSet', 40000, 0, 0.2, 0.8, {}, 1, {'Duration','edit',0.3,'Subsets','edit',1});    
    o.Subsets = 1;
    o.SNR=100;
    o.Duration = 0.3;
    o = class(o,'PfCSoundSet',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'PfCSoundSet')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end