%
%function to create corr fn from matrix of corr coefficients

function cfn = corr_fn(C);

cfn=zeros(1,size(C,1));
for offset = 0:size(C,1)-1
    temp=[];
    for k=1:size(C,1)-offset
        temp = [temp C(k,k+offset)];
    end
    cfn(offset+1) = mean(temp);
end