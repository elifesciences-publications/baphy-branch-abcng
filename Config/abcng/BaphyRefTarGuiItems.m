function varargout = BaphyRefTarGuiItems (field);
% Baphy Reference-Target Gui items are defined here.
%
% To add a new item, just add the new item to
% the corresponding list below.
% 

% Nima, November 2005
switch field
    case 'ReferenceList'                % reference list
        varargout{1} = {'FrequencyTuning','LevelTuning','Phoneme','Silence','Speech','Torc','Tone'};
    case 'TargetList'                   % Target list
        varargout{1} = {'None','Torc','Tone','Phoneme'};
    case 'GlobalparamsPosition'         % position of global parameters
        varargout{1} = [160 745];
    case 'ModuleparamsPosition'         % position of module properties
        varargout{1} = [400 640];
    case 'ReferencePosition'            % position of reference properties
        varargout{1} = [130 385];
    case 'TargetPosition'               % position of target properties
        varargout{1} = [390 385];
    case 'StatusPosition'               % position of status information
        varargout{1} = [680 670];
    case 'BehaviorControlScripts'                  % List of existing lick scripts
        varargout{1} = {'PunishTarget','PunishReference'};
end