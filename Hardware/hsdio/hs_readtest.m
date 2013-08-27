
disp('compiling');
mextest;
disp('reading data');
tic;
y=hsdio_stream(2000,10000);
toc;

% teststring=[0 0 0 0 0 1 0 1 0 0 0 0 0 1 0 1]';
% 
% teststring1=[0  0  0  0  0  0  0  0 ]';
% teststring2=[ 0  0  1  1  0  0  1  1]';
% m1=zeros(size(y));
% m2=zeros(size(y));
% for ii=1:(length(y)-length(teststring)),
%     if sum(teststring==y(ii+(1:length(teststring))))==length(teststring),
%         fprintf('match at ii=%d??\n',ii);
%     end
%     if sum(teststring1==y(ii+(1:length(teststring1))))==length(teststring1),
%         m1(ii)=1;
%     end
%     if sum(teststring2==y(ii+(1:length(teststring2))))==length(teststring2),
%         m2(ii)=1;
%     end
% end
% y=double(y);
% 
% figure(1);
% clf;
% subplot(2,1,1);
% plot([xcov(y,y,1000)]);
% a=axis;
% axis([a(1:2) 0 200]);
% subplot(2,1,2);
% plot([xcov(m1,m1,1000),xcov(m2,m2,1000)]);
% 
