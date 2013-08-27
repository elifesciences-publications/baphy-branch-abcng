function o = RandomMultitone (varargin)

% methods: set, get, waveform
%   
% usage: 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('RandomMultitone', 40000, 0,0.4, 0.8, ...
        {''}, 1, {'BaseFundamental','edit',1000,'OctaveBelow','edit',2,...
        'OctaveAbove','edit',3,'TonesPerOctave','edit',5,...
        'Duration','edit',1000,'NumOfHarmonics','edit',[2 3]});
    o.BaseFundamental = 250;
    o.OctaveBelow = 1;
    o.OctaveAbove = 1;
    o.TonesPerOctave = 2;
    o.Duration = 1;  %ms
    o.NumOfHarmonics = [2 3];
    o = class(o,'RandomMultitone',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end