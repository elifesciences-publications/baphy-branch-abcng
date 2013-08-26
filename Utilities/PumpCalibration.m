function PumpCalibration (globalparams,PumpName)

global BAPHYHOME;
globalparams.Physiology = 'No';
HW = InitializeHW(globalparams);
paramfname = [BAPHYHOME filesep 'Config' filesep 'HWSetupParams.mat'];
ButtonName=questdlg('For proper callibration, make sure that spout is positioned so that water flows somewhere that it can be measured.', ...
    'Callibrate pump', ...
    'Continue','Cancel','Continue');
if strcmpi(ButtonName,'Continue'),
    disp('Sending 3 pulses of 10 sec ...');
    HW=InitializeHW(globalparams);
    for ii=1:3,
        fprintf('%d',ii);
        IOControlPump(HW,'Start',10,PumpName);
        for jj=1:10,
            pause(1);
            fprintf('.');
        end
        pause(1);
        fprintf('\n');
    end
    %
    ShutdownHW(HW);
    tt=inputdlg('30 sec = How many ml of water?','Callibrate pump');
    if ~isempty(tt),
        if exist(paramfname,'file')
            load (paramfname);
        end
        if ~exist('MicVRef','var')
            MicVRef=0; 
        end
        if ~exist('EqualizerCurve','var')
            EqualizerCurve = zeros(1,30);
        end
        if ~exist('MicLast','var'), MicLast  = '---';end
        if ~exist('EqzLast','var'), EqzLast  = '---';end
        
        PumpMlPerSec.(PumpName) = round(str2num(tt{1})./30*1000)/1000;
        PumpLast = [date ' - ' globalparams.Tester];
        save (paramfname,'MicVRef','PumpMlPerSec','EqualizerCurve',...
            'MicLast','PumpLast','EqzLast');
    end
end