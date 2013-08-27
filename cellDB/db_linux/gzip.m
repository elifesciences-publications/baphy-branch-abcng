% function gzip(filename)
%
% wrapper: call unix gzip on filename
%
% created SVD 2009-01-19
%
function gzip(filename)

unix(['gzip ',filename]);
