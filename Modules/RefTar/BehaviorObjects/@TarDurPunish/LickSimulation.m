function All_Licks = LickSimulation(o,globalparams, exptparams, StimEvents, ChanceLick)

cnt1 = 1;
fs = globalparams.HWparams.fsAI;
All_Licks=[];
Licks=[];
TrialObject = get(exptparams.TrialObject);
TargetObject = get(TrialObject.TargetHandle);
ReferenceObject = get(TrialObject.ReferenceHandle);
RefPreStimSilence = ReferenceObject.PreStimSilence;
RefPostStimSilence = ReferenceObject.PostStimSilence;
TarPreStimSilence = TargetObject.PreStimSilence;
TarPostStimSilence = TargetObject.PostStimSilence;

while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim')
            if strcmpi(StimRefOrTar,'Reference')
                
                %Reference
                LengthIndex = single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)));
                t = 0:1/fs:(LengthIndex/fs)-(1/fs);
                if rand > .01
                    %Safe
                    Licks = [zeros(fs*RefPreStimSilence,1); circshift(abs(sin(2*pi*2.*t))',roundTo(.1 + (.5-.1).*rand,2)*fs); zeros(fs*RefPostStimSilence,1)];
                    
                else
                    %Snooze
                    Licks = [zeros(fs*RefPreStimSilence,1); zeros(LengthIndex,1); zeros(fs*RefPostStimSilence,1)];
                    
                end
            else
                
                stoplick = randsample([.25 .35 .35],1);
                
                %Target
                
                if rand > ChanceLick
                    
                    %Hit
                    Ltime = (StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime);
                    LengthIndex = single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-((1-stoplick)*Ltime)));
                    t = 0:1/fs:(LengthIndex/fs)-(1/fs);
                    Licks = [zeros(fs*TarPreStimSilence,1); circshift(abs(sin(2*pi*2.*t))',roundTo(.1 + (.5-.1).*rand,2)*fs)];
                    Licks = [Licks; zeros(fs*((1-stoplick)*Ltime),1); zeros(fs*TarPostStimSilence,1)];
                    
                else
                    
                    %Miss
                    LengthIndex = single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)));
                    t = 0:1/fs:(LengthIndex/fs)-(1/fs);
                    Licks = [Licks; zeros(fs*TarPreStimSilence,1); circshift(abs(sin(2*pi*2.*t))',roundTo(.1 + (.5-.1).*rand,2)*fs); zeros(fs*TarPostStimSilence,1)];
                    
                end
                
            end
        end
        cnt1 = cnt1 + 1;
        All_Licks = [All_Licks; Licks];
        Licks=[];
    end
end
    
% %PlotLicks
% % First, draw the boundries of Reference and Target
% figure(10000)
% clf
% for cnt1 = 1:length(StimEvents)
%     if ~isempty([strfind(StimEvents(cnt1).Note,'Reference') strfind(StimEvents(cnt1).Note,'Target')])
%         [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
%         if strcmpi(Type,'Stim')
%             
%             if strcmp(StimRefOrTar,'Reference')
%                 c='k';
%             else
%                 c='r';
%             end
%             
%             line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StartTime],[0 .5],'color',c,...
%                 'LineStyle','--','LineWidth',2);
%             line([fs*StimEvents(cnt1).StopTime fs*StimEvents(cnt1).StopTime],[0 .5],'color',c,...
%                 'LineStyle','--','LineWidth',2);
%             line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StopTime], [.5 .5],'color',c,...
%                 'LineStyle','--','LineWidth',2);
%             
%             if strcmp(StimRefOrTar,'Reference')
%                 text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
%                     'color',c,'FontWeight','bold','HorizontalAlignment','center');
%                 1
%             else
%                 text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
%                     'color',c,'FontWeight','bold','HorizontalAlignment','center');
%                 0
%             end
%         end
%     end
% end
% hold on
% plot(All_Licks)