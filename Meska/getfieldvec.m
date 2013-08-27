function [result, number] = getfieldvec(fieldlist,fieldname);
% [result, number] = GETFIELDVEC(fieldlist,fieldname);

lf = char(10);
linebegin = findstr(fieldlist,[fieldname,':']);
number = length(linebegin);
if isempty(linebegin)
 result = [];
else
 linebegin = linebegin + 1;
 for m=1:number
  returnlist = findstr(lf,fieldlist(linebegin(m):length(fieldlist)));
  if ~isempty(returnlist)
   returnlist =  returnlist(1);
  else
   returnlist =  length(fieldlist);
  end
  linestr = fieldlist(linebegin(m)+[0:returnlist-2]);
  colonind=findstr(':',linestr);
  resulthold{m}=eval(['[',linestr(colonind+1:returnlist-1),']']);
 end
 if (number==1)
  result = resulthold{1};
 else
  result = resulthold;
 end
end
