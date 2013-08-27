function o = AltToneSeq(varargin)
% ToneSeqTone produces random sequences of 
%
% The parameters are listed in the code.
%
% benglitz 2011

% Technical Note:


switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'FrequencyTone','edit','1000',... %
      'FrequencySeq','edit','1500',...
      'AfterTonePause','edit','0.5',...
      'AfterSeqPause','edit','0.5',... % Results in the number of indices
      'WithinSeqPause','edit','0.2',...
      'ToneDur','edit','0.2',...
      'SeqToneDur','edit','0.2',...
      'NTonesSeq','edit','5',...
      'Amplitudes','edit','70',...
      };
    s = SoundObject ('AltToneSeq', 40000, 0,0.4, 0.4, {''}, 1, Fields);
    for i=1:length(Fields)/3 o.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    o.Fields = Fields;
    o.FieldNames = Fields(1:3:end-2); 
    o.FieldTypes = Fields(2:3:end-1);
    o.MaxIndex = 0; o.Names = {}; o.Par = [];
    o.RunClass = 'ATS'; o.Duration = NaN;
    o.LastPitchSequence = [];
    o.LastSeeds = [];
    o = class(o,'AltToneSeq',s);
    o = ObjUpdate(o);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end