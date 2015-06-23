function out = relaxC(in,sig);
% function out = relaxC(in,sig);

X = [0:sig*2*3];

G = exp(-((sig*3-X).^2)/(2*sig^2));;

out = conv(in,G);
ttt = conv(ones(size(in)),G);
out  = out./ttt;
di = floor((length(out) - length(in)) / 2);
out = out(di+1:length(out)-di);
%TODO here need to modify these because depending on sig, out can be either a row or a column
%fixed it rapidly to 'have something', but I'm not sure the result is the good one...
if isrow(out)
  if iscolumn(in)
    out = transpose(out)
  end
else
  if isrow(in)
    out = transpose(out)
  end
end
out = out(1:size(in,1),1:size(in,2));


