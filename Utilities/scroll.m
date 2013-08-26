
function [ output_args ] = scroll(~,evnt )

set(gcf, 'WindowScrollWheelFcn', @scroll,'units','normalized')
y=get(gcf,'children');
delta=.05;
for i=1:length(y)
pos=get(y(i),'position');
pos(2)=pos(2)+evnt.VerticalScrollCount*delta;
set(y(i),'position',pos);

end

