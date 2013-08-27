function flag = IOIsPlaying (HW);
% function flag = IOIsPlaying (HW);
%
% This function return 1 if the sound is still playing and 0 if its not.
% 

% Nima, november 2005

switch HW.params.HWSetup
    case {0}              % Test mode
        % how do you know??
        flag = isplaying(HW.AO);
    otherwise
        flag = isrunning(HW.AO);
end

