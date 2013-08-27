function outSize = size(v1,Dim)

outSize = size(v1.value);
if exist('Dim','var') outSize = outSize(Dim); end