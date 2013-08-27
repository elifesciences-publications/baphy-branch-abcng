function out = relaxC(in,sig);
% function out = relaxC(in,sig);

X = [0:sig*2*3];

G = exp(-((sig*3-X).^2)/(2*sig^2));;

out = conv(in,G);
ttt = conv(ones(size(in)),G);
out  = out./ttt;
di = floor((length(out) - length(in)) / 2);
out = out(di+1:length(out)-di);
out = out(1:size(in,1),1:size(in,2));


