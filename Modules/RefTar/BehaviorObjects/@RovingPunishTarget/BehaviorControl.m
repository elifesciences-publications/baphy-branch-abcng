function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex)
% june 2009, adding a new training paradigme to the behavior:
%   shock period can be extended. 
%   definition of miss and hit??
%   
% June 10 2008:
% if its in passive mode, do not shock the poor animal, do not dispense
% water, and do not flash any light!!

% % log the down times:
% if exist('downtime.mat','file')
%     object_spec = what(class(o));
%     load ([object_spec.path filesep 'downtime.mat']);
%     t2 = clock;
%     if ~exist('t1','var'), t1 = clock;end
%     dwt(end+1) = etime(t2,t1);
%     save ([object_spec.path filesep 'downtime.mat'], 'dwt');
% else
%     dwt = [];
%     object_spec = what(class(o));
%     save ([object_spec.path filesep 'downtime.mat'], 'dwt');
% end
global LastTrialWasSham;

% The maximum shock duration is 0.3:
ShockDuration = min(0.2, get(o,'ShockDuration'));
exptparams.ThereWasShock = 0;
ExtendedShock = get(o,'ExtendedShock');
% first, find the shock window, which is the time duration that animal gets
% shocked if lick:
StimulationFlag=0;
TarPostLickWin = [];
RefPostLickWin = [];
RefSound = [];
TarSound = [];
LickEvents=[];
StopWaterIfNoLick = get(o,'StopWaterIfNoLick');
WaterDuration = get(o,'PumpDuration');
% stimulation parameters
TarStimulation = get(o,'TarStimulation');
TarStimulationDur = get(o,'TarStimulationDur');
TarStimulationOnset = get(o,'TarStimulationOnset');
%
if StopWaterIfNoLick
    if ~isfield(exptparams,'Water'), exptparams.Water = 0;end
    % we are going to control the water based on the response of the
    % ferret. At the begining, turn the pump on:
    ev = IOControlPump(HW,'Start',WaterDuration);
    LickEvents = AddEvent(LickEvents, ev, TrialIndex);
    exptparams.Water = exptparams.Water+WaterDuration;
end
NumOfEvPerStim = get(exptparams.TrialObject,'NumOfEvPerStim');
% the following two have been added to work in more general situations,
% NumOfEvPerStim is not needed anymore but we keep it for backward
% compatibility
if isfield(get(exptparams.TrialObject),'NumOfEvPerRef'),
    NumOfEvPerRef = get(exptparams.TrialObject,'NumOfEvPerRef');
    NumOfEvPerTar = get(exptparams.TrialObject,'NumOfEvPerTar');
else
    NumOfEvPerRef = NumOfEvPerStim;
    NumOfEvPerTar = NumOfEvPerStim;
end
cnt1 = 1;
while cnt1<length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmpi(StimRefOrTar, 'Reference')
            cnt1 = cnt1 + NumOfEvPerRef-3;
            RefPostLickWin = sort([RefPostLickWin StimEvents(cnt1).StopTime + get(o,'ResponseTime') ...
                StimEvents(cnt1).StopTime + get(o,'ResponseTime') + get(o,'PostLickWindow')]);
            % also save the start time of the reference:
            RefSound(end+1).Start = StimEvents(cnt1).StartTime;
            RefSound(end).Dur = StimEvents(cnt1).StopTime - StimEvents(cnt1).StartTime;
        else
            cnt1 = cnt1 + NumOfEvPerTar-3;
            TarPostLickWin = sort([TarPostLickWin StimEvents(cnt1).StopTime + get(o,'ResponseTime') ...
                StimEvents(cnt1).StopTime + get(o,'ResponseTime') + get(o,'PostLickWindow')]);
            % also save the start time of the reference:
            TarSound(end+1).Start = StimEvents(cnt1).StartTime;
            TarSound(end).Dur = StimEvents(cnt1).StopTime - StimEvents(cnt1).StartTime;
        end
    end
    cnt1 = cnt1+1;
end
if isempty(TarPostLickWin)
    % which means its a sham trial, no punishment
    TarPostLickWin = [0 0];
elseif ExtendedShock
% in the extended shock, shock till the end of the trial:
    TarPostLickWin(end) = exptparams.LogDuration;
end
PreStimSilence = RefSound(1).Start;
if length(TarSound)>1
    TarSound(1).Dur = TarSound(end).Start+TarSound(end).Dur-TarSound(1).Start;
    TarSound(2:end)=[];
