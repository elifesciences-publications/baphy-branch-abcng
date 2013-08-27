function [result, number] = geta1dvec(a1infolist,fieldname);
% [result, number] = GETA1VEC(a1infolist,fieldname);

linebegin = findstr(a1infolist,fieldname);
number = length(linebegin);
if isempty(linebegin)
 result = [];
else
 for m=1:number
  rparenlist = findstr(')',a1infolist(linebegin(m):length(a1infolist)));
  if ~isempty(rparenlist)
   rparenlist =  rparenlist(1);
  else
   rparenlist =  length(fieldlist);
  end
  linestr = a1infolist(linebegin(m)+[0:rparenlist-2]);
  lparenind=findstr('(',linestr);
  resulthold{m}=eval(['[',linestr(lparenind+1:rparenlist-1),']']);
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
  % result(speechnum) = [];
  result(speechnum+1:number+1) = resultold(speechnum:number);
  number = wfmnum;
 end
end
