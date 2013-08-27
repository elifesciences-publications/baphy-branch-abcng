function [result, number] = geta1dstring(a1infolist,fieldname);
% [result, number] = GETA1STRING(a1infolist,fieldname);

lf = char(10);
linebegin = findstr(a1infolist,fieldname);
number = length(linebegin);
if isempty(linebegin)
 result = [];
else
 for m=1:number
  returnlist = findstr(lf,a1infolist(linebegin(m):length(a1infolist)));
  if ~isempty(returnlist)
   returnlist =  returnlist(1);
  else
   returnlist =  length(fieldlist);
  end
  linestr = a1infolist(linebegin(m)+[0:returnlist-2]);
  equalind=findstr('=',linestr);
  resulthold{m}=sscanf(linestr(equalind+1:returnlist-1),'%s');
 end
 if (number==1)
  result = resulthold{1};
 else
  result = resulthold;
 end
end

if number > 1
 wfmnum = geta1val(a1infolist,'Waveform Total');
 speechnum = geta1val(a1infolist,'Speech Waveform');
 if (speechnum > 0) & (wfmnum == number +1)
  resultold = result;
  result = cell(wfmnum, 1);
  result(1:speechnum-1) = resultold(1:speechnum-1);
  %result(speechnum) = '';
  result(speechnum+1:number+1) = resultold(speechnum:number);
  number = wfmnum;
 end
end
