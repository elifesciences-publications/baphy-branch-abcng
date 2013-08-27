function o = ToneSequence(varargin)
% ToneSequence
% related function: set, get, waveform
%   
% Pingbo, Decemebr 2005
% modifed in April, 2006
switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('ToneSequence', 40000, 0,0, 0, ...
        {''}, 1, {'Frequency','edit',[500 800],...
        'NoteDur','edit',0.075,'NoteGap','edit',0.025,...
        'OctaveRange','edit',[0 1],...
        'OctaveStep','edit',0.25,...
        'Type','popupmenu','Single|Multi-L|Multi-H|Multiple|Multi-Step|Shepard'});  %
    o.Frequency = [500 800];
    o.NoteDur = 0.075;
    o.NoteGap = 0.025;
    o.OctaveRange=[0 1];      %contour move up/down tange in octave
    o.OctaveStep = 0.25;      %step in octave
    
    o.Type='Single';  %or 'multiple' sequency
    o = class(o,'ToneSequence',s);
    o = ObjUpdate (o);
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