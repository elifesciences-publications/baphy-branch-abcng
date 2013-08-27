function o = readme (varargin)
% methods: set, get, waveform
% usage: 
% pingbo yin, July 2007
if ~isa(varargin{1},'MultiRangeTask')
    return;
end
stype=get(varargin{1},'Type');
if nargin==2
    stype=varargin{2};
end

disp('Simulus type of MultiRangTask');
switch lower(stype)
    
    case 'protone'
        disp('protone: in preparation - two tone combination as a probe for behavior testing');
    case 'stype'
        disp('Include: Tone, Click, Amtone, Gaptone, Harm, Protone');
    case 'harm'
        disp('Harm: harmonic tone complex (1-7 harminics)');
    case 'tone'
        disp('Ttone: the basic stimulus type');
    case 'click'
        disp('Click: use click string insteatd of sine wave');
    case 'amtone'
        disp('Amtone: ');
        disp('...field *LowFrequency* has two elements');
        disp('......First element indicate the carrier frequency, meant froaen noise if 0');
        disp('......2nd element indicate modulation depth (%)');
        disp('......AM frequency range 4-60 Hz which spaced equally');
    case {'amtone2','amtone2a'}
        disp('Amtone2 and Amtone2a set: ');
        disp('...field *LowFrequency* has two elements');
        disp('......First element indicate the carrier frequency, meant froaen noise if 0');
        disp('......2nd element indicate modulation depth (%)');
        disp('......AM frequency range 4-60 Hz which spaced equally');
        disp('...AMtone2 set combine two AM sets with PT and WN as carrior');
        disp('...AMtone2a set combine tone set and AM sets with WN carrior');
    case 'gaptone'
        disp('Gaptone: ');
        disp('...field *Duration* has two elements');
        disp('......First element indicate the total duration of the tone');
        disp('......2nd element indicate Gap duration inserted into tone (default=0.1 sec)');
        disp('......the silence Gap started from 0.1 sec from onset onset');
        disp('......the total duration of the tone would be the duratoion of (Gap+Tone)');
    otherwise
        disp('Wrong stumulus type!');
end