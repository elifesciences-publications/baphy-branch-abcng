function [x,kcount]=idstrip(xstring,num)
%IDSTRIP Converts a string of numbers, separated by spaces, to numbers.
%   XSTRING:a string of numbers,
%   X:   contains the numbers
%   KCOUNT: The number of numbers in XSTRING
%   NUM: If num=='on', the X will contain numbers, otherwise it is
%        a string matrix

%   L. Ljung 4-4-94
%   Copyright 1986-2000 The MathWorks, Inc.
%   $Revision: 1.1.1.1 $  $Date: 2005/03/17 00:01:24 $

if nargin<2,num='on';end
   sl1=xstring;
   nrblank=[1,find(sl1==' '),length(sl1)+1];
   kcount=1;nn=[];
   for k=1:length(nrblank)-1
       ntemp=deblank(sl1(nrblank(k):nrblank(k+1)-1));
       if ~isempty(ntemp),
           if strcmp(num,'on')
               eval('nn(kcount)=str2num(ntemp);','')
           else
               ntemp=ntemp(find(ntemp~=' '));
               nn=str2mat(nn,ntemp);
           end
           kcount=kcount+1;
       end
   end
  x=nn;
if ~strcmp(num,'on')
  [nr,nc]=size(x);x=x(2:nr,:);
end