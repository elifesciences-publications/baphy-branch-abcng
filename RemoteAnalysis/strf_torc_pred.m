% function pred=strf_torc_pred(strf,StStims);
function pred=strf_torc_pred(strf,StStims);

[stimX,stimT,numstims] = size(StStims);
pred=zeros(stimT,numstims);

for rec = 1:numstims,
   for X=1:stimX,
      
      % doesn't work... offset?
      %tr=cconv2(StStims(X,:,rec),strf(X,:));
      
      % works!
      tr = real(ifft(fft(StStims(X,:,rec)).*fft(strf(X,:))));
      
      pred(:,rec)=pred(:,rec)+tr';
   end
end
