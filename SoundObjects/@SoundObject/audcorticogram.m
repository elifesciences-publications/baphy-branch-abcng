function cort = audcorticogram (o,param1,param2,fdecimate,forceCalculate);
%

% april 2006, Nima Mesgarani
if nargin<4, forceCalculate = 0;end
rv=2.^(0:6);
sv=2.^(-2:3);
fs = get(o,'SamplingRate');
figure;loadload;close;
auds = audspectrograms(o,param1,fdecimate,forceCalculate);
for cnt1=1:length(auds);
    disp([num2str(cnt1) ' out of ' num2str(get(o,'MaxIndex'))]);
    cort{cnt1} = aud2cor(auds{cnt1}',[param1 param2],rv,sv,'tmp');
end