end
% if ~isempty(TarSound) && isfield(exptparams.Reference
% Now monitor the lick
lightFlag=0;
CurrentTime = IOGetTimeStamp(HW);
LastPunishTime = clock - 1;
LastWaterTime = clock - 1;
DidSheLick = 1;
flag1 = 0;
% we monitor the lick until the end plus response time and postargetlick
while CurrentTime < exptparams.LogDuration
    Lick = IOLickRead (HW);
    if (Lick) && (ShockDuration) && (etime(clock,LastPunishTime) > (ShockDuration+0.05)) ...
            && isempty(strfind(globalparams.Physiology,'Passive')) % dont send shock command until the last one is done
        if ((CurrentTime > TarPostLickWin(1)) && (CurrentTime < TarPostLickWin(2))) ... % if in target
                || ( ((ExtendedShock) && (CurrentTime < 0.2)) && ~LastTrialWasSham) % or the first 0.2 seconds
            % punish her!
            disp('***SHOCK***')
            ev = IOControlShock (HW, ShockDuration);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            LastPunishTime = clock;
            exptparams.ThereWasShock = 1;
        end
    end
    % turn off the water 0.5 sec before the trial ends, if extended shock, and not Sham trial:
    if ExtendedShock && (CurrentTime>(exptparams.LogDuration-.5)) && (sum(TarPostLickWin>0))
        ev = IOControlPump(HW,'Stop');
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
    end
    % now, if she licks in the second Reference, turn on the water:
    if ExtendedShock && (CurrentTime<RefPostLickWin(min(4,length(RefPostLickWin)))) && (CurrentTime>PreStimSilence) && Lick
        ev = IOControlPump(HW,'Start');
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
    end
    % in the first transition to the PostLick, set the flag to one:
    if mod(length(find(RefPostLickWin<CurrentTime)),2) && (StopWaterIfNoLick) && (flag1 ==0)
        flag1 = 1;
        DidSheLick = 0;
    end
    % now, if she licks in Post window set the flag to one
    if (Lick) && mod(length(find(RefPostLickWin<CurrentTime)),2) && (StopWaterIfNoLick)
        DidSheLick = 1;
    end
    % at anytime, if we are not in post window, set the flag1 to zero, also if she didnot lick stop
    % the water:
    if ~mod(length(find(RefPostLickWin<CurrentTime)),2) && (StopWaterIfNoLick) && (flag1==1) ...
            && isempty(strfind(globalparams.Physiology,'Passive'))
        flag1 = 0;
        if DidSheLick
            ev = IOControlPump(HW,'Start',WaterDuration);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            exptparams.Water = exptparams.Water+WaterDuration;
            %             ev = IOControlPump (HW,'Stop',0);
            %             LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
    end
    % for the light control, if its yes turn in on on target. if its
    % RefOnTarFlash turn it on for reference but flash for the target.
    switch get(o,'LightOnTarget')
        case 'Yes'
          if isfield(TarSound,'Start')
            if (CurrentTime > TarSound.Start) && (CurrentTime < TarSound.Start+TarSound.Dur) && ...
                    (lightFlag==0) && (isempty(strfind(globalparams.Physiology,'Passive')) || get(o,'LightInPassive'))
                [ll,ev] = IOLightSwitch (HW, get(get(exptparams.TrialObject,'TargetHandle'),'Duration'), get(o,'PostLickWindow'));
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
                lightFlag=1;
            end
          end
        case 'RefOnTarFlash'
            % if we are in reference time
            % if multiple light source is on, have the reference light on
            % the LED line, otherwise on the Light:
            if ~isempty(RefSound) && (CurrentTime > RefSound(1).Start) && ...
                    (isempty(strfind(globalparams.Physiology,'Passive'))|| get(o,'LightInPassive'))
                    [ll,ev] = IOLightSwitch (HW, 1, RefSound(1).Dur,'start');
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
                RefSound(1)=[];
            end
            % if we are in target time
            if ~isempty(TarSound) && (CurrentTime > TarSound(1).Start) && ...
                    (isempty(strfind(globalparams.Physiology,'Passive')) || get(o,'LightInPassive'))
%                 [ll,ev] = IOLightSwitch (HW, 1, TarSound(1).Dur,'start',...
%                     get(o,'LightFlashFreq'),get(o,'LightFlashGap'));
                % temporarily, disable the gap parameter and use 50% duty
                % cycle:
                Gap = (0.5/ifstr2num(get(o,'LightFlashFreq')));
                [ll,ev] = IOLightSwitch (HW, 1, TarSound(1).Dur,'start',...
                    ifstr2num(get(o,'LightFlashFreq')),Gap);
                
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
                TarSound(1)=[];
            end
        otherwise
    end
    % if we have TargetStimulation, send it too:
    if TarStimulation && ~isempty(TarSound) && (StimulationFlag==0) && ...
                (CurrentTime>=(TarSound(1).Start+TarStimulationOnset))
            % send the stimulation
            ev = IOControlStimulation (HW,TarStimulationDur,'Start');
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            StimulationFlag=1;        
    end
    % debugging FRB1
    %OldTime = CurrentTime; % %
    CurrentTime = IOGetTimeStamp(HW);
    %SA = get(HW.AI,'SamplesAcquired');
    %fprintf(['Time : ',num2str(CurrentTime),' - SA : ',num2str(SA),'\n']);
    %if OldTime == CurrentTime 
      %  warning('time is frozen!');
     %   disp(['oldtime: ' num2str(OldTime) ' curTime: ' num2str(CurrentTime) ' exptDur: ' num2str(exptparams.LogDuration)]);
    %end
end
% if exist('downtime.mat','file')
%     object_spec = what(class(o));
%     load ([object_spec.path filesep 'downtime.mat']);
%     t1 = clock;
%     save ([object_spec.path filesep 'downtime.mat'], 't1','dwt');
% else
%     object_spec = what(class(o));
%     t1 = clock;
%     save ([object_spec.path filesep 'downtime.mat'], 't1','dwt');
% end
if ExtendedShock && (globalparams.HWSetup==2) && isempty(strfind(globalparams.Physiology,'Passive'))
    if sum(TarPostLickWin>0)
        % only in the Free running 2, at the begining of the down time, turn on
        % the shock.
        IOControlShock(HW,4); % turn it on for 8 seconds. Longer should not be necessary.
        LastTrialWasSham=0;
    else
        % we just finished a sham trial, communicate to CanStart:
        LastTrialWasSham=1;
    end
end