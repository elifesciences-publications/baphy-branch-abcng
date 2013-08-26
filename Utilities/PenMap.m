function PenMap(x1,y1,z1,x2,y2,z2)

if exist('M:\daq\Cabbage\PenMap\PenMap.m')
    PenMap = load('M:\daq\Cabbage\PenMap\PenMap.m')
    
else
    PenMap{1} = [x1;y1;z1];
    PenMap{2} = [x2;y2;z2];
end

PenMap{1} = [PenMap{1} x1;y1;z1];
PenMap{2} = [PenMap{2} x2;y2;z2];

Headpost = PenMap{2};
Well = PenMap{1};

figure(10000)
hold on
for i = size(Headpost,1)
    plot3(Headpost') ,'markershape','o','linewidth',2);
    plot3(Well(i,:),'markershape','o','linewidth',2);
    
end
