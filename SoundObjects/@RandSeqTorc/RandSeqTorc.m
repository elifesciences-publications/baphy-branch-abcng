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
        {''}, 1, {'FirstFrequency','edit',[8372],...
        'Intervals', 'edit', [0 -2 1 -2],...
        'NoteDur','edit',0.075,...
        'NoteGap','edit',0.025,...
        'SequenceGap','edit',0.25,...
        'TORC','popupmenu','yes|no',...
        'IsRef','popupmenu','yes|no',...
        'IsBuzz' ,'popupmenu','yes|no',...
        'TorcDuration','edit',1,...
        'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|U:1000-32000 Hz|W:2000-64000 Hz|Y:1000-32000 Hz|Z:150-38400 Hz',...
        'TorcRates','popupmenu','1:1:8|4:4:24|4:4:48|8:8:48|8:8:96',...       
        'OctaveRange','edit',[0 1],...
        'OctaveStep','edit',0.25,...
        'Key', 'edit', [],...
        'TrialN','edit',0,...
        'MaxIndex','edit', 3,...
        'SimilareTones','edit',[1 0 0 0]});
        %'Type','popupmenu','Single'});  %
    o.FirstFrequency = [8372];
    o.Intervals = [0 -2 1 -2]
    o.NoteDur = 0.075;
    o.NoteGap = 0.025;
    o.TORC = 'yes';
    o.OctaveRange=[0 1];      %contour move up/down tange in octave
    o.OctaveStep = 0.25;      %step in octave
    o.SequenceGap = [0.5];
    o.TorcDuration = [1];
    o.FrequencyRange = 'L:125-4000 Hz';
    o.TorcRates = '4:4:48';
    o.Key = [];
    o.TrialN = 0;
    o.PastRef = [];
    o.SimilareTones = [1 0 0 0];
    o.AllTargetPositions = [];
    o.CurrentTargetPositions = [];
    o.MaxIndex = 3;
    o.DifficultyLvlByInd = [];
    o.IsRef = 'yes';
    o.IsBuzz = 'yes';
%     o.Index = 0;
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