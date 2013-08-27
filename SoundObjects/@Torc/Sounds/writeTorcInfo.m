function a = writeTorcInfo(fname,rippleList,cond)
% This function writes a .txt file for Daqsc for torc described by rippleList and cond
% rippleList and cond are as in input for multimvripfft
% output a returns if write to the file was true
if nargin<1,
error('please mention torc text filename');
end;

% default rippleList and conditions
% rippleList = [Am, w, Om, Ph]; cond = (optional) [T0, f0, BW, SF,   CF, df, RO,
%  AF, Mo, wM];
rippleList0  = [1,  8, 1,  0];  
cond0 =           [1, 125, 5, 16000, 1, 1/20, 0, 1, 0.9, 120];

% arguments
if nargin < 2, rippleList = rippleList0; end;
if nargin < 3, cond = cond0; end;
if size(rippleList,2) < 4, rippleList(:,4) = rippleList0(4); end;
for k = 2:10, if length(cond) < k, cond(k) = cond0(k); end; end;

fid = fopen(fname,'w','b');
a = fprintf(fid,'%s\n','Base Amplitude                  = 50 dB');
a = fprintf(fid,'%s\n','Voltage at 50dB                 = 64.16 mV');
a = fprintf(fid,'%s%d%s\n','Sampling frequency              = ',cond(4),' Hz');
a = fprintf(fid,'%s%d%s\n','Ripple peak                     = ',cond(9)*100 ,' %');
a = fprintf(fid,'%s%d%s\n','Lower frequency component       = ',cond(2), ' Hz');
a = fprintf(fid,'%s%d%s\n','Upper frequency component       = ',cond(2)*2^cond(3), ' Hz');
if cond(5)
    a = fprintf(fid,'%s%d\n','Number of components            = ',cond(3)/cond(6));
else
    fr = cond(6)*(round(cond(2)/cond(6)):round(2.^cond(3)*cond(2)/cond(6))).';
    a = fprintf(fid,'%s%d\n','Number of components            = ',length(fr));
end;
a = fprintf(fid,'%s%d\n','Components harmonically spaced  = ',~cond(5));
if cond(5)
    a = fprintf(fid,'%s%d%s\n','Harmonic spacing                = ',0,' Hz');
else
    a = fprintf(fid,'%s%d%s\n','Harmonic spacing                = ',cond(6),' Hz');
end;
a = fprintf(fid,'%s%d%s\n','Spectral Power Decay            = ',cond(7),' dB/octave');
a = fprintf(fid,'%s%d\n','Components random phase         = ',1);
a = fprintf(fid,'%s%3.2f\n','Time duration                   = ',cond(1));
a = fprintf(fid,'%s\n',['Ripple amplitudes               = (',...
	sprintf('%3.2f  ',rippleList(:,1)),')']);
a = fprintf(fid,'%s\n',['Ripple frequencies              = (',...
	sprintf('%3.2f  ',rippleList(:,3)),') cyc/oct']);
a = fprintf(fid,'%s\n',['Ripple phase shifts             = (',...
	sprintf('%3.2f  ',rippleList(:,4)), ') deg']);
a = fprintf(fid,'%s\n',['Angular frequencies             = (',...
	sprintf('%3.2f  ',rippleList(:,2)),') Hz']);
fclose(fid);
 




