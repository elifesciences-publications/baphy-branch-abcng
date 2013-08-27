function zeroequalizer(t,dobypass);

% just for backward compatibility. dobypass=1 (default) - to remove the
% equalization block

zerolevel=0;
% get the levels for each equalizer blocks
sendcommand(t,'restore','equalizer');
% check if the blocks need to be bypassed
if nargin<2
    dobypass=1;
end

if dobypass
    eqblks=readparams('equalizer');
    for i=1:length(eqblks)
        sendcommand(t,'set',eqblks(i),'bypass',1);
    end
end

