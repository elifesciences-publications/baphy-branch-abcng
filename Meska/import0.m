% import0.m Import pre-sorted spikes
%
% comments added SVD 2005-10-16
%


if ~isempty(findstr('GLNX',computer)),
   files=uipickfiles('num',1,'Prompt','Import file...','FilterSpec',...
                     [path direc filesep 'sorted' filesep '*.mat']);
   [a,b]=basename(files{1});
else
   [a,b] = uigetfile([path direc filesep 'sorted' filesep '*.mat'],...
                     'Import File...');
end

ind =findstr(a,'.spk.mat');
af=a(1:ind-1);
if ~isempty(findstr(fname,af)),
   % import file matches first file
   stsave=st;
   clear st spiketemp 
   [Ws, Wt, Ss, St, st, spiketemp, spktemp, xaxis_imported]=...
       importfile(a,b,ts,spkraw,classtot,str2num(chanNum), REGORDER1, extras);
   spk(:,1)=spktemp;
elseif ~isempty(findstr(f2name,af)),
   
   % import file matches second file
   clear st2 spiketemp2 
   [Ws2, Wt2, Ss2, St2, st2, spiketemp2,spktemp, xaxis_imported]=...
       importfile(a,b,ts,spkraw2, classtot,str2num(chanNum),REGORDER2, extras2);
   spk(:,2)=spktemp;
end

% set x-axis to whatever was saved in spike file
xaxis=xaxis_imported;
set(e5,'string',sprintf('[%d, %d]',xaxis));

% refresh display
meska
classrefresh
