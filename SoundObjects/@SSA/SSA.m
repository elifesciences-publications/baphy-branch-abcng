function o = SSA(varargin)
% SSA: generate a long oddball tone sequence
% related function: set, get, waveform
%   
% Pingbo, 4-19-2013
switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('SSA', 40000, 0,0, 0, ...
        {''}, 1, {'Standard','edit',1000,'Deviant','edit',50,'Deviant_pct','edit',[0.95 0.5]...
        'NoteDur','edit',0.1,'NoteGap','edit',0.0,'NoteNumber','edit',150,...
        'Type','popupmenu','Tone|BPN'});  %
    o.Standard = 1500;     %standard stimulus
    o.Deviant = 50;    %deviant percentage of the standard or in HZ if greater than 100
    o.Deviant_pct=5;
    o.NoteDur = 0.05;
    o.NoteGap = 0.05;
    o.NoteNumber=400;      
    o.Type='Tone';  %or 'multiple' sequence
    o = class(o,'SSA',s);
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