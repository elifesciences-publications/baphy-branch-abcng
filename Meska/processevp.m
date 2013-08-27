% These are various attempts to whiten the evp spectrum

if 0,
disp('Processing evp')
wf1 = 0;
disp('Computing average spectrum')
for abc = 1:300,
temp = abs(fft(spkraw(1+(abc-1)*60000:abc*60000)));
wf1 = wf1 + temp;
end
wf1 = wf1/300;
end

if 0,
disp('Lowpassing average spectrum')
temp = conv2(hanning(500),1,wf1,'same')/sum(hanning(500));
h = hanning(200).^2;
%temp(1:100) = temp(1:100).*h(1:100);
%temp(end-99:end) = temp(end-99:end).*h(101:end);
temp(1:600) = temp(601);
temp(end-599:end) = temp(end-600);
wf2 = temp;
else
%wf2 = ones(size(wf1));
end

if 0,
disp('Modifying evp spectrum')
for abc = 1:300,
spkraw(1+(abc-1)*60000:abc*60000) = real(ifft(fft(spkraw(1+(abc-1)*60000:abc*60000))./wf1.*wf2));
end
end

if 1,
wf1 = [0;1-triang(59999)].^2;
nsegs = floor(length(spkraw)/60000);
for abc = 1:nsegs,
X = fft(spkraw(1+(abc-1)*60000:abc*60000));
X = mean(abs(X))*wf1.*exp(j*angle(X));
spkraw(1+(abc-1)*60000:abc*60000) = real(ifft(X));
end
end
