function TMG_CheckTrialLength(LocalRootFolder,mFile,DistantRootFolder)

clear GrmpfSessions exptevents UnfinishedTrials
counter = 0; UncompleteTrials = [];
CheckTrial = 1;
RegenerateStim = 1;
LFPsf = 2000;
%%
cd(LocalRootFolder)
fprintf('Checking TMG file length + generating stimulus files... ')
clear exptevents
run(mFile(1:end-2));
%%
if RegenerateStim
    if exptevents(end).Trial>25
        [Stimuli,ChangeTimes,options,Behavior] = TMG_ResynthesizeStim(mFile(1:end-2),'RootAdress',LocalRootFolder);
        Stimuli.ChangeTimes = ChangeTimes;
        save([DistantRootFolder mFile(1:end-2) '_ToneClouds.mat'],...
            '-struct','Stimuli','waveform','PreChangeToneMatrix','PostChangeToneMatrix','SoundStatistics','ChangeTimes');
        if ~isempty(Behavior); save([DistantRootFolder mFile(1:end-2) '_Behavior.mat'],'Behavior'); end
    end
end

if CheckTrial
    % events
    TrialStopEventsInd = strcmpi({exptevents.Note},'TRIALSTOP');
    % lfp
    cd(['raw/' mFile(1:(find(mFile=='_',1,'first')-1))]);
    evpfiles = dir([mFile(1:end-2) '*']);
    [~,~,~,~,rL,LTrialIdx] = evpread(evpfiles(1).name,'lfpchans',1);
    cd ..; cd ..;
    ProblemInLength = 0;
    trialfunum = 0;
    if exptevents(end).Trial>25
        for tnum = 1:(exptevents(end).Trial-1)
            % end time from event structure
            indd = find([exptevents.Trial]==tnum & TrialStopEventsInd);
            EndTimeEv = exptevents(indd).StopTime;
            % end time from lfp
            EndTimeLFP = (LTrialIdx(tnum+1)-LTrialIdx(tnum))/LFPsf;
            if abs(EndTimeLFP-EndTimeEv)>0.1
                if ~ProblemInLength
                    counter = counter+1;
                    ProblemInLength = 1;
                end
                trialfunum = trialfunum+1;
                UncompleteTrials{counter}.Session = mFile(1:end-2);
                UncompleteTrials{counter}.Trials(trialfunum) = tnum;
                disp('!!!!!!!!!!!!!!!');
                fprintf(['  -->  ' num2str(tnum) ]);
            end
        end
        if ProblemInLength
            fprintf([' Found ' num2str(length(UncompleteTrials{counter}.Trials)) ' uncomplete trials! '])
            UnfinishedTrials = UncompleteTrials{counter}.Trials;
            save([DistantRootFolder UncompleteTrials{counter}.Session '_UnfinishedTrials.mat'],'UnfinishedTrials');
        end
    end
end
fprintf('Done. \n');