%MakeGolayStim.m
%created 09/12/12 sjs


%make the golay stimulus
cd /Aim7_FerretIC/mfiles_aim7
L=8192;
[A,B] = generate_code(L);

spec_golay = ((fft(A).*conj(fft(A))+fft(B).*conj(fft(A)))/2/L)';
%compute ifft to get impulse response
spec_golay = ifft(spec_golay);

impulse=(xcorr(A,A)+xcorr(B,B))/2/L;

StimA=[];
StimB=[];

%Make 20 reps
for j=1:20
    StimA(j,:)=A;
    StimB(j,:)=B;
end

StimA=reshape(StimA',8192*20,1);
StimB=reshape(StimB',8192*20,1);





%-------------------------------------------------------------------
%code for analyzing the spectra
%cd /Aim7_FerretIC/mfiles_aim7
L=8192;
[A,B] = generate_code(L);


respA=p19;
respB=p20;

mrespA=reshape(respA,8192,20);
mrespA=mean(mrespA(:,2:19),2)';
mrespB=reshape(respB,8192,20);
mrespB=mean(mrespB(:,2:19),2)';

%make frequency vector (in kHz, 100 kHz sampling rate)
freqs=[0:((8192/2))-1]*100000/8192/1000;    

%make hanning window
hwin(1:512,1)=hann(512);  
hwin(513:8192,1)=0;

spec_golay = ((fft(A).*conj(fft(mrespA))+fft(B).*conj(fft(mrespB)))/2/L)';
%compute ifft to get impulse response
impulse_golay = ifft(spec_golay);
mag_golay = impulse_golay.*hwin; %hanning window impulse
mag_golay = fft(mag_golay);
mag_golay = 20*log10(abs(mag_golay(1:4096)));

%plot
figure;
subplot(2,1,1),hold on,plot(impulse_golay,'k')
title('impulse response')
xlim([-100 8192])

subplot(2,1,2), hold on
semilogx(freqs,mag_golay,'k')
xlabel('frequency, kHz')
ylabel('Magnitude, dB re 1 volt')
xlim([0.1 50])
















