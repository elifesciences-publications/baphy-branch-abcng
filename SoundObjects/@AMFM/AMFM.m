function o = AMFM(varargin)
% AMFM is the constructor for the object AMFM which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Duration",
%       "Freq_Carrier"," Freq_AM_List", "Freq_FM_List",       
%       "Modulation_AM", "Modulation_FM", "Ramp_Duration"
%
% usage:
% To creates an AM-FM stimulus set with default values.
%   amfm = AMFM;     
%
% To create an AM-FM stimulus set with specified values:
%   amfm = AMFM (Loudness, PreStimSilence, PostStimSilence,
%       Duration, Freq_Carrier, Freq_AM_List, Freq_FM_List,       
%       Modulation_AM, Modulation_FM, Ramp_Duration);
%
% To get the waveform and events:
%   [w, events] = waveform(amfm, index);  
%
% methods: set, get, waveform, ObjUpdate


% Jonathan Simon, March 2006
% Based on code by Nima Mesgarani, Oct 2005

% Default Values
def_SamplingFrequency = 40000; % Hz
def_Duration = 2.25; % s
def_Freq_Carrier = 1000;  % Hz
def_Freq_AM_List = [3.5 7.5 15.5 31.5];  % Hz
def_Freq_FM_List = [3.5 7.5 15.5 31.5];  % Hz
def_Modulation_AM = 0.9; % fraction
def_Modulation_FM = 2; % octaves
def_Ramp_Duration = 0.01; % s

% need to update case 0 and case 5 for AMFM not tone.

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('AMFM', def_SamplingFrequency, 0, 0.4, 0.4, ...
        {''}, 1, {
        'Duration','edit',def_Duration,...        
        'Freq_Carrier','edit',def_Freq_Carrier,...        
        'Freq_AM_List','edit',def_Freq_AM_List,...        
        'Freq_FM_List','edit',def_Freq_FM_List,...        
        'Modulation_AM','edit',def_Modulation_AM,...        
        'Modulation_FM','edit',def_Modulation_FM,...        
        'Ramp_Duration','edit',def_Ramp_Duration});
    o.Duration = def_Duration;  %
    o.Freq_Carrier = def_Freq_Carrier;
    o.Freq_AM_List = def_Freq_AM_List;
    o.Freq_FM_List = def_Freq_FM_List;
    o.Modulation_AM = def_Modulation_AM;
    o.Modulation_FM =def_Modulation_FM;
    o.Ramp_Duration = def_Ramp_Duration;
    o.FullAMList=[];
    o.FullFMList=[];
    o = class(o,'AMFM',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
case 10
    s = SoundObject('AMFM', ...
        def_SamplingFrequency , ...         % SamplingFrequency
        varargin{1}, ...    % Loudness
        varargin{2}, ...    % PreStimSilence
        varargin{3},...     % PostStimSilence
        '',1, {
        'Duration','edit',def_Duration,...        
        'Freq_Carrier','edit',def_Freq_Carrier,...        
        'Freq_AM_List','edit',def_Freq_AM_List,...        
        'Freq_FM_List','edit',def_Freq_FM_List,...        
        'Modulation_AM','edit',def_Modulation_AM,...        
        'Modulation_FM','edit',def_Modulation_FM,...        
        'Ramp_Duration','edit',def_Ramp_Duration});
    o.Duration = varargin{4};
    o.Freq_Carrier = varargin{5};
    o.Freq_AM_List = varargin{6};
    o.Freq_FM_List = varargin{7};
    o.Modulation_AM = varargin{8};
    o.Modulation_FM = varargin{9};
    o.Ramp_Duration = varargin{10};
    o.FullAMList=[];
    o.FullFMList=[];
    o = class(o,'AMFM',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end
