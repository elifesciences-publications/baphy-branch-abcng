function o = SDWMPunishTarget (varargin)
%
% General behavior control script for Conditioned Avoidance tasks
% (SDWMPunishTarget model). Note that the timing parameters should be
% consistent for ALL versions of the conditioned avoidance tasks used in
% the lab, so that ferrets can easily go from one task to another without
% having to relearn timing contingencies.
% ===========================================
% Parameters: ResponseTime:
%   Specifies the time duration after the target stimulus ends that ferret
%   can continue licking without getting shocked.
% ===========================================
% PreTargetLickWindow:
%   Specifies the duration of the time window before the beginning of the
%   target stimulus that is used for calculation of performance.
% ===========================================
% PosTargetLickWindow:
%   Should be equal to the duration of the pretargetlickwindow. Specifies
%   the duration of the time window following the target AND the subsequent
%   response time, that is used for calculation of performance. This is
%   used to determine whether the animal has a hit (stops licking during
%   the post-target-lick-window), or a miss (continues licking during the
%   post-target-lick-window).
% ===========================================
% ShockDuration:
%   specifies the constant duration of the shock.
% ===========================================
% IncludeLickDuringTarget:
%   Specifies whether licks occurring during the target stimulus are also
%   included in PreTargetLickWindow. If so, then the PreTargetLickWindow IS
%   longer than the PosTargetLickWindow (otherwise they are the same
%   duration).
%
%
% Logic:
%   During the presentation of reference (or safe) stimuli, the ferret can
%   lick as much as she likes. However, when the danger or target stimulus
%   appears, the ferret must stop licking. Specifically, when the target
%   stimulus ends, animal has a reaction or decision period (ResponseTime)
%   to stop licking, otherwise she gets shocked.

%
% varargin should include:
%   globalparams, HW, exptparams, StimEvents and TrialIndex. All the
%   parameters needed for the control are passed in the fields of
%   exptparams automatically by baphy.

% Nima, November 2005. The experiment documentation is prepared by Jonathan
% Fritz
switch nargin
    case 0
        % if no input arguments, create a default object
        o.ResponseTime      = 0.4;
        o.PreLickWindow     = 0.4;
        o.PostLickWindow    = 0.4;
        o.ShockDuration     = 0.2;
        o.ExtendedShock     = 0;
        o.PumpDuration      = 0.5;
        o.LightFlashFreq    = 5;    % in hertz is the frequency of flashing the light
        o.LightFlashGap     = 0;
        o.LightOnTrial     = 'Yes';
        o.MultipleLights    = 'No';
        o.LightInPassive    = 0;
        o.FirstDisplay = 'Comments';
        o.TarStimulation = 0;
        o.TarStimulationOnset = 0;
        o.TarStimulationDur = .5;
        o.StopWaterIfNoLick = 0;
        o.IncludeLickDuring = 0;
        o.UserDefinableFields = {'ResponseTime','edit',0.4, 'PreLickWindow', ...
            'edit',0.4, 'PostLickWindow','edit',0.4, 'ShockDuration','edit',0.2, ...
            'ExtendedShock','checkbox',0,'PumpDuration','edit',.5,'LightFlashFreq','edit',5, ...
            'LightFlashGap','edit',0,'LightOnTrial','popupmenu','Yes|No',...
            'MultipleLights','popupmenu','No|Yes','LightInPassive','checkbox',0,...
            'FirstDisplay','popupmenu','Comments|Cumulative', 'TarStimulationOnset','edit','0',...
            'TarStimulationDur','edit',0.5,'TarStimulation','checkbox',0,'StopWaterIfNoLick','checkbox',0,...
            'IncludeLickDuring','checkbox',0};
        o = class(o,'SDWMPunishTarget');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'SDWMPunishTarget')
            o = varargin{1};
        else
            error('Wrong argument type');
        end
    otherwise
        error('Wrong number of input arguments');
end