function [result, number] = geta1dval(a1infolist,fieldname);
% [result, number] = GETA1VAL(a1infolist,fieldname);

lf = char(10);
linebegin = findstr(a1infolist,fieldname);
number = length(linebegin);
if isempty(linebegin)
 result = [];
else
 resulthold = zeros(number,1);
 for m=1:number
  returnlist = findstr(lf,a1infolist(linebegin(m):length(a1infolist)));
  if ~isempty(returnlist)
   returnlist =  returnlist(1);
  else
   returnlist =  length(returnlist);
  end
  linestr = a1infolist(linebegin(m)+[0:returnlist-2]);
  if ~strcmp(fieldname,'WAVEFORM')
   equalind=findstr('=',linestr);
  else
   equalind=findstr(' ',linestr);
  end
  if findstr('isoc',linestr(equalind+1:returnlist-1))
      resulthold(m) = 'i';
  elseif findstr('gallop', linestr(equalind+1:returnlist-1))
      resulthold(m) = 'g';
  else
      resulthold(m)=sscanf(linestr(equalind+1:returnlist-1),'%g');
  end
 end
 if (number==1)
  result = resulthold(1);
 else
  result = resulthold;
 end
end

if number > 1
 wfmnum = geta1val(a1infolist,'Waveform Total');
 speechnum = geta1val(a1infolist,'Speech Waveform');
 if (speechnum > 0) & (wfmnum == number +1)
  resultold = result;
  result = -ones(wfmnum, 1);
  result(1:speechnum-1) = resultold(1:speechnum-1);
  %result(speechnum) = -1;
  result(speechnum+1:number+1) = resultold(speechnum:number);
  number = wfmnum;
 end
end
