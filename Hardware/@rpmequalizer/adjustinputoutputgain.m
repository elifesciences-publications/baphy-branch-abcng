function adjustinputoutputgain(t,levels)

% load the trim (level of the input of the equalizer.
% t is the equalizer object
% levels: [input_level output_level] 
% 192 is zero db
% 182 is -5 dB
% 152 is -20 db

%find number of equalizer blocks
eqzin=readparams('input');
eqzout=readparams('output');
sendcommand(t,'set',eqzin(1),'trim','value',levels(1));
sendcommand(t,'set',eqzout(1),'trim','value',levels(2));