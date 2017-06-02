function o = RandSeqTorc(varargin)
% ToneSequence
% related function: set, get, waveform
%   
% Pingbo, Decemebr 2005
% modifed in April, 2006
switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('RandSeqTorc', 100000, 0, 0.4, 0.8, ...
        {''}, 1, {'FirstF','edit',[ 8372 ],...
        'RampInterval', 'edit', 0.3 ,...
        'ToneDur','edit',0.075,...
        'ToneGap','edit',0.025,...
        'SequenceGap','edit',0.25,...
        'LoudnessCue','edit',0,...
        'TORC','popupmenu','yes|no',...
        'SameRef','popupmenu','yes|no',...
        'TorcDuration','edit',1,...
        'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|U:1000-32000 Hz|W:2000-64000 Hz|Y:1000-32000 Hz|Z:150-38400 Hz',...
        'TorcRates','popupmenu','1:1:8|4:4:24|4:4:48|8:8:48|8:8:96',...       
        'OctaveRange','edit',[0 1],...
        'OctaveStep','edit',0.25,...
        'MaxIndex','edit', 3,...
        'IdenticalTones','edit',[1 0 0 0],...
        'UniqueToneIndex','edit',2,...
        'RampProbability','edit',0});
        %'Type','popupmenu','Single'});  %
    o.FirstF = [8372];
    o.TargetF = [ 8372  7459  7902 7040 ];   % -2 +1 -2 semitone-intervals
    o.RampsF = [];
    o.RampInterval = 0.3;
    o.ToneDur = 0.075;
    o.ToneGap = 0.025;
    o.SequenceGap = 0.5;
    o.LoudnessCue = 0;
    o.TORC = 'yes';
    o.OctaveRange=[0 1];      %contour move up/down tange in octave
    o.OctaveStep = 0.25;      %step in octave    
    o.TorcDuration = [1];
    o.FrequencyRange = 'L:125-4000 Hz';
    o.TorcRates = '4:4:48';
    o.Key = []; 
    o.PastRef = [];
    o.IdenticalTones = [1 0 0 0];
    o.AllTargetPositions = [];
    o.CurrentTargetPositions = [];
    o.MaxIndex = 3;
    o.UniqueToneIndex = 2;
    o.SameRef = 'no';
    o.RampProbability = 0;
    o.Names = {};

    %o.Type='Single';  %or 'multiple' sequency
    o = class(o,'RandSeqTorc',s);
    o = ObjUpdate(o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end