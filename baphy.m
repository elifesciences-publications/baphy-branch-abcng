% BAPHY (Behavioural Auditory Physiology)
%
% version 1.00
% This is the main control script of baphy
% The steps taken are:
%   Run startup program, initialize the path.
%   Open the main GUI and wait for the user to specify the global parameters
%   Based on the Module, specify the initialization and run scripts
%   Run the module initialization using the global parameters
%   Initialize the hardware using the global parameters
%   Run the module script and get the events back
%   dump the data in an m file
%   write evp files
%   start over
%
% each different experimental paradigm (control mode) must specify
% initialization (initcommand) and run commands (runcommand) that fit this syntax:
%
% exptparams=feval(globalparams.initcommand,globalparams);
%    (if returns empty exptparams, then return to main menu)
% [events,exptparams]=feval(globalparams.runcommand,globalparams,exptparams,HW);
%    (events contain event log, exptparams can be modified by runcommand)

% Stephen, Nima, November 2005

global globalparams

disp('*** Starting baphy ***'); quit_baphy=0;
warning('off','MATLAB:dispatcher:InexactMatch');
baphy_set_path;

if exist('HW','var') ShutdownHW(HW); end

while ~quit_baphy,
    if exist('exptparams','var') && isfield(exptparams,'FigureHandle')
        try close(exptparams.FigureHandle);catch end;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine global parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  globalparam includes {Tester, Ferret, Module, Physiology, SiteID,
    %  number of electrodes, date and HWSetup)
    [globalparams, quit_baphy] = BaphyMainGui;
    % BaphyMainGui also returns a flag: quit_baphy. If the user pressed
    % 'exit' button this flag is one.
    if quit_baphy,  break;  end
    exptparams=feval(globalparams.initcommand,globalparams);
    
    % if globalparams.initcommand returns empty then skip experiment
    if ~isempty(exptparams),
        
        globalparams.tempdatapath=BaphyMainGuiItems('tempdatapath',globalparams);
        globalparams.outpath=BaphyMainGuiItems('outpath',globalparams);
        if isfield(exptparams,'outpath'),
            globalparams.outpath=exptparams.outpath;
        end
        
        % initcommand must define exptparams.runclass ("TOR", "FTC", etc).
        % this is used to construct appropriate file names
        if ~isfield(exptparams,'runclass') || isempty(exptparams.runclass),
            warning('initcommand should define exptparams.runclass. guessing TOR');
            exptparams.runclass='TOR';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % figure out names of output files (database or intelligent guess)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmpi(globalparams.outpath,'X'),
            % special case for testing. don't save
            globalparams.mfilename='';
            globalparams.rawid=0;
            globalparams.localevpfile='';
            globalparams.tempevpfile='';
            globalparams.evpfilename='';
        elseif dbopen,
            % talk to celldb if it's reachable
            if globalparams.outpath(end)~=filesep,
                globalparams.outpath=[globalparams.outpath filesep];
            end
            
            [globalparams.mfilename,globalparams.evpfilename,...
                globalparams.rawid]=...
                dbmfilename(globalparams,exptparams);
            pp=fileparts(fileparts(fileparts(globalparams.mfilename)));
            globalparams.outpath=[pp filesep];
            
            % rawid==-1 means the user selected "cancel". set exptparams to
            % [] in order to skip expt and return to main GUI
            if globalparams.rawid<0,
                exptparams=[];
            end
        else
            % guess m- and evp filenames
            if globalparams.outpath(end)~=filesep,
                globalparams.outpath=[globalparams.outpath filesep];
            end

            setcount=0;
            outfile='';
            while isempty(outfile) || exist([outfile,'.m'],'file'),
                setcount=setcount+1;
                outfile=[globalparams.outpath globalparams.Ferret ...
                    filesep globalparams.Ferret '_' ...
                    datestr(now,'yyyy_mm_dd') '_' exptparams.runclass ...
                    '_' num2str(setcount)];
            end
            globalparams.mfilename=[outfile,'.m'];
            globalparams.evpfilename=[outfile,'.evp'];
            globalparams.rawid=0;
        end
    end
    % check to see if tempdatapath and outpath are acessable, if not DONT
    % continue:
    if ~isempty(exptparams) && ~exist(globalparams.tempdatapath,'dir')
        warning(['The temp data path: ' globalparams.tempdatapath ' is not available, can not continue']);
        exptparams = [];
    end
    if ~isempty(exptparams) && ~exist(globalparams.outpath,'dir') && ...
            ~strcmp(upper(globalparams.outpath),'X')
        warning(['The output path: ' globalparams.outpath ' is not available, can not continue']);
        exptparams = [];
    end
    % also, if the directory required for mfilename (and evp) does not
    % exist create it:
    if ~isempty(exptparams) && ~exist(fileparts(globalparams.mfilename),'dir') &&...
            ~isempty(globalparams.mfilename),
        success = mkdir(fileparts(globalparams.mfilename));
        success = mkdir([fileparts(globalparams.mfilename) filesep 'tmp']);
        success = mkdir([fileparts(globalparams.mfilename) filesep 'raw']);
        if ~success,
            warning(['The file path: ' fileparts(globalparams.mfilename) ' is not available, can not continue']);
            exptparams = [];
        end
    end
    
    if ~isempty(exptparams),
        % define a local and temp evp file here. In alphaomega, the evp is
        % written locally first, then copied
        [tmp1, tmp2, tmp3] = fileparts(globalparams.mfilename);
        globalparams.tempMfile = [globalparams.tempdatapath tmp2 tmp3];
        % in alpha omega, there are three evps: local, remote before merge
        % (tempevp) and remote after merge (evpfilename):
        [tmp1, tmp2, tmp3] = fileparts(globalparams.evpfilename);
        globalparams.localevpfile = [globalparams.tempdatapath tmp2 tmp3];
        globalparams.tempevpfile  = globalparams.evpfilename;
        if ismember(globalparams.HWSetup,[1 3 7 9 10 11]),
            % if the tmp directory does not exist, create it:
            tmppath = [tmp1 filesep 'tmp'];
            if ~exist(tmppath,'dir'), mkdir(tmp1,'tmp');end
            globalparams.tempevpfile = [tmppath filesep tmp2 tmp3];
        end
        % based on the data in globalparam, initialize the hardware and return
        % the instruments handles in HW, which contains handles to
        % all the instruments including analog and digital IO, Attenuator,
        % Filter, TCPIP, etc.
        disp('Initializing hardware...');
        [HW, globalparams] = InitializeHW(globalparams);
        globalparams.ExperimentComplete=0;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Run the experiment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % NOTE: events structure has a standard form with the fields:
        %   Note: description of the event
        %   Trial: indicates the index of trial when event happened
        %   StartTime: seconds since beginning of trial
        %   StopTime: in seconds, since start of the trial
        [exptevents,exptparams]=feval(globalparams.runcommand,globalparams,exptparams,HW);
        
        % Shut down hardware
        disp('Shutting down hardware...');
        ShutdownHW(HW);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Save the results of the experiment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %warning('assuming 1 map file per trial');
        if isfield(exptevents,'Trial')
            globalparams.rawfilecount=max(cat(1,exptevents.Trial));
            if isfield(exptparams,'RepetitionCount'),
                RepCount=exptparams.RepetitionCount;
            elseif isfield(exptparams,'TotalRepetitions'),
                RepCount=exptparams.TotalRepetitions;
            elseif isfield(exptparams,'repcount'),
                RepCount=exptparams.repcount;
            else
               RepCount=0;
            end
            sql=['UPDATE gDataRaw SET trials=',...
                 num2str(globalparams.rawfilecount),',',...
                 ' reps=',num2str(RepCount),...
                 ' WHERE id=',num2str(globalparams.rawid)];
            mysql(sql);
        else
            globalparams.rawfilecount = 0;
        end

        % this is a useful indicator to the online analysis that it should
        % quit the iteritive STRF/raster update loop. also useful for
        % determining whether an experiment crashed before it was complete.
        globalparams.ExperimentComplete=1;

        if ~isempty(globalparams.mfilename) && ~strcmpi(globalparams.mfilename,'X'),

            % process evp file with behavior results according to hardware setup.
            switch globalparams.Physiology
              case 'NO';  %TRAINING
                disp('Generating behavior evp file...');
                % training/test, no physiology: just copy temp evp file to final location
                if exist(globalparams.tempevpfile,'file') && ...
                        ~strcmpi(globalparams.tempevpfile,globalparams.evpfilename),
                    movefile(globalparams.tempevpfile,globalparams.evpfilename);
                end
              otherwise % RECORDING
                % copy tempevpfile to remote computer if it hasn't
                % already been copied there.
                if exist(globalparams.localevpfile,'file')
                    d1=dir(globalparams.localevpfile);
                    d2=dir(globalparams.tempevpfile);
                    if isempty(d2) || d1.bytes~=d2.bytes,
                        movefile(globalparams.localevpfile, globalparams.tempevpfile);
                    end
                end
            end
            
            % WRITE PARAMS, STIMULUS, EXPTEVENTS TO MFILE
            if ~strcmpi(globalparams.Module,'Multi-Stimulus'),
                fprintf('Generating m-file: %s...\n',globalparams.mfilename);
                WriteMFile(globalparams,exptparams,exptevents,1);
            end
            
            % save results to jpeg accessible from celldb web interface!
            if isfield(exptparams,'results_command'),
                eval(exptparams.results_command);
                if ~isfield(exptparams,'ResultsFigure'),
                    exptparams.ResultsFigure=gcf;
                end
            end
            global BEHAVIOR_CHART_PATH DB_USER;
            if isfield(exptparams,'ResultsFigure') && exist(BEHAVIOR_CHART_PATH,'dir'),
                jpegpath=[BEHAVIOR_CHART_PATH lower(globalparams.Ferret) filesep datestr(now,'yyyy')];
                jpegfile=[basename(globalparams.mfilename(1:end-1)) 'jpg'];
                if ~exist([BEHAVIOR_CHART_PATH lower(globalparams.Ferret)],'file'),
                    mkdir(BEHAVIOR_CHART_PATH,lower(globalparams.Ferret));
                end
                if ~exist(jpegpath,'dir'),
                    mkdir([BEHAVIOR_CHART_PATH lower(globalparams.Ferret)],datestr(now,'yyyy'));
                end
                fprintf('printing to %s\n',jpegfile);
                tpo=get(exptparams.ResultsFigure,'PaperOrientation');
                tpp=get(exptparams.ResultsFigure,'PaperPosition');
                set(exptparams.ResultsFigure,'PaperOrientation','portrait','PaperPosition',[0.5 0.5 10 7.5])
                drawnow;
                print('-djpeg',['-f',num2str(exptparams.ResultsFigure)],[jpegpath filesep jpegfile]);
                set(exptparams.ResultsFigure,'PaperOrientation',tpo,'PaperPosition',tpp)
            end
            
            if strcmpi(globalparams.Physiology,'No') ||...
                strcmpi(globalparams.Physiology,'Yes -- Behavior'),
                sql=['SELECT gAnimal.id as animal_id,gHealth.id,gHealth.water'...
                    ' FROM gAnimal LEFT JOIN gHealth ON gHealth.animal_id=gAnimal.id'...
                    ' AND date="',datestr(now,29),'"'...
                    ' WHERE gAnimal.animal like "',globalparams.Ferret,'"'];
                hdata=mysql(sql);
                if ~isempty(hdata) && ~isempty(hdata.id),
                    sql=['UPDATE gHealth set trained=1 WHERE id=',num2str(hdata.id)];
                else
                    sql=['INSERT INTO gHealth (animal_id,animal,date,trained,addedby,info) VALUES'...
                        '(',num2str(hdata.animal_id),',"',globalparams.Ferret,'",',...
                        '"',datestr(now,29),'",1,"',DB_USER,'","dms_run.m")'];
                end
                mysql(sql);
            end
        else
            disp('outpath="X". Not saving m-file or evpfile!');
        end
    end
end