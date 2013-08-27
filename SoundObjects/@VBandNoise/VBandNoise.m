function o = VBandNoise(varargin)
% VBandNoise: generate noise set with varyied bandwidth
% related function: set, get, waveform
%   
% Pingbo, 4-20-2013
switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('VBandNoise', 40000, 0,0, 0, ...
        {''}, 1, {'CenterFrequency','edit',1500,'BandWidths','edit',[0 0.125 0.25 0.5 1 2],...
        'Probe','edit',[],'Duration','edit',0.1,'SemiToneRange','edit',[-12 12],'SemiToneStep','edit',4,...
        'ToneDensity','edit',100,'Type','popupmenu','SingleFreq|MultiFreq'});  %
    o.CenterFrequency = 1500;              %
    o.BandWidths = [0 2 4 8 12 24]; %in semitones
    o.Probe=[];
    o.Duration = 0.1;
    o.SemiToneRange=[-12 12]; %in semitones
    o.SemiToneStep=4; %in semitones
    o.ToneDensity=100;  %tone number per ocatve in compromise the noise, white noie=se if inf
    o.Type='SingleFreq';       %or 'MultiFreq' sequence
    o = class(o,'VBandNoise',s);
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