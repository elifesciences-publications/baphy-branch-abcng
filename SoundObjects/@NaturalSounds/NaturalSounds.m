function O = NaturalSounds(varargin)

% Thomas Schatz 02/11/2012

switch nargin
  case 0  % if no input arguments, create a default object
    Fields = {...
      'StimulusType','popupmenu','PilotScrambling',...
      };
    [p, ~, ~] = fileparts(mfilename('fullpath'));
    
    O.Fields = Fields;
    O.FieldNames = Fields(1:3:end-2); 
    O.FieldTypes = Fields(2:3:end-1);
    O.FieldVals =  Fields(3:3:end-1);
%     O.MaxIndex =  numel(sounds);
    O.MaxIndex =  [];
    for i=1:length(Fields)/3 O.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    
    switch O.StimulusType
        case 'PilotScrambling'
            load([p filesep 'stim-orders-ferret.mat']);
            sounds = stim_order(:,1);
            S = SoundObject ('NaturalSounds', 100000, 0, 0.4, 0.4, sounds, numel(sounds), Fields);
    end
    O.Names = sounds;
    O.Duration = NaN;
    O.VarFieldNames = {};  O.VarFieldInds = []; O.Par = [];
    O.RunClass = 'NSD'; 
    O = class(O, 'NaturalSounds', S);
    O = ObjUpdate(O);
    
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   S = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end




