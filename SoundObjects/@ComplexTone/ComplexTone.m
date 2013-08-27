function o=ComplexTone(varargin)
% ComplexTone generates a harmonic/inharmonic complex tone, with acomponent
% equal to the anchor frequency separated by silence gap 
%
% To create a ComplexTone with default values.
%   t = ComplexTone;
%
% To create a ComplexTone with specified values:
%
%
% To get the waveform and events:
%   [w, events] = waveform(t);
%
% methods: set, get, waveform, ObjUpdate
%
% Mai December 2008

switch nargin
    case 0
        % if no input arguments, create a default object
        s= SoundObject('ComplexTone', 40000, 0, 0, 0, ...
            {''}, 1, {'AnchorFrequency','edit', 1000, ...
            'ComponentsNumber','edit',4,...
            'ComplexToneDur','edit',0.3,...
            'GapDur','edit',0,...
            'PoolSize','edit',5});

        o.AnchorFrequency= 1000;
        o.ComponentsNumber= 4;
        o.ComponentRatios= [2;3/2;4/3];
%         o.ComponentsNumber= 6;
%         o.ComponentRatios= [2;3/2;4/3;5/4;6/5];
        o.PoolSize= 24;
        o.ComplexToneDur= 0.3;
        o.GapDur= 0;
        o.FrequencyOrder= 1;
        o= class(o,'ComplexTone',s);
        o= ObjUpdate (o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'SoundObject')
            o= varargin{1};
        else
            error('Wrong argument type');
        end
    otherwise
        error('Wrong number of input arguments');
end

