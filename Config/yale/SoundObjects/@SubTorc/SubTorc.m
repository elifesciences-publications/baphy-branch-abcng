function o = SubTorc (varargin)

% SVD hacked from MouseVocal

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject('SubTorc', 100000, 0, 0.5, 0.5, {}, 1, ...
                    {'Duration','edit',3,...
                     'Subsets','edit',1});
    o.Subsets = 1;
    o.SNR=100;
    o.NoiseType = 'White';
    o.ReverbTime = 0;
    o.Duration = 3;
    o.SoundPath = '';
    o = class(o,'SubTorc',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end
