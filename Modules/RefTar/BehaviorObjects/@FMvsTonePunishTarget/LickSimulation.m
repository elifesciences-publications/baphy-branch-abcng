function All_Licks = LickSimulation(o,globalparams, exptparams, StimEvents, ChanceLick)

cnt1 = 1;
fs = globalparams.HWparams.fsAI;
All_Licks=[];
Licks=[];
ShockTar = 3;
while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim');
            if strcmpi(StimRefOrTar,'Reference')
                
                %Reference
                lick = [ones(.1*fs,1); zeros(.15*fs,1)];
                LengthIndex = single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime));
                if rand > ChanceLick
                    Licks = [Licks; circshift(repmat(lick,LengthIndex/length(lick),1),roundTo(.1 + (.5-.1).*rand,2)*fs)];
                    
                else
                    Licks = [Licks; zeros(LengthIndex,1)];
                    
                end
            else
                if ShockTar < 3
                    if StimEvents(cnt1).Rove(1) == ShockTar
                        
                        %Target
                        if rand > ChanceLick
                            %Hit
                            lick = [ones(.1*fs,1); zeros(.15*fs,1)];
                            stoplick = randsample([.25 .5],1);
                            LengthIndex = single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-(1-stoplick)));
                            
                            Licks = [Licks; circshift(repmat(lick,LengthIndex/length(lick),1),roundTo(.1 + (.5-.1).*rand,2)*fs)];
                            
                            Licks = [Licks; zeros(LengthIndex-length(Licks)+(fs*(1-stoplick)),1)];
                            
                        else
                            %Miss
                            lick = [ones(.1*fs,1); zeros(.15*fs,1)];
                            LengthIndex = single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime));
                            
                            Licks = [Licks; circshift(repmat(lick,LengthIndex/length(lick),1),roundTo(.1 + (.5-.1).*rand,2)*fs)];
                            
                        end
                    else
                        %Distractor
                        if rand > ChanceLick
                            %CorrectRejection
                            lick = [ones(.1*fs,1); zeros(.15*fs,1)];
                            LengthIndex = single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime));
                            
                            Licks = [Licks; circshift(repmat(lick,LengthIndex/length(lick),1),roundTo(.1 + (.5-.1).*rand,2)*fs)];
                            
                            
                        else
                            %FalseAlarm
                            lick = [ones(.1*fs,1); zeros(.15*fs,1)];
                                                        stoplick = randsample([.25 .5],1);
                            LengthIndex = single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-(1-stoplick)));
                            
                            Licks = [Licks; circshift(repmat(lick,LengthIndex/length(lick),1),roundTo(.1 + (.5-.1).*rand,2)*fs)];
                            
                            Licks = [Licks; zeros(LengthIndex-length(Licks)+(fs*(1-stoplick)),1)];
                        end
                    end
                else
                    %Target
                    if rand > ChanceLick
                        %Hit
                        lick = [ones(.1*fs,1); zeros(.15*fs,1)];
                                                    stoplick = randsample([.25 .5],1);
                        LengthIndex = single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-(1-stoplick)));
                        
                        Licks = [Licks; circshift(repmat(lick,LengthIndex/length(lick),1),roundTo(.1 + (.5-.1).*rand,2)*fs)];
                        
                        Licks = [Licks; zeros(LengthIndex-length(Licks)+(fs*(1-stoplick)),1)];
                    else
                        %Miss
                        lick = [ones(.1*fs,1); zeros(.15*fs,1)];
                        LengthIndex = single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime));
                        
                        Licks = [Licks; circshift(repmat(lick,LengthIndex/length(lick),1),roundTo(.1 + (.5-.1).*rand,2)*fs)];
                        
                    end
                end
                
            end
            All_Licks = [All_Licks; Licks];
            
        end
    end
    cnt1 = cnt1 + 1;
    Licks=[];
    
end

% %PlotLicks
% % First, draw the boundries of Reference and Target
% figure(10000)
% for cnt1 = 1:length(StimEvents)
%     if ~isempty([strfind(StimEvents(cnt1).Note,'Reference') strfind(StimEvents(cnt1).Note,'Target')])
%         [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
%         if strcmpi(Type,'Stim')
%             
%             if strcmp(StimRefOrTar,'Reference')
%                 c='k';
%             elseif ShockTar ~= 3
%                 if StimEvents(cnt1).Rove(1) == ShockTar
%                     c='r';
%                 else
%                     c='c';
%                 end
%             elseif ShockTar == 3
%                 c='r'
%                 
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
%             elseif ShockTar ~= 3
%                 if StimEvents(cnt1).Rove(1) == ShockTar
%                     text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
%                         'color',c,'FontWeight','bold','HorizontalAlignment','center');
%                 else
%                     text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, 'D',...
%                         'color',c,'FontWeight','bold','HorizontalAlignment','center');
%                 end
%             elseif ShockTar == 3
%                 text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, 'T',...
%                     'color',c,'FontWeight','bold','HorizontalAlignment','center');
%                 
%             end
%         end
%     end
% end
% hold on
% plot(All_Licks)