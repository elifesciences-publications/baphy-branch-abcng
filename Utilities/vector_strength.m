% function [vs,vserr]=vector_strength(r,F,fs);
%
% measure vector strength of response to modulated stimulus 
%
% r = matrix time X rep
% F = frequenc(ies) of modulation to test (Hz)
% fs= sampling rate of r
% 
% formula used: vs = (1/n)*sqrt(sum(cos(2(pi)t/T))^2+sum(sin(2(pi)t/T))^2)
% t=time b/w first noise pulse and ith spike (total n spikes)
% T=period b/w 2 consecutive noise pulses
%
% created SVD 2009-07-08
%
function [vs,vserr]=vector_strength(r,F,fs);

vs=zeros(length(F),1);
vserr=zeros(length(F),1);

jncount=min(size(r,2),10);
jackstep=size(r,2)./jncount;

for ff=1:length(F),
   if F(ff)>0,
      vsj=zeros(jncount,1);
      for ii=1:jncount,
         
         jset=[1:round((ii-1).*jackstep) round(ii.*jackstep+1):size(r,2)];
         
         Tlen=round(fs./F(ff));
         Tcount=floor(size(r,1)./Tlen)-1;
      
         p=r((Tlen+1):((Tcount+1).*Tlen),jset);
         p=reshape(p,[Tlen,Tcount*size(p,2)]);
         p=squeeze(nanmean(p,2));
         
         theta=((1:Tlen)'-1)./Tlen.*2.*pi;
         
         vsj(ii)=abs(sum(p.*exp(i.*theta))./sum(p));
      end
      
      vs(ff)=mean(vsj);
      vserr(ff)=std(vsj).*sqrt(jncount-1);
   end
end
