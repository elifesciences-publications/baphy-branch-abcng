% function fftBPFilter(data,freq,octwidth,SR);
% expects data to have an even number of samples!
function data=fftBPFilter(data,freq,width,SR);

lf=2.^(log2(freq)-octwidth./2);
hf=2.^(log2(freq)+octwidth./2);
fd=fft(data);
ff=linspace(0,SR./2,(length(data))./2+1)';
ff=[ff ; flipud(ff(2:(end-1)))];
fd(find(ff<lf | ff>hf))=0;
data=real(ifft(fd));

