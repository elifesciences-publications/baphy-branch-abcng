function Licks = TestLicking(globalparams, exptparams, exptparams)

cnt1 = 1;
fs = globalparams.HWparams.fsAI;
ShockTar = get(exptparams.TrialObject,'ShockTar');
Licks=[];
Lickprob=0;

%This loop collects the lick data for each reference and target stimulus
while cnt1<length(StimEvents)
    if strcmpi(StimEvents(cnt1).Note,'TRIALSTART') == 0
        
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        
        if strcmpi(Type,'Stim');
            if strcmpi(StimRefOrTar,'Reference')
                Licks = [Licks; linspace(0,1,single(fs*(StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)))'];
            else
                if ShockTar < 3
                    if StimEvents(cnt1).Rove(1) == ShockTar
                        if rand > Lickprob
                            Licks = [Licks; linspace(1,0,single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-.6)))'; zeros(fs.*0.6,1)];
                        else
                            Licks = [Licks; ones(single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime))))'; zeros(fs.*0.6,1)];
                        end
                    else
                        if rand > Lickprob
                            Licks = [Licks; ones(single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime))))'; zeros(fs.*0.6,1)];
                        else
                            Licks = [Licks; linspace(1,0,single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-.6)))'; zeros(fs.*0.6,1)];
                        end
                    end
                else
                    if rand >Lickprob
                        Licks = [Licks; linspace(1,0,single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime)-.6)))'; zeros(fs.*0.6,1)];
                    else
                        Licks = [Licks; ones(single(fs*((StimEvents(cnt1).StopTime-StimEvents(cnt1).StartTime))))'; zeros(fs.*0.6,1)];
                    end
                end
                
            end
            
        end
    end
    cnt1 = cnt1 + 1;
    
end
