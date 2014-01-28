function HW = IOMicTTLStart(HW)
%Demonstration function for using mic line as an analog trigger.
%Displays FFT of mic inpu signal.
%see
%http://www.mathworks.com/products/daq/examples.html;jsessionid=16a202205f602a5cac784b0990d7?file=/products/demos/shipping/daq/demoai_continuous.html
global MIC_TTL;

MIC_TTL=[];

TimerUpdate=0.05;

ai=analoginput('winsound');
addchannel(ai, 1);


%We can set samples per trigger to INF. you will need to use STOP to stop
%acquiring 
set(ai, 'SamplesPerTrigger', Inf);

%Use GETDATA to periodically bring data into matlab. Otherwise you will blow
%up system resources. DAQMEM checks to see what memory is available

daqmem(ai);

%Use TIMERFNC and TIMERPERIOD to create a callback. Every time TimerPeriod
%passes, matlab will run the callback specified by TimerFcn.

set(ai, 'TimerPeriod', TimerUpdate);
set(ai, 'TimerFcn', {@continuous_timer_callback});

HW.AI=ai;

% remaining step--done in IOStartAcquisition
%start(HW.ai);


%Now we need to define our callback.

function continuous_timer_callback(obj, event)
%obj is ai
%event is a variable containing EventLog property

if obj.SamplesAvailable<1
    return
end

[data, time]=getdata(obj, obj.SamplesAvailable);

if isempty(MIC_TTL);
    lastTTL=-1;
    MIC_TTL.time = [];
    MIC_TTL.data = [];
    
else
    lastTTL=MIC_TTL.data(end);
end

MICstd=std(data);
%figure(1);
%plot(data);

%[ get(obj,'SamplesAcquired') get(obj,'SamplesPerTrigger') MICstd];
THRESHOLD=10^-2;

% only recode a new event if ttl status has changed
if MICstd>THRESHOLD && lastTTL~=1,
    % changed to high
    MIC_TTL.data=[MIC_TTL.data;1];
    MIC_TTL.time=[MIC_TTL.time;now()];
    MIC_TTL.data';
elseif MICstd<=THRESHOLD && lastTTL~=0,
    MIC_TTL.data=[MIC_TTL.data;0];
    MIC_TTL.time=[MIC_TTL.time;now()];
    %MIC_TTL.data'
end

if get(obj,'SamplesAcquired')==get(obj,'SamplesPerTrigger'),
    stop(obj);
    disp('max samples acquired. stopping MICTTL from inside trigger function.');
end

end

end


