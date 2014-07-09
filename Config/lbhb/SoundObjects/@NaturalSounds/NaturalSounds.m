function o = NaturalSounds (varargin)

% Nima Mesgarani, Apr 2007

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject('NaturalSounds', 48000, 0, 0, 0, {}, 1, ...
                    {'Duration','edit',3,'Subsets','edit',1,...
                     'NoiseType','popupmenu',...
                     'None|White|Pink|Jet2|F16|MachineGun|City|SpectSmooth',...
                     'SNR','edit',1000,'ReverbTime','edit',0, ...
                     'RepIdx','edit',[0 1]});
    o.Subsets = 1;
    o.SNR=100;
    o.NoiseType = 'White';
    o.ReverbTime = 0;
    o.Duration = 3;
    o.idxset=[];
    o.RepIdx=[0 1];
    o.SoundPath = '';
    o = class(o,'NaturalSounds',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'NaturalSounds')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end