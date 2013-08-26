% function fftBPFilter(data,freq,octwidth,SR);
% expects data to have an even number of samples!
function data=fftBPFilter(data,freq,octwidth,SR);

if length(freq)==1,
  lf=2.^(log2(freq)-octwidth./2);
  hf=2.^(log2(freq)+octwidth./2);
else
  lf=freq(1);
  hf=freq(2);
end
fd=fft(data);
ff=linspace(0,SR./2,(length(data))./2+1)';
ff=[ff ; flipud(ff(2:(end-1)))];
fd(ff<lf | ff>hf)=0;
data=real(ifft(fd));

