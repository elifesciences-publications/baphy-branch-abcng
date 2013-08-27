function t=mklookuptable(n,pav);
%create a lookup table so that the target appearence has equal chance.
%n      trial length
%pav    average chance level at each position
if nargin<2
    pav=0.5; %default 
end
t(n)=round((1-pav)/pav);
for i=n-1:-1:1
    tem=pav*sum(t(i+1:end))/(1-pav);
    t(i)=ceil(tem);
end
tem=[];
for i=1:n
    tem=[tem;ones(t(i),1)*i];
end
t=tem(randperm(length(tem)));

