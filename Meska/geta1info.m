function [wfmnum, s_freqs, infodata, speechwfm] = geta1info (fname);
% function [wfmnum, s_freqs, infodata, speechwfm] = GETA1INFO (fname);
%
% INPUT
% fname   : string containing the experiment and A1 info filename,
%           for example '225/30a07.a1-.inf'.
%           It may also be the complete A1 path and filename,
%           such as '/export/software/daqsc/data/225/30a13.a1-.inf',
%           which would be returned by getfieldstr(paramdata,'inf_file'),
%           if paramdata were created by getspikes('225/30a13.a1-.fea').
%
% OUTPUT 
% wfmnum: number of waveforms
% s_freqs: a vector of the sampling frequencies
% speech : 0, or if one waveforms was digitzed speech, which one
% infodata: a (proprietary) data structure containing all 
%             info parameters & their values
%
% BYPRODUCTS & REQUIREMENTS
% Reads in a text file in the 'featxt' directory:
%
%  info file (e.g. 225_30a12.inf)
%
% In addition, the function file 'geta1val.m' is required.

%fname
%[featxtdir,sstr,ctag] = spikefile(fname);
%inffile = [featxtdir sstr '.inf'];
inffile=fname;

fidinf = fopen(inffile,'r');
if fidinf == -1, pause(1), fidinf = fopen(inffile);end %try again
if fidinf == -1 %file doesn't exist! return gracefully
		wfmnum = -1;
		s_freqs = 0;
		infodata = 0;
		speechwfm = 0;
		return
end
infodata = fscanf(fidinf,'%c');
fclose(fidinf);

wfmnum = max(geta1val(infodata, 'WAVEFORM'));
s_freqs  = geta1val(infodata, 'Sampling frequency');

lf = char(10);
speechwfm = ((wfmnum - length(geta1val(infodata, 'Time duration'))) == 1);
if speechwfm
 wfmchars = findstr(infodata,'WAVEFORM');
 linechars = [1,findstr(infodata,lf)+1];
 lines = [];
 for mm=wfmchars
  wfmline = find(linechars==mm);
  if ~isempty(wfmline)
   lines = [lines wfmline];
  end
 end
 wfmspacing = diff(lines);
 speechwfm = find(wfmspacing - max(wfmspacing));
 if isempty(speechwfm)
  speechwfm = wfmnum;
 end
end 

infodata = [infodata, sprintf('Waveform Total                  = %d',wfmnum), lf];

infodata = [infodata, sprintf('Speech Waveform                 = %d',speechwfm), lf];
