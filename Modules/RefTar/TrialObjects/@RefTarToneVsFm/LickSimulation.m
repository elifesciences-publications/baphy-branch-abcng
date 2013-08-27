function Licks = LickSimulation(globalparams, exptparams, StimEvents, ChanceLick)

cnt1 = 1;
fs = globalparams.HWparams.fsAI;
Licks=[];
ShockTar = get(exptparams.TrialObject,'ShockTar');
w = poisspdf(1:500,150);
randsample(1:500, single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)), 'true', w);

while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim');
            if strcmpi(StimRefOrTar,'Reference')
                if rand > ChanceLick
                    
%                     Licks = [Licks; randsample(1:500, single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)), 'true', w)'];
                else
                    Licks = [Licks; linspace(0,0,single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)))'];
                    
                end
            else
                if ShockTar < 3
                    if StimEvents(cnt1).Rove(1) == ShockTar
                        if rand > ChanceLick
                            Licks = [Licks; linspace(1,0,single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-.6)))'; zeros(fs.*0.6,1)];
                        else
                            Licks = [Licks; ones(single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime))),1)];
                        end
                    else
                        if rand > ChanceLick
                            Licks = [Licks; ones(single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime))),1)];
                        else
                            Licks = [Licks; linspace(1,0,single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-.6)))'; zeros(fs.*0.6,1)];
                        end
                    end
                else
                    if rand > ChanceLick
                        Licks = [Licks; linspace(1,0,single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-.6)))'; zeros(fs.*0.6,1)];
                    else
                        Licks = [Licks; ones(single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime))),1)];
                    end
                end
                
            end
            
        end
    end
    cnt1 = cnt1 + 1;
    
end
