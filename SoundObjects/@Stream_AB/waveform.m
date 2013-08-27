function [w, ev]=waveform (o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object Stream_AB
%
%Pingbo, December 2005.

SamplingRate = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

% the parameters of Stream_AB object
ToneDur = get(o,'ToneDur');
ToneGap = get(o,'ToneGap'); % duration is second
Names = get(o,'Names');
Type = deblank(get(o,'Type'));
ABratio=get(o,'dBAtten_A2B');
ABratio=10^(-ABratio/20);    %convert DB into amplitude ratio
Frequency = str2num(Names{index(1)});%c1-tone A; c2-tone B; c3-complex number; c4-tardB;
tardB = Frequency(4);
% now generate a tone with specified frequency:
t=0:1/SamplingRate:ToneDur;
tgap=0:1/SamplingRate:ToneGap;
% if length(index)>1
%     dBAttr2t = index(2);
% else
%     dBAttr2t = 0;
% end

Bdev = round(Frequency(2)*2^(1/4));
A = addenv(ABratio*sin(2*pi*Frequency(1)*t),SamplingRate);
B = addenv(sin(2*pi*Frequency(2)*t),SamplingRate);
Bprime = addenv(sin(2*pi*Bdev*t),SamplingRate);
tarB = 10^(tardB/20)*B;
tarA = 10^(tardB/20)*A;
gap=sin(2*pi*0*tgap);
ToneDur=length(A)/SamplingRate;
ToneGap=length(gap)/SamplingRate;
w=[];ev=[];
ev = AddEvent(ev,[''],[],0,PreStimSilence);
switch Type
    case {'referenceBB','referenceAA'}
        for i=1:Frequency(3)-1
            w=[w;A(:);gap(:);B(:);gap(:)];
            ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
            ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        end
        w = [w;A(:);gap(:);B(:)];
        ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
        ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
        switch Type
            case 'referenceAA'
                w=[w;gap(:);];
                ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
            case 'referenceBB'
                w=[w;gap(:);A(:);gap(:);];  %referenceBB add a extra note A
                ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
                ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
                ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        end
   case 'targetAA'
        for i=1:Frequency(3)-1
            w=[w;tarA(:);gap(:);B(:);gap(:)];
            ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
            ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        end
        w = [w;tarA(:);gap(:);B(:)];
        ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
        ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
    case 'targetBB'
        for i=1:Frequency(3)-1
            w=[w;tarB(:);gap(:);A(:);gap(:)];
            ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
            ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        end
        w=[w;tarB(:);gap(:);A(:)];  %target ends without silence gap
        ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
        ev = AddEvent(ev,['GAP , ToneB ' num2str(Frequency(2)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ', r2t ' num2str(tardB)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
    case 'RefTar' %Light stimuli as target;
        for i=1:Frequency(3)
            w=[w;A(:);gap(:);B(:);gap(:)];
            ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
            ev = AddEvent(ev,['STIM , ToneB ' num2str(Frequency(2)) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneB ' num2str(Frequency(2)) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        end
        for j=1:5 %always 5ABprime+1A;
            w = [w;A(:);gap(:);Bprime(:);gap(:)];
            ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneA ' num2str(Frequency(1)) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
            ev = AddEvent(ev,['STIM , ToneB ' num2str(Bdev) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
            ev = AddEvent(ev,['GAP , ToneB ' num2str(Bdev) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneGap);
        end
        w=[w;A(:)];  %target ends without silence gap
        ev = AddEvent(ev,['STIM , ToneA ' num2str(Frequency(1)) ' , AB ' num2str(Frequency(3))],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
end
w = [zeros(PreStimSilence*SamplingRate,1); w(:) ;zeros(PostStimSilence*SamplingRate,1)];
[a,b,c]  = ParseStimEvent(ev(2),0); % dont remove spaces
ev (1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);
% w = 5 * w/max(abs(w));
w = 5*w/10;

%add 5 ms rise/fall time ===================================
function s=addenv(s1,fs);
f=ones(size(s1));
pn=round(fs*0.005);    % 5 ms rise/fall time
up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
f = [up ones(1,length(s1)-2*pn) down]';
s=s1(:).*f(:);