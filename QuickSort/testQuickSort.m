function testQuickSort

R = zeros(20000,10);
K = -sin(2*pi*1000*[0:25]/25000);

for i=1:10 for j=1:5 R(3000*j,i) = 1; end;end
for i=1:10 tmp = conv(R(:,i),K); R(:,i) = tmp(1:20000); end
quickSort(R(:)+0.001*rand(200000,1),...
  'TrialIndices',[1:20000:9*20000+1]',...
  'Electrode',1,'Sorter','englitz','Threshold',5)