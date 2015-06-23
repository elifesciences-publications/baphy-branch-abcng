function o = Noise(varargin)
% Noise is the constructor for the object @Noise which is a child of  
%       SoundObject class
%
% Run class: NSE
%
% Contiuous white (or other?) noise. Use same noises added to speech sounds.
%
% usage:
% To create a NoiseBurst with default values.
%   t = Noise;
%
% To get the waveform and events:
%   [w, events] = waveform(t,idx);  
%
% methods: set, get, waveform, ObjUpdate

% SVD created 2007-08-05, based on ComplexChord object.

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Noise', 100000, 0, 0.4, 0.4, {}, 1, ...
      {'NoiseType','popupmenu','None|White|Pink|Jet2|F16|MachineGun|City',...
       'LowFreq','edit',250,...       
       'HighFreq','edit',8000,...       
       'TonesPerBurst','edit',20,...
       'Duration','edit',3,...
       'Frozen','edit',[]});
    o.NoiseType = 'White';
    o.Duration = 3;
    o.Frozen = [];
    o.Count = 30;
    o.LowFreq = 250;
    o.HighFreq = 8000;
    o.TonesPerBurst=20;
    o.Filter=[];
    o.SoundPath='';
    o.Names={};

    o = class(o,'Noise',s);
    o = ObjUpdate (o);
    
 otherwise
    error('Wrong number of input arguments');
end