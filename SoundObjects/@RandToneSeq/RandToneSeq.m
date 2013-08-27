function o = RandToneSeq(varargin)
% RandToneSeq: generate a long random tone sequence
% related function: set, get, waveform
%   
% Pingbo, January 2007
switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('RandToneSeq', 40000, 0,0, 0, ...
        {''}, 1, {'CenterFrequency','edit',1500,...
        'NoteDur','edit',0.1,'NoteGap','edit',0.0,'NoteNumber','edit',150,...
        'SemiToneRange','edit',[-12 12],...
        'SemiToneStep','edit',4,...
        'Type','popupmenu','FixedStep|MultiStep|Seq_Daniel|New_Daniel|AddStream|RShepard|AddStream2|oddbal12|3stream'});  %
    o.CenterFrequency = [1500];
    o.NoteDur = 0.1;
    o.NoteGap = 0.0;
    o.NoteNumber=150;
    o.SemitoneRange=[-12 12];      
    o.SemitoneStep =4;      
    o.Type='FixedStep';  %or 'multiple' sequence
    o = class(o,'RandToneSeq',s);
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