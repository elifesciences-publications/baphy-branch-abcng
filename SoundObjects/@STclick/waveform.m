function [w, events] = waveform(o,index,IsRef)
% Nima, dec 2005
% Sundeep Teki, May 2015. Added irregular click train functionality.

%% variables
PreStimSilence  = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end

Names           = get(o,'Names');
duration        = get(o,'Duration');
width           = get(o,'ClickWidth');
rate            = str2num(Names{index});
SamplingRate    = get(o,'SamplingRate');
jitter          = get(o,'ClickJitter'); % based on a uniform distribution
jitrange        = get(o,'JitterRange');
jitterpos       = get(o,'ClickJitterPos');

w               = zeros(1, duration * SamplingRate);
rateSamples     = SamplingRate / rate;
Cindex          = 1:rateSamples:length(w);
OnSamples       = width * SamplingRate / 2;
flag            = 1;

%% click regularity flag

if jitter == 0
    jitterflag  = 0; % regular
else
    jitterflag  = 1; % irregular
end

%% create stimulus

% regular click train; original click code
if jitterflag == 0
    for cnt1    = 1:length(Cindex)
        if flag==1;
            flag =-1;
        else flag = 1;
        end
        w( ceil(max(1,Cindex(cnt1)-OnSamples) : min(Cindex(cnt1)+OnSamples,length(w))) )=flag;
    end
    
    
    % irregular click train
elseif jitterflag == 1
    
    % entire click train is irregular
    if jitterpos == 0
        for cnt1    = 1:length(Cindex)
            if flag==1;
                flag =-1;
            else flag = 1;
            end
            
            jit = ((jitter - jitrange/2) + (jitrange).*rand(100,1))/100;
            tmp = Cindex(cnt1) + sign(rand(1)-0.5)*Cindex(cnt1)*jit(randi(100));
            w( ceil(max(1,tmp-OnSamples) : min(tmp+OnSamples,length(w))) )=flag;
        end
        
        % click train starts as regular and then becomes irregular at jitterpos
    else
        jitlimit = ceil(jitterpos*length(Cindex));
        
        for cnt1    = 1:length(Cindex)
            if flag==1;
                flag =-1;
            else flag = 1;
            end
            
            if cnt1 <= jitlimit % regular bit
                w( ceil(max(1,Cindex(cnt1)-OnSamples) : min(Cindex(cnt1)+OnSamples,length(w))) )=flag;
                
            elseif cnt1 == jitlimit+1 % first click after transition -
                jit = ((jitter - jitrange/2) + (jitrange).*rand(100,1))/100;
                % make sign positive so next click does not precede last click of regular bit
                tmp = Cindex(cnt1) + Cindex(cnt1)*jit(randi(100));                 
                w( ceil(max(1,tmp-OnSamples) : min(tmp+OnSamples,length(w))) )=flag;
                
            elseif cnt1 > jitlimit + 1 % irregular bit
                jit = ((jitter - jitrange/2) + (jitrange).*rand(100,1))/100;
                tmp = Cindex(cnt1) + sign(rand(1)-0.5)*Cindex(cnt1)*jit(randi(100));
                w( ceil(max(1,tmp-OnSamples) : min(tmp+OnSamples,length(w))) )=flag;
            end
            
        end
    end
end


% Now, put it in the silence:
Names = Names(index);
w     = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];

% and generate the event structure:
events = struct('Note',['PreStimSilence , ' Names{:}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
events(2) = struct('Note',['Stim , ' Names{:}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+duration,'Trial',[]);
events(3) = struct('Note',['PostStimSilence , ' Names{:}],...
    'StartTime',PreStimSilence+duration, 'StopTime',PreStimSilence+duration+PostStimSilence,'Trial',[]);
if max(abs(w))>0
    w = 5 * w/max(abs(w));
end

% savepath = 'D:\Data\Maroille\';
% save([savepath 'stclicktimes_' num2str(randi(1000))],'w')
