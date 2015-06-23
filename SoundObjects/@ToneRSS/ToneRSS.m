function o = ToneRSS(varargin)
% ToneRSS = tone embedded in RSS, ripped off of Tone
% methods: set, get, waveform, ObjUpdate

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('ToneRSS', 100000, 0, 0, 0, ...
        {''}, 1, {'Frequencies','edit',1000,...        
        'Duration','edit',1,'Subsets','edit',1,'SNR','edit',100,...
        'SplitChannels','popupmenu','no|yes'});
    o.Frequencies = 1000;
    o.Duration = 1;
    o.Subsets = 2;
    o.SNR=0;
    o.SplitChannels = 'no';
    % internal variables for tracking relevant RSS files.
    o.SoundPath = '';
    o.RSSNames={};
    o.FreqNames={};
    
    o = class(o,'ToneRSS',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end