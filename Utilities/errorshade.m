function l = errorshade(x, y, e, lcolor, scolor)
%function l = errorshade(x, y, e, lcolor, scolor)
%
% Fri Oct 26 17:12:26 2001 mazer 
%
%

if ~exist('scolor','var'),
   scolor=[.9 .9 .9];
end
if ~exist('lcolor','var'),
   lcolor=[0 0 0];
end

holdstate = ishold;

p = y+e;
m = y-e;
px = [x x(end:-1:1)];
py = [p m(end:-1:1)];
pix = ~isnan(px) & ~isnan(py);
px = px(pix);
py = py(pix);
pa=patch(px, py, scolor);
set(pa, 'edgecolor', scolor);
hold on;
l = plot(x, y);
set(l, 'color', lcolor);


if ~holdstate
  hold off;
end


