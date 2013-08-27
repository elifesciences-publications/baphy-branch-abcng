function timestamp=iosoundstart(HW,stim);
% function starttime=iosoundstart(HW,stim)
%
% HW - handle of HW card. if [], run in TESTMODE
% fs- sampling rate, only required for TESTMODE
%
% note: this command isDDO only useful when AI is not hardware triggered
%
% returns timestamp of event (from HW clock??)

% created SVD 2005-08-31
% Revision November 09, 2005, Nima: Add alphaomega rig (case 3)

try,
    switch HW.params.HWSetup
        case 0 ,  % ie, TEST MODE
            % ie, test mode
            sound(stim,HW.params.fsAO);
            timestamp=clock;
        %
        case 1      % Sound Proof 1, Single electrode rig
        %
        case 2      % Sound Proof 2, Training rig
            % real mode
            putdata(HW.AO,[stim(:) stim(:)]);      % Put signal into sound engine
            start([HW.AO]);                        % Start interfaces
            %putvalue(HW.DIO.Line(5),0);           % Trigger On
            e=get(HW.AO,'EventLog');
            timestamp=e(end).Data.AbsTime;
        %
        case 3      % Sound Proof 3, AlphaOmega rig
            % 
            % The following line was added to solve the missing stims bug.
            % The buffering is handled manually:
            set(HW.AO,'BufferingConfig',[ceil(length(TrialSound)/10) 20]);
            
            putdata (HW.AO, stim);  
            % wait until input and output become available
            while isrunning(HW.AO) | isrunning(HW.AI);end
            % start the sound and data acqusition:
            start([HW.AO HW.AI]);putdata(HW.DIO.Line([5:6]),[0 0]);
            e=get(HW.AO,'EventLog');
            timestamp=e(end).Data.AbsTime;
    end

catch,
    ShutdownHW;
    error(['error: ',lasterr]);
end
