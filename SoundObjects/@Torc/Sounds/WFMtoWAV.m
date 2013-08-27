% wfm to wav converter:

d=dir('*w501.wfm');
for cnt1 = 1:length(d)
    f=fopen(d(cnt1).name,'rb','b');
    wav = fread(f,'float');
    fs = length(wav)/3;
    wavwrite(.999*wav/max(abs(wav)), fs, [d(cnt1).name(1:end-3) 'wav']);
end

% d=dir('TORC_424*.*');
% for cnt1=1:length(d)
%     oldname=d(cnt1).name;
%     newname=[oldname(1:8) '_' oldname(13:end)];
%     cmd=['rename ' oldname ' ' newname];
%     system(cmd);
% end