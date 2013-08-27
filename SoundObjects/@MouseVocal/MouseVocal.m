function o = MouseVocal (varargin)

% Nima Mesgarani, Apr 2007

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject('MouseVocal', 100000, 0, 0, 0, {}, 1, ...
                    {'Duration','edit',3,'Subsets','edit',1, ...
                     'NoiseType','popupmenu',...
                     'None|White|Pink|Jet2|F16|MachineGun|City|SpectSmooth',...
                     'SNR','edit',1000,'ReverbTime','edit',0});
    o.Subsets = 1;
    o.SNR=100;
    o.NoiseType = 'White';
    o.ReverbTime = 0;
    o.Duration = 3;
    o.SoundPath = '';
    o = class(o,'MouseVocal',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'MouseVocal')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end
