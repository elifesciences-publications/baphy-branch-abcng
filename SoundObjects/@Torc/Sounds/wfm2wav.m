% wfm to wav converter:

d=dir('TORC_896*u501.wfm');
for cnt1 = 1:length(d)
  fprintf('converting %s to wav.\n',d(cnt1).name);
    f=fopen(d(cnt1).name,'rb','b');
    wav = fread(f,'float');
    fs = length(wav)/3;
    wavwrite(wav/max(abs(wav)+eps), fs, [d(cnt1).name(1:end-3) 'wav']);
end
