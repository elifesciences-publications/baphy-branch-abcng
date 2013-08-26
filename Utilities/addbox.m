function h=addbox(c,x1,y1,fc);
%fc   filled eith color fc
%add a box
if ~ishold
   hold on;
end
x=get(gca,'xlim');
y=get(gca,'ylim');
if nargin>1
   if sum(abs(x1))~=0
      x=x1;
   end
   if nargin==3
      if isstr(y1)
         fc=y1;
      elseif sum(abs(y1))~=0
         y=y1;
      end
   elseif nargin==4
       y=y1;
   end   
end
if nargin==4 | (nargin==3 & isstr(y1))
   fill([x(1) x(1) x(2) x(2)],[y(1) y(2) y(2) y(1)],fc);
else
	h=line([x x(2) x(1) x(1)],[y(1) y y(2) y(1)]);
	set(h,'color',c,'tag','bx');
end
set(gca,'ticklength',[0.0025,0.1]);