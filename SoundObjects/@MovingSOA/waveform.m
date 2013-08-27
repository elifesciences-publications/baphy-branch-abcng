function [w, ev]=waveform (o,index,isref);
% function w=waveform(t);
% this function is the waveform generator for object Stream_AB
%
%Ling Ma modified from Stream_AB(Pingbo), Jun. 2006

SamplingRate = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

% the parameters of Stream_AB object
ToneDur = get(o,'ToneDur');
ToneGap = get(o,'ToneGap'); % duration is second
Names = get(o,'Names');% [ToneA ToneB SOA]
% Type = deblank(get(o,'Type'));
ABratio=get(o,'dBAtten_A2B');
ABratio=10^(-ABratio/20);    %convert DB into amplitude ratio
Frequency = str2num(Names{index})
% now generate a tone with specified frequency:
t=0:1/SamplingRate:ToneDur;
tgap=0:1/SamplingRate:2*ToneGap+ToneDur;%tonedur+tonegap
Amp = 5/2;
A = Amp*addenv(ABratio*sin(2*pi*Frequency(1)*t),SamplingRate);
B = Amp*addenv(sin(2*pi*Frequency(2)*t),SamplingRate);
gap=sin(2*pi*0*tgap);
ToneDur=length(A)/SamplingRate;
ToneGap=length(gap)/SamplingRate;
% ComplexNum = Frequency(3);
ComplexNum = get(o,'ComplexNum');

w1=[];w2=[];ev=[];
ev = AddEvent(ev,[''],[],0,PreStimSilence);

            for i=1:ComplexNum-1
                w1= [w1;A(:);gap(:)]; w2 = [w2;B(:);gap(:)];
                if length(ev)==1
                    last=length(ev);
                else
                    last=length(ev)-1;
                end
                ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ' ' num2str(Frequency(3)) ' ' num2str(Frequency(4))],[],ev(last).StopTime,ev(last).StopTime+ToneDur);
                ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ' ' num2str(Frequency(3)) ' ' num2str(Frequency(4))],[],ev(end).StartTime+Frequency(4),ev(end).StartTime+Frequency(4)+ToneDur);
                ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ' ' num2str(Frequency(3)) ' ' num2str(Frequency(4))],[],ev(end-1).StopTime,ev(end-1).StopTime+ToneGap);
                ev = AddEvent(ev,['GAP , ToneB ' num2str(Frequency(2)) ' ' num2str(Frequency(3)) ' ' num2str(Frequency(4))],[],ev(end-1).StopTime,ev(end-1).StopTime+ToneGap);
            end
            w1 = [w1;A(:)]; w2 = [w2;B(:)];
            ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ' ' num2str(Frequency(3)) ' ' num2str(Frequency(4))],[],ev(end-1).StopTime,ev(end-1).StopTime+ToneDur);
            ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ' ' num2str(Frequency(3)) ' ' num2str(Frequency(4))],[],ev(end).StartTime+Frequency(4),ev(end).StartTime+Frequency(4)+ToneDur);
            
            w2 = [zeros(Frequency(4)*SamplingRate,1);w2];
            w1 = [w1;zeros(length(w2)-length(w1),1)];
            w = w1+w2;       
            
%             switch Type
%                 case 'targetAA'
%                     w2 = [zeros(Frequency(4)*SamplingRate,1);w2];
%                     w1 = [w1;zeros(length(w2)-length(w1),1)];
%                     w = w1+w2;
%                 case 'referenceAA'
%                     w1=[w1;gap(:)];
% %                     ev = AddEvent(ev,['GAP , ToneB ' num2str(Frequency(2)) ' ' num2str(Frequency(4))],[],ev(end-1).StopTime,ev(end-1).StopTime+ToneGap);
%                     ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ' ' num2str(Frequency(4))],[],ev(end-1).StopTime,ev(end-1).StopTime+ToneGap);
%                     w2 = [zeros(Frequency(4)*SamplingRate,1);w2];
%                     w2 = [w2;zeros(length(w1)-length(w2),1)];
%                     w = w2+w1;
%             end
%             
w = [zeros(PreStimSilence*SamplingRate,1); w(:) ;zeros(PostStimSilence*SamplingRate,1)];
[a,b,c]  = ParseStimEvent(ev(2),0); % dont remove spaces
ev (1).Note = ['PreStimSilence , ' b];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev      = AddEvent(ev,['PostStimSilence , ' b],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);
% w = 5 * w/max(abs(w));

%add 5 ms rise/fall time ===================================
function s=addenv(s1,fs);
f=ones(size(s1));
pn=round(fs*0.005);    % 5 ms rise/fall time
up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
f = [up ones(1,length(s1)-2*pn) down]';
s=s1(:).*f(:);
