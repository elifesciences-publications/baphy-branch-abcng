function Vec = addSinRamp(Vec,RampDurms,SRkHz,method)

RampSteps=floor(RampDurms*SRkHz);
dt = 1/(1000*SRkHz);
t = [dt:dt:RampDurms/1000];
if size(Vec,1)>size(Vec,2) t = t'; end
FRamp = 1/(2*RampDurms/1000); 
StartRamp = (sin(2*pi*(FRamp*t-.25))+1)/2;
EndRamp = StartRamp(end:-1:1);

if length(Vec)==1 % if Vec specifies a length, then Vec is in [s]
  Vec = ones(1,floor(Vec*1000*SRkHz));
end

switch method
 case '<=='
  Vec(1:RampSteps) = StartRamp.*Vec(1:RampSteps);
 case '==>'
  Vec(end-RampSteps+1:end) = EndRamp.*Vec(end-RampSteps+1:end);
 case '<=>'
  Vec(1:RampSteps) = StartRamp.*Vec(1:RampSteps);
  Vec(end-RampSteps+1:end) = EndRamp.*Vec(end-RampSteps+1:end);
  otherwise error('Unknown Rampshape.');
end
