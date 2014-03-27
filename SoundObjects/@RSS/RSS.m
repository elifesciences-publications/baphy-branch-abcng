function o = RSS (varargin)

% Sean Slee, Mar 2014

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject('RSS', 100000, 0, 0, 0, {}, 1, ...
                    {'Duration','edit',1,'Subsets','edit',1, ...
                     'NoiseType','popupmenu',...
                     'None|White|Pink|Jet2|F16|MachineGun|City|SpectSmooth',...
                     'SNR','edit',1000,'ReverbTime','edit',0});
    o.Subsets = 1;
    o.SNR=100;
    o.NoiseType = 'White';
    o.ReverbTime = 0;
    o.Duration = 1;
    o.SoundPath = '';
    o = class(o,'RSS',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'RSS')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end