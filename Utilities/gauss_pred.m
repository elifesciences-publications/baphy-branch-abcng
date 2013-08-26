function [pred,gstrf]=gauss_pred(beta,stim,f0)

x=1:size(stim,1);
fw=beta(1);
t0=beta(2);
tw=beta(3);
a=beta(4);

[xx,yy]=meshgrid(x,1:size(stim,2));
xx=xx';
yy=yy';

gstrf=exp(-(yy-t0).^2 ./ (2.*tw.^2) - (xx-f0).^2 ./ (2.*fw.^2)).*a;

pred=strf_torc_pred(gstrf,stim);
pred=pred(:);