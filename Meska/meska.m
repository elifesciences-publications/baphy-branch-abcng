% meska.m
%
% main meska program:
%  define all the various windows, load raw signals, identify
%  candidate spike events
%
%
global EXPERIMENT_DIR meska_ROOT

% old code moved out to baphy_set_path
% make sure path settings are correct
%global meska_ROOT

% presumably meska_ROOT is simply the path the copy of meska that's running:
%meska_ROOT=fileparts(which(mfilename));

% this code should now be unnecessary (SVD 2005-10-13)
%addpath(meska_ROOT);

%if ~strcmp(computer,'GLNX86'),
%   % for some reason the objects in these paths crash matlab in linux
%   addpath([meska_ROOT filesep 'shared']);
%   addpath([meska_ROOT filesep 'signals']);
%   addpath([meska_ROOT filesep 'userInterface']);
%end

if ~exist('spkfig'), spkfig = 0; GUIINIT = 0; end
if ~ishandle(spkfig), GUIINIT = 0; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~GUIINIT,
    
    close all force, clear
    
    % settings for connecting to celldb (SVD 2005-10-13)
    global USEDB
    if isempty(USEDB),
        USEDB=0;
    end
    if USEDB
        disp('celldb interface on');
        dbmeskinit;
    else
        disp('celldb interface switched off');
    end
    
    %chanNum = 1; % to be set when file is opened. It will be one for now
    comments=[];
    thrdef = 4.0;
    nspkdef = 50;
    nwindef = 1;
    xaxisdef = [-10,39];
    classtot = 12; % must be a multiple of 4 
    npages = 1 + (classtot - 4)/4;
    maxfilenum = 2;
    
    RECOMPUTE = 1;
    REFRESH = 1;
    SAVED = 0;
    PSORTER = 0;
    ONEFILE = 0;
    SAVEAS=0;
    OPNFLAG=0;
    FIRSTSAVED=1;
    SECONDSAVED=1;
    REGORDER1 = 0;
    REGORDER2 = 0;
    
    
    spkfig = figure;
    set(gcf,'WindowStyle','normal')
    set(gcf,'pos',[70 350 1150 500],'name','MESKA? Multi Electrode Spike Sorter','NumberTitle','off')
    hpos(1:3,1:4) = [.125, .11, .335, .78;.125, .50, .335, .39;.125, .07, .335, .39];
    
    %%%%%%%%%% "Open" Window %%%%%%%%%%%%
    opnfig = figure;
    set(gcf,'WindowStyle','normal');
    set(opnfig,'pos',[400 325 350 300],'name','meska - Open','NumberTitle','off','visible','off')
    
    to1 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .850 .214 .100],'string',{'1st EVP File'; 'eg. 20b14.a1-'});
    to2 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .710 .214 .100],'string',{'Exp Directory'; 'eg. 236'});
    if strcmp(computer,'SOL2') | strmatch('GLNX',computer),
        to3 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .570 .214 .100],'string',{'Path'; 'eg. /data/'});
    elseif strcmp(computer,'MAC2')
        to3 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .570 .214 .100],'string',{'Path'; 'eg. 236a:'});
    end
    
    to4 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .430 .214 .100],'string',{'2nd EVP File'; 'eg. 20b14.a1-'});
    to5 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .290 .214 .100],'string',{'Exp Directory'; 'eg. 236'});
    if strcmp(computer,'SOL2') | strmatch('GLNX',computer),
        to6 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .150 .214 .100],'string',{'Path'; 'eg. /data/'});
    elseif strcmp(computer,'MAC')
        to6 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .150 .214 .100],'string',{'Path'; 'eg. 236a:'});
    elseif strcmp(computer,'PCWIN')
        to6 = uicontrol(opnfig,'style','text','units','norm','pos',[.029 .150 .214 .100],'string',{'Path'; 'eg. /data/'});
    end
    
    ot1 = uicontrol(opnfig,'style','edit','units','norm','pos',[.354 .850 .571 .070],'backgroundcolor',[1 1 1]);
    ot2 = uicontrol(opnfig,'style','edit','units','norm','pos',[.354 .710 .571 .070],'backgroundcolor',[1 1 1]);
    ot3 = uicontrol(opnfig,'style','edit','units','norm','pos',[.354 .570 .571 .070],'backgroundcolor',[1 1 1]);
    
    ot4 = uicontrol(opnfig,'style','edit','units','norm','pos',[.354 .430 .571 .070],'backgroundcolor',[1 1 1]);
    ot5 = uicontrol(opnfig,'style','edit','units','norm','pos',[.354 .290 .571 .070],'backgroundcolor',[1 1 1]);
    ot6 = uicontrol(opnfig,'style','edit','units','norm','pos',[.354 .150 .571 .070],'backgroundcolor',[1 1 1]);
    
    co = uicontrol(opnfig,'style','check','units','norm','pos',[.029 .015 .060 .070],'value', 0 ,'callback',...
        ['if get(co,''value''),','set(ot4,''visible'',''off''),', 'set(ot5,''visible'',''off''),','set(ot6,''visible'',''off''),',...
            'set(to4,''visible'',''off''),','set(to5,''visible'',''off''),','set(to6,''visible'',''off''),','ONEFILE=1,',...   
            'else,','set(ot4,''visible'',''on''),','set(ot5,''visible'',''on''),','set(ot6,''visible'',''on''),',...
            'set(to4,''visible'',''on''),','set(to5,''visible'',''on''),','set(to6,''visible'',''on''),','ONEFILE=0,','end,']);
    uicontrol(opnfig,'style','text','units','norm','pos',[.100 .015 .150 .070],'string','One file')
    
    ot7 = uicontrol(opnfig,'style','edit','units','norm','pos',[.470 .015 .060 .070],'backgroundcolor',[1 1 1]);
    set(ot7,'string','1');
    uicontrol(opnfig,'style','text','units','norm','pos',[.300 .015 .150 .070],'string','Channel #')
    
    
    
    uicontrol(opnfig,'style','push','units','norm','pos',[.786 .005 .143 .070],'string','Open','callback',...
        ['set(opnfig,''visible'',''off''),','drawnow,','RESUME=1;','uiresume(opnfig)'])
    uicontrol(opnfig,'style','push','units','norm','pos',[.614 .005 .143 .070],'string','Cancel','callback',...
        ['DATAFLAG=1;','RECOMPUTE=0;','set(opnfig,''visible'',''off''),','RESUME=0;','uiresume(opnfig)'])
    set(opnfig,'Visible','on')
    
    %uiwait(opnfig);
    
    set(opnfig,'HandleVisibility','off')
    set(opnfig,'visible','off');    
    
    %close(opnfig);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%% Main meska Figure%%%%%%%%%%%%%%%%%%
    if ONEFILE
        h1 = subplot(121); set(gca,'pos',[hpos(1,1) hpos(1,2) hpos(1,3) hpos(1,4)])
    else
        h1 = subplot(121); set(gca,'pos',[hpos(2,1) hpos(2,2) hpos(2,3) hpos(2,4)])
        bh1= uicontrol(spkfig,'style','push','units','norm','pos',[.443 .85 .017 .040],'string','C','callback',...
            ['saveundo,','delSpikes1;']);
        
        h12= subplot(122); set(gca,'pos',[hpos(3,1) hpos(3,2) hpos(3,3) hpos(3,4)])
        bh12= uicontrol(spkfig,'style','push','units','norm','pos',[.443 .42 .017 .040],'string','C','callback',...
            ['saveundo,','delSpikes2;']);
    end
    h2 = subplot(243); 
    t1 = uicontrol(spkfig,'style','text','units','normalized','pos',[.573 .928 .104 .040],'string','Class 1');
    h3 = subplot(244); 
    t2 = uicontrol(spkfig,'style','text','units','normalized','pos',[.782 .928 .104 .040],'string','Class 2');
    h4 = subplot(247); 
    t3 = uicontrol(spkfig,'style','text','units','normalized','pos',[.573 .458 .104 .040],'string','Class 3');
    h5 = subplot(248); 
    t4 = uicontrol(spkfig,'style','text','units','normalized','pos',[.782 .458 .104 .040],'string','Class 4');
    
    uicontrol(spkfig,'style','frame','units','norm','pos',[.129 .900 .113 .090])
    uicontrol(spkfig,'style','text','units','norm','pos',[.130 .940 .043 .040],'string','Window')
    uicontrol(spkfig,'style','text','units','norm','pos',[.139 .906 .017 .040],'string','#')
    e1 = uicontrol(spkfig,'style','edit','units','normalized','pos',[.156 .904 .030 .040],'backgroundcolor',[1 1 1],'string',num2str(nwindef));
    b1 = uicontrol(spkfig,'style','push','units','norm','pos',[.186 .944 .052 .040],'string','Select','userdata',1,'callback',...
        ['set(b1,''userdata'',~get(b1,''userdata''));','if ~get(b1,''userdata''),','BAR=0;','window,','end']);
    b2 = uicontrol(spkfig,'style','push','units','norm','pos',[.186 .904 .052 .040],'string','Unselect','userdata',1,'callback',...
        ['set(b2,''userdata'',~get(b2,''userdata''));','if ~get(b2,''userdata''),','BAR=1;','window,','end']);
    
    uicontrol(spkfig,'style','frame','units','norm','pos',[.242 .900 .223 .090])
    uicontrol(spkfig,'style','text','units','norm','pos',[.243 .946 .057 .030],'string','workspace:')
    b3 = uicontrol(spkfig,'style','push','units','norm','pos',[.299 .944 .052 .040],'string','Invert','callback',...
        ['invert']);
    b4 = uicontrol(spkfig,'style','push','units','norm','pos',[.351 .944 .052 .040],'string','Delete','callback',...
        ['delSpikes']);
    b7 = uicontrol(spkfig,'style','push','units','norm','pos',[.403 .944 .052 .040],'string','Clear All','callback',...
        ['clearSpikes']);
    
    uicontrol(spkfig,'style','text','units','norm','pos',[.243 .906 .059 .030],'string','move/copy')
    p1 = uicontrol(spkfig,'style','popup','units','norm','pos',[.421 .904 .041 .040],'string',cellstr(num2str((1:classtot)')));
    b5 = uicontrol(spkfig,'style','push','units','norm','pos',[.403 .904 .017 .040],'string','=>','callback',...
        ['TO = 1;','DEL = get(c1,''value'');','cnm = get(p1,''value'');','spikeshuttle']);
    b6 = uicontrol(spkfig,'style','push','units','norm','pos',[.386 .904 .017 .040],'string','<=','callback',...
        ['FROM = 1;','DEL = get(c1,''value'');','cnm = get(p1,''value'');','spikeshuttle']);
    c1 = uicontrol(spkfig,'style','check','units','norm','pos',[.351 .904 .035 .040],'string','mv','value',1,'callback',...
        ['if get(c1,''value''),','set(c1,''string'',''mv''),','else,','set(c1,''string'',''cp''),','end']);
    
    b14 = uicontrol(spkfig,'style','push','units','norm','pos',[.681 .884 .017 .040],'string','C','callback',...
        ['saveundo,','spk1=[];','subplot(h2),','cla reset']);
    b16 = uicontrol(spkfig,'style','push','units','norm','pos',[.887 .884 .017 .040],'string','C','callback',...
        ['saveundo,','spk2=[];','subplot(h3),','cla reset']);
    b18 = uicontrol(spkfig,'style','push','units','norm','pos',[.681 .414 .017 .040],'string','C','callback',...
        ['saveundo,','spk3=[];','subplot(h4),','cla reset']);
    b20 = uicontrol(spkfig,'style','push','units','norm','pos',[.887 .414 .017 .040],'string','C','callback',...
        ['saveundo,','spk4=[];','subplot(h5),','cla reset']);
    
    uicontrol(spkfig,'style','frame','units','norm','pos',[.013 .900 .113 .090])
    uicontrol(spkfig,'style','text','units','norm','pos',[.039 .946 .056 .030],'string','Display')
    e2 = uicontrol(spkfig,'style','edit','units','normalized','pos',[.089 .944 .035 .040],'backgroundcolor',[1 1 1],...
        'string',num2str(nspkdef),'callback',['nspk = str2num(get(e2,''string''));','meska']);
    uicontrol(spkfig,'style','text','units','norm','pos',[.039 .906 .056 .030],'string','Threshold')
    e3 = uicontrol(spkfig,'style','edit','units','norm','pos',[.093 .904 .030 .040],'backgroundcolor',[1 1 1],...
        'string',num2str(thrdef),'callback',['RECOMPUTE = 1;','REFRESH = 1;','meska']);
    
    uicontrol(spkfig,'style','frame','units','norm','pos',[.698 .460 .056 .124],'backgroundcolor',[.7 .7 .7])
    uicontrol(spkfig,'style','text','units','norm','pos',[.713 .550 .026 .030],'string','Page #')
    b21 = uicontrol(spkfig,'style','push','units','norm','pos',[.699 .508 .017 .040],'string','<-','callback',...
        ['if str2num(get(e6,''string''))>1,','set(e6,''string'',num2str(str2num(get(e6,''string''))-1)),','classrefresh,','end']);
    e6 = uicontrol(spkfig,'style','edit','units','norm','pos',[.716 .508 .017 .040],'backgroundcolor',[1 1 1],'string','1','callback',...
        ['classrefresh']);
    b22 = uicontrol(spkfig,'style','push','units','norm','pos',[.734 .508 .017 .040],'string','->','callback',...
        ['if str2num(get(e6,''string''))<npages,','set(e6,''string'',num2str(str2num(get(e6,''string''))+1)),','classrefresh,','end']);
    b12 = uicontrol(spkfig,'style','push','units','norm','pos',[.699 .462 .052 .040],'string','Redraw','callback',...
        ['classrefresh']);
    
    uicontrol(spkfig,'style','frame','units','norm','pos',[.013 .440 .104 .090])
    uicontrol(spkfig,'style','text','units','norm','pos',[.015 .486 .035 .030],'string','y-lim')
    uicontrol(spkfig,'style','text','units','norm','pos',[.015 .446 .035 .030],'string','x-lim')
    
    m16 = uimenu(spkfig,'label','Spike File...');
    uimenu(m16,'label','Open...','callback',['DATAFLAG=0;','RECOMPUTE=1;','OPNFLAG=1;','meska'])
    if USEDB,
        uimenu(m16,'label','Save','callback','savspk; matchcell2file;');
        uimenu(m16,'label','Save as...','callback',['SAVEAS=1;','savspk; matchcell2file;']);
    else
        uimenu(m16,'label','Save','callback','savspk;');
        uimenu(m16,'label','Save as...','callback',['SAVEAS=1;','savspk;']);
    end
    
    uimenu(m16,'label','Import...','callback','import0');
    uimenu(m16,'label','Presort...','callback','presort');
    m4 = uimenu(m16,'label','Quit','callback',...
        ['close all force,','clear,',...
            'delete(fullfile(pwd,''sorted'',''temp_*.mat'')),',...
            'disp(''You missed a spike'');']);
    
    m5 = uimenu(spkfig,'label','Data Movement...');
    m6 = uimenu(m5,'label','Add to class...                     cp =>','callback',['TO=1;','DEL=0;']);
    for i = 1:classtot,
        uimenu(m6,'label',num2str(i),'callback',['TO=1;','DEL=0;','cnm=' num2str(i) ';','spikeshuttle'])
    end
    m7 = uimenu(m5,'label','Delete and add to class...     mv =>','callback',['TO=1;','DEL=1;']);
    for i = 1:classtot,
        uimenu(m7,'label',num2str(i),'callback',['TO=1;','DEL=1;','cnm=' num2str(i) ';','spikeshuttle'])
    end
    m8 = uimenu(m5,'label','Add class...                         cp <=','callback',['FROM=1;','DEL=0;']);
    for i = 1:classtot,
        uimenu(m8,'label',num2str(i),'callback',['FROM=1;','DEL=0;','cnm=' num2str(i) ';','spikeshuttle'])
    end
    m9 = uimenu(m5,'label','Add and delete class...         mv <=','callback',['FROM=1;','DEL=1;']);
    for i = 1:classtot,
        uimenu(m9,'label',num2str(i),'callback',['FROM=1;','DEL=1;','cnm=' num2str(i) ';','spikeshuttle'])
    end
    m10 = uimenu(m5,'label','Remove class...','callback',['RMC=1;','RMW=0;']);
    for i = 1:classtot,
        uimenu(m10,'label',num2str(i),'callback',['RMC=1;','RMW=0;','cnm=' num2str(i) ';','spikeshuttle'])
    end
    m11 = uimenu(m5,'label','Remove from class...','callback',['RMW=1;','RMC=0;']);
    for i = 1:classtot,
        uimenu(m11,'label',num2str(i),'callback',['RMW=1;','RMC=0;','cnm=' num2str(i) ';','spikeshuttle'])
    end
    
    m12 = uimenu(spkfig,'label','Classes...');
    uimenu(m12,'label','Mean Waveforms','callback',['meanfig= figure,','if ONEFILE,','plotflag=0;','else,','plotflag=1;','end,',...
            'mean_meska(spiketemp, st, ts, spk, fname, direc, meanfig, plotflag),','if ~ONEFILE,','plotflag=2;',...
            'mean_meska(spiketemp2, st2, ts, spk, f2name, direc2, meanfig, plotflag),','end'])
    uimenu(m12,'label','Time Histograms','callback',['htemp = figure;','if ONEFILE,','plotflag=0;','else,','plotflag=1;','end,',...
            'TIME(playOrder(2,find(playOrder(1,:)==1)), sweeps, records, npoint, spk,fname, direc, htemp, plotflag,REGORDER1),',...
            'if ~ONEFILE,','plotflag=2;', 'TIME(playOrder2(2,find(playOrder2(1,:)==1)), sweeps2, records2, npoint2, spk,f2name, direc2, htemp, plotflag,REGORDER2),','end'])
    m13 = uimenu(m12,'label','Spike Raster...');
    m14 = uimenu(m13,'label','All','callback',['unit=0;','SEP=1,','TPLOT(path,direc,fname,meska_ROOT,st,spk,spiketemp,expData,torcList,unit,SEP,stonset,stdur,1),',...
            'if ~ONEFILE,','TPLOT(path2,direc2,f2name,meska_ROOT,st2,spk,spiketemp2,expData2,torcList2,unit,SEP,stonset2,stdur2,2),','end']);
    uimenu(m14,'label','Separate','callback',['unit=0;','SEP=1;','TPLOT(path,direc,fname,meska_ROOT,st,spk,spiketemp,expData,torcList,unit,SEP,stonset,stdur,1),',...
            'if ~ONEFILE,','TPLOT(path2,direc2,f2name,meska_ROOT,st2,spk,spiketemp2,expData2,torcList2,unit,SEP,stonset2,stdur2,2),','end'])
    uimenu(m14,'label','Superimposed','callback',['unit=0;','SEP=0;','TPLOT(path,direc,fname,meska_ROOT,st,spk,spiketemp,expData,torcList,unit,SEP,stonset,stdur,1),',...
            'if ~ONEFILE,','TPLOT(path2,direc2,f2name,meska_ROOT,st2,spk,spiketemp2,expData2,torcList2,unit,SEP,stonset2,stdur2,2),','end'])
    for i = 1:classtot,
        uimenu(m13,'label',num2str(i),'callback',['unit=' num2str(i) ';','SEP=0;','TPLOT(path,direc,fname,meska_ROOT,st,spk,spiketemp,expData,torcList,unit,SEP,stonset,stdur,1),',...
                'if ~ONEFILE,','TPLOT(path2,direc2,f2name,meska_ROOT,st2,spk,spiketemp2,expData2,torcList2,unit,SEP,stonset2,stdur2,2),','end'])
    end
    
    % PCA Menu
    m17pca = uimenu(m12,'label','PCA...');
    uimenu(m17pca,'label','File 1','callback',['spk_pca({spk{:,1}},spkraw,xaxis,fname);']);
    uimenu(m17pca,'label','File 2','callback',['spk_pca({spk{:,2}},spkraw2,xaxis,f2name);']);
    
    m15 = uimenu(m12,'label','ISI Histograms','callback',['isifig=figure,','if ONEFILE,','plotflag=0;','else,','plotflag=1;','end,',...
            'ISI(spk, npoint,rate, plotflag, isifig),','if ~ONEFILE,','plotflag=2;','ISI(spk, npoint2,rate2, plotflag, isifig),','end']);
    uimenu(m12,'label','STRFs','callback',['strffig=figure,','if ONEFILE,','plotflag=0;','else,','plotflag=1;','end,',...
            'strf_meska(path,direc,fname,meska_ROOT,spiketemp, spk,st, extras, plotflag, strffig, REGORDER1,xaxis);','if ~ONEFILE,','plotflag=2;',...
            'strf_meska(path2,direc2,f2name,meska_ROOT,spiketemp2, spk,st2, extras2, plotflag, strffig, REGORDER2,xaxis,fname,direc);','end']);
    %uimenu(m12,'label','Grand Analysis','callback',...
    %['unit=0;','SEP=1;','prepareclasses']);
    
    m1 = uimenu(spkfig,'label','Oops!');
    uimenu(m1,'label','Undo','callback','undo');
    % uimenu(m1,'label','Invert Waveform','callback',...
    % ['clear spiketemp st Ws Wt Ss St spiketemp2 st2 Ws2 Wt2 Ss2 St2,','RECOMPUTE=1;','spkraw(1:floor(end/2)) = -spkraw(1:floor(end/2));',...
    % 'spkraw(floor(end/2)+1:end) = -spkraw(floor(end/2)+1:end);','meska'])
    
    uimenu(m1,'label','Invert Waveform','callback','invertWvfm')
    uimenu(m1,'label','Refresh Workspace','callback',['saveundo,','REFRESH=1;','meska']);
    
    
    
    
    %%%%%%%%%% "Save" Window %%%%%%%%%%%%
    if ONEFILE, rep =1, else rep =maxfilenum, end
    
    savfig = figure;
    svp=[];svl =[];sve=[];svb=[];
    svp1=[400,325,350,200];
    svp2=[400,325,350,350];
    svlm(1:4,1:4)=  [.029, .800, .214, .150;.029, .600, .214, .150;.029 ,.400, .214, .150;.029, .200, .214, .150];
    svlm(5:8,1:4)=  [.029, .900, .214, .070;.029, .800, .214, .070;.029 ,.700, .214, .070;.029, .600, .214, .070];
    svlm(9:11,1:4)=[.029, .400, .214, .070;.029, .300, .214, .070;.029 ,.200, .214 .070];
    svem(1:4,1:4)=  [.354, .800, .571, .110;.354, .600, .571, .110;.354, .400 ,.571, .110;.354, .200, .571, .110];
    svem(5:8,1:4)=  [.354, .900, .571, .060;.354, .800, .571, .060;.354, .700 ,.571, .060;.354, .600, .571, .060];
    svem(9:11,1:4)= [.354, .400, .571, .060;.354, .300, .571, .060;.354, .200 ,.571, .060];
    svbm(1:4, 1:4) = [.029 .015 .060 .100; .100 .015 .300 .100; .786 .015 .120 .130; .614 .015 .120 .130];
    svbm(5:8, 1:4) = [.029 .005 .060 .060; .100 .005 .300 .060; .786 .005 .140 .080; .614 .005 .140 .080];
    svbm(9:12,1:4) = [.029 .500 .060 .060; .100 .500 .200 .060; .029 .100 .060 .060; .100 .100 .200 .060];
    
    
    
    if ONEFILE
        svp=svp1; svl=svlm(1:4,1:4); sve =svem(1:4,1:4); svb =svbm(1:4,1:4);
    else
        svp =svp2;svl=svlm(5:11,1:4); sve =svem(5:11,1:4);svb =svbm(5:12,1:4);
    end
    set(savfig,'WindowStyle','normal')
    set(savfig,'pos',[svp(1,1) svp(1,2) svp(1,3) svp(1,4)],'name','MESKA - Save','NumberTitle','off','visible','off');
    
    sl1= uicontrol(savfig,'style','text','units','norm','pos',[svl(1,1) svl(1,2) svl(1,3) svl(1,4)],'string',{'Sorter Name:'});
    sl2= uicontrol(savfig,'style','text','units','norm','pos',[svl(2,1) svl(2,2) svl(2,3) svl(2,4)],'string',{'File Name:'});
    sl3= uicontrol(savfig,'style','text','units','norm','pos',[svl(3,1) svl(3,2) svl(3,3) svl(3,4)],'string',{'Save In:'});
    sl4= uicontrol(savfig,'style','text','units','norm','pos',[svl(4,1) svl(4,2) svl(4,3) svl(4,4)],'string',{'EVP Path:'});
    
    stsort = uicontrol(savfig,'style','edit','units','norm','pos',[sve(1,1) sve(1,2) sve(1,3) sve(1,4)],'backgroundcolor',[1 1 1]);
    ste1 = uicontrol(savfig,'style','edit','units','norm','pos',[sve(2,1) sve(2,2) sve(2,3) sve(2,4)],'backgroundcolor',[1 1 1]);
    ste2 = uicontrol(savfig,'style','edit','units','norm','pos',[sve(3,1) sve(3,2) sve(3,3) sve(3,4)],'backgroundcolor',[1 1 1]);
    ste3 = uicontrol(savfig,'style','edit','units','norm','pos',[sve(4,1) sve(4,2) sve(4,3) sve(4,4)],'backgroundcolor',[1 1 1]);
    
    cs = uicontrol(savfig,'style','check','units','norm','pos',[svb(1,1) svb(1,2) svb(1,3) svb(1,4)],'value', 0 ,'callback',...
        ['if get(cs,''value''),','PSORTER=1;','else,','PSORTER =0;','end,']);
    uicontrol(savfig,'style','text','units','norm','pos',[svb(2,1) svb(2,2) svb(2,3) svb(2,4)],'string','Primary sorter')
    
    uicontrol(savfig,'style','push','units','norm','pos',[svb(3,1) svb(3,2) svb(3,3) svb(3,4)],'string','Save','callback',...
        ['set(savfig,''visible'',''off''),','drawnow,','RESUME=1;','uiresume(savfig)'])
    uicontrol(savfig,'style','push','units','norm','pos',[svb(4,1) svb(4,2) svb(4,3) svb(4,4)],'string','Cancel','callback',...
        ['DATAFLAG=1;','RECOMPUTE=0;','set(savfig,''visible'',''off''),','RESUME=0;','uiresume(savfig)'])
    
    if ~ONEFILE 
        cfirst = uicontrol(savfig,'style','check','units','norm','pos',[svb(5,1) svb(5,2) svb(5,3) svb(5,4)],'value', 1 ,'callback',...
            ['if get(cfirst,''value''),','FIRSTSAVED=1;','set(stsort,''visible'',''on''),',...
                'set(ste1,''visible'',''on''),','set(ste2,''visible'',''on''),','set(ste3,''visible'',''on''),',...
                'set(sl1,''visible'',''on''),','set(sl2,''visible'',''on''),','set(sl3,''visible'',''on''),',...
                'set(sl4,''visible'',''on''),','else,','FIRSTSAVED =0;','set(stsort,''visible'',''off''),',...
                'set(ste1,''visible'',''off''),','set(ste2,''visible'',''off''),','set(ste3,''visible'',''off''),',...
                'set(sl1,''visible'',''off''),','set(sl2,''visible'',''off''),','set(sl3,''visible'',''off''),','set(sl4,''visible'',''off''),','end,']);
        uicontrol(savfig,'style','text','units','norm','pos',[svb(6,1) svb(6,2) svb(6,3) svb(6,4)],'string','Save 1st file');
        
        sl5= uicontrol(savfig,'style','text','units','norm','pos',[svl(5,1) svl(5,2) svl(5,3) svl(5,4)],'string',{'File Name:'});
        sl6= uicontrol(savfig,'style','text','units','norm','pos',[svl(6,1) svl(6,2) svl(6,3) svl(6,4)],'string',{'Save In:'});
        sl7= uicontrol(savfig,'style','text','units','norm','pos',[svl(7,1) svl(7,2) svl(7,3) svl(7,4)],'string',{'EVP Path:'});
        
        ste4 = uicontrol(savfig,'style','edit','units','norm','pos',[sve(5,1) sve(5,2) sve(5,3) sve(5,4)],'backgroundcolor',[1 1 1]);
        ste5 = uicontrol(savfig,'style','edit','units','norm','pos',[sve(6,1) sve(6,2) sve(6,3) sve(6,4)],'backgroundcolor',[1 1 1]);
        ste6 = uicontrol(savfig,'style','edit','units','norm','pos',[sve(7,1) sve(7,2) sve(7,3) sve(7,4)],'backgroundcolor',[1 1 1]);
        
        csecond = uicontrol(savfig,'style','check','units','norm','pos',[svb(7,1) svb(7,2) svb(7,3) svb(7,4)],'value', 1 ,'callback',...
            ['if get(csecond,''value''),','SECONDSAVED=1;','set(ste4,''visible'',''on''),',...
                'set(ste5,''visible'',''on''),','set(ste6,''visible'',''on''),','set(sl5,''visible'',''on''),',...
                'set(sl6,''visible'',''on''),','set(sl7,''visible'',''on''),','else,','SECONDSAVED =0;','set(ste4,''visible'',''off''),',...
                'set(ste5,''visible'',''off''),','set(ste6,''visible'',''off''),','set(sl5,''visible'',''off''),',...
                'set(sl6,''visible'',''off''),','set(sl7,''visible'',''off''),','end,']);
        uicontrol(savfig,'style','text','units','norm','pos',[svb(8,1) svb(8,2) svb(8,3) svb(8,4)],'string','Save 2nd file')
    end
    
    
    set(savfig,'HandleVisibility','off')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    drawnow
    GUIINIT = 1;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('DATAFLAG'), DATAFLAG = 0; OPNFLAG=1; end
if ~DATAFLAG,
    %disp('~DATAFLAG');
    if OPNFLAG,
        if ~USEDB,
            [open_file1,open_file2,open_channel]=openGUI;
            if isempty(open_file2),
                ONEFILE=1;
            else
                ONEFILE=0;
            end
            if isempty(open_file1),
                % ie, don't try to open new files. user hit cancel.
                RESUME=0;
                RECOMPUTE=0;
            else
                RESUME=1;
                RECOMPUTE=1;
            end
            OPNFLAG=0;
        else
            RESUME=0;
            filedata=dbchooserawfile(0,'Choose first file to sort');
            
            if isempty(filedata),
                disp(' cancelled.');
                RESUME=0;
                RECOMPUTE=0;
            else
                RESUME=1;
                RECOMPUTE=1;
                rawid=filedata.rawid;
                siteid=filedata.siteid;
                open_file1=filedata.evpfile;
                spikefile1=filedata.spikefile;
                parmfile1=filedata.parmfile;
                open_channel=filedata.channel;
                fcount=1;
                
                filedata=dbchooserawfile(1,'Choose second file (or cancel)');

                if ~isempty(filedata),
                    tmplrawid=filedata.rawid;
                    open_file2=filedata.evpfile;
                    spikefile2=filedata.spikefile;
                    parmfile2=filedata.parmfile;
                    fcount=2;
                else
                    evpbase2='';evpdir2='';evppath2='';
                end
                RESUME=1;
                ONEFILE=(fcount==1);
            end
        end
        OPNFLAG=0;
    end
    
    if RESUME,
        drawnow;
        % used openGUI to specify input files
        if length(open_file1)>0,
            chanNum=num2str(open_channel);
            [fname,path]=basename(open_file1);
            if length(path)>0,
                path=path(1:(end-1));
                [direc,path]=basename(path);
            else
                direc='';
            end
            [f2name,path2]=basename(open_file2);
            if length(path2)>0,
                path2=path2(1:(end-1));
                [direc2,path2]=basename(path2);
            else
                direc2='';
            end
        end
        
        if ~exist('EXPERIMENT_DIR','var')
            global EXPERIMENT_DIR
        elseif isempty(whos('global','EXPERIMENT_DIR'))
            global EXPERIMENT_DIR
        end
        EXPERIMENT_DIR = [path direc];
        
        clear spkraw
        % check whether old or new format
        if strfind(fname,'.evp'),
            testfile = strrep(fname,'.evp','.m');
        else
            testfile = [fname,'.m'];
            fname = [fname,'.evp'];
        end

        % guessing parameter file (.m or .par)
        if exist(fullfile(path,direc,testfile),'file')
            % new format
            pbase = strrep(testfile,'.m','');
        else
            pbase = strrep(testfile,'.m','.par');
        end
        fprintf('guessing parmfile: %s\n',pbase);
        BaphyConfigPath; % for cellDB
        [spkraw, extras]=loadevp(fullfile(path,direc,pbase),fullfile(path,direc,fname),chanNum);
        
        torcList=extras.torcList;
        expData=extras.expData;
        sigma=extras.sigma;
        records=extras.records;
        npoint=extras.npoint;
        dataget=extras.dataget;
        spk1min=extras.spkmin;
        spk1max=extras.spkmax; 
        playOrder = extras.playOrder;
        sweeps = extras.sweeps;
        rate = extras.rate;
        stonset = extras.stonset;
        stdur = extras.stdur;
        
        if ~ONEFILE
            if ~exist('EXPERIMENT_DIR2','var')
                global EXPERIMENT_DIR2
            elseif isempty(whos('global','EXPERIMENT_DIR2')),
                global EXPERIMENT_DIR2
            end;
            EXPERIMENT_DIR2 = [path2 direc2];
            
            clear spkraw2
            % check whether old or new format
            if strfind(f2name,'.evp'),
                testfile = strrep(f2name,'.evp','.m');
            else
                testfile = [f2name,'.m'];
                f2name = [f2name,'.evp'];
            end

            % guessing parameter file (.m or .par)
            if exist(fullfile(path2,direc2,testfile),'file')
                % new format
                pbase = strrep(testfile,'.m','');
            else
                pbase = strrep(testfile,'.m','.par');
            end
            fprintf('guessing parmfile: %s\n',pbase);
            [spkraw2, extras2]=loadevp(fullfile(path2,direc2,pbase),fullfile(path2,direc2,f2name),chanNum);

            torcList2=extras2.torcList;
            expData2=extras2.expData;
            sigma2=extras2.sigma;
            records2=extras2.records;
            npoint2=extras2.npoint;
            dataget2=extras2.dataget;
            spk2min=extras2.spkmin;
            spk2max=extras2.spkmax;
            playOrder2 = extras2.playOrder;
            sweeps2 = extras2.sweeps;
            rate2 = extras2.rate;
            stonset2 = extras2.stonset;
            stdur2 = extras2.stdur;
            
            yaxis = 1.1*[min(spk1min,spk2min),max(spk1max,spk2max)];
            if yaxis(1)<-max(sigma,sigma2).*12,
                yaxis(1)=-max(sigma,sigma2).*12;
            end
            if yaxis(2)>max(sigma,sigma2).*12,
                yaxis(2)=max(sigma,sigma2).*12;
            end
        else
            yaxis = 1.1*[min(spkraw),max(spkraw)];   
            if yaxis(1)<-sigma.*12,
                yaxis(1)=-sigma.*12;
            end
            if yaxis(2)>sigma.*12,
                yaxis(2)=sigma.*12;
            end
        end
        
        xaxis = xaxisdef;
        
        if exist('e4','var'), if ishandle(e4), delete(e4), end, clear e4, end
        if exist('e5','var'), if ishandle(e5), delete(e5), end, clear e5, end
        e4 = uicontrol(spkfig,'style','edit','units','norm','pos',[.045 .484 .070 .040],'backgroundcolor',[1 1 1],...
            'string',['[',num2str(round(yaxis(1))),',',num2str(round(yaxis(2))),']'],'callback',...
            ['yaxis = str2num(get(e4,''string''));','spikeselect,','classrefresh']);
        e5 = uicontrol(spkfig,'style','edit','units','norm','pos',[.045 .444 .070 .040],'backgroundcolor',[1 1 1],...
            'string',['[',num2str(xaxis(1)),',',num2str(xaxis(2)),']'],'callback',...
            ['xaxis = str2num(get(e5,''string''));','meska,','classrefresh']);
        
        %save spkraw spkraw %memory
        DATAFLAG = 1;
        SAVED = 0;
        
        disp('inverting waveform by default!!!')
        invertWvfm;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if RECOMPUTE,
    
    %if exist('spkraw') ~= 1, load spkraw, end %memory
    
    spk = cell(classtot,2);
    %tem = zeros(xaxis(2)-xaxis(1)+1,classtot);
    
    spkraw(1) = 0;
    spkraw2(1) = 0;
    thr = str2num(get(e3,'string'))
    disp('Computing threshold crossings...')
    
    st = [];
    %Begin changes to open streaming files 04/21/2005 Serin Atiani
    if strcmpi(lower(torcList.type), 'complexaba') | ...
          strcmpi(lower(torcList.type),'streamAB') 
        REGORDER1=1;
        st= find(diff((spkraw > thr*sigma))>0);
    else
        REGORDER1=0;
        for rec = 1:records,
            st = [st; (rec-1)*dataget + find(diff((spkraw(dataget*(rec-1)+1:dataget*rec) > thr*sigma))>0)];
        end
        %st= find(diff((spkraw > thr*sigma))>0);
    end 
    % end changes
    if isempty(st), error('No spikes! from 1st file'), end
    ts = xaxis(1):xaxis(2); 
    spiketemp = spkraw(min(max((ts'*ones(1,length(st)))+(ones(length(ts),1)*st'),1),length(spkraw)));
    
    
    if ~ONEFILE
        st2 = [];
        %Begin changes to open streaming files 04/21/2005 Serin Atiani
        if strcmpi(lower(torcList2.type), 'complexaba') | ...
              strcmpi(lower(torcList.type),'streamAB')
           REGORDER2=1;
           st2= find(diff((spkraw2 > thr*sigma2))>0);
        else
           REGORDER2=0;
           for rec = 1:records2,
              st2 = [st2; (rec-1)*dataget2 + find(diff((spkraw2(dataget2*(rec-1)+1:dataget2*rec) > thr*sigma2))>0)];
           end
        end
        % end of changes
        if isempty(st2), error('No spikes! from 2nd file'), end
        spiketemp2 = spkraw2(min(max((ts'*ones(1,length(st2)))+(ones(length(ts),1)*st2'),1),length(spkraw2)));
        classrefresh 
    else
        classrefresh
    end
    
    nspk = str2num(get(e2,'string'));
    set(e6,'string','1') % reset page no.
    
end

if ~exist('spkraw'), error('1st file is not a valid EVP file'), end
if ~exist('spkraw2'), error('2nd file is not a valid EVP file'), end


if REFRESH | RECOMPUTE,
    
    Ws = spiketemp;
    Wt = st;
    St = Wt; Ss = Ws;
    hood = 0;
    
    if ~ONEFILE
        Ws2 = spiketemp2;
        Wt2 = st2;
        St2 = Wt2; Ss2 = Ws2;
        hood2=0
    end
    
    REFRESH = 0;
    RECOMPUTE = 0;
    
else,
    
    %if exist('spkraw') ~= 1, load spkraw, end %memory
    if isempty(xaxis), xaxis = xaxisdef; end
    if (sum(xaxis == get(h1,'xlim'))~=2) 
        ts = xaxis(1):xaxis(2); 
        spiketemp = spkraw(round(min(max((ts'*ones(1,length(st)))+(ones(length(ts),1)*st'),1),length(spkraw))));
        Ws = spiketemp(:,ismember(st,Wt));
        Ss = Ws(:,ismember(Wt,St));
        
        if ~ONEFILE
            spiketemp2 = spkraw2(min(max((ts'*ones(1,length(st2)))+(ones(length(ts),1)*st2'),1),length(spkraw2)));
            Ws2 = spiketemp2(:,ismember(st2,Wt2));
            Ss2 = Ws2(:,ismember(Wt2,St2));
        end
        saveundo
    end
    
end

%hood = 0;
%nspk = str2num(get(e2,'string'));

nstep = ceil(size(Ws,2)/nspk)-1;

if nstep, stepVec = [min(1/nstep,.51),min(5/nstep,1)]; else stepVec = [0 1]; end

%stepVec
sls=[];sll=[];
slstemp (1:3, 1:4) =[.330, .118, .087, .040;.330, .508, .087, .040;.330, .078, .087, .040];
slltemp(1:6,1:4) =[.291, .120, .039, .040;.417, .120, .039, .040;.291, .508, .039, .040; .417, .508, .039, .040;.291, .078, .039, .040;.417, .078, .039, .040];
if ONEFILE 
    sls(1,1:4)=slstemp(1,1:4);
    sll(1:2,1:4) =slltemp(1:2,1:4)
else
    sls(1:2,1:4) =slstemp(2:3,1:4)
    sll(1:4,1:4) =slltemp(3:6,1:4)
end

if exist('s1'), if ishandle(s1), delete(s1), end, clear s1, end
if size(Ws,2),
    s1 = uicontrol(spkfig,'style','slider','units','norm','pos',[sls(1,1) sls(1,2) sls(1,3) sls(1,4)],'min',1,'max',nspk*(ceil(size(Ws,2)/nspk)-1)+1,...
        'SliderStep',stepVec,'value',hood+1,'callback',['hood=round((get(s1,''value'')-1)/nspk)*nspk;',...
            'set(s1,''value'',hood+1),','spikeselect']);
end
if ~ONEFILE
    nstep2 = ceil(size(Ws2,2)/nspk)-1;
    if nstep2, stepVec2 = [min(1/nstep2,.51),min(5/nstep2,1)]; else stepVec2 = [0 1]; end
    if exist('s2'), if ishandle(s2), delete(s2), end, clear s2, end
    if size(Ws2,2),
        s12 = uicontrol(spkfig,'style','slider','units','norm','pos',[sls(2,1) sls(2,2) sls(2,3) sls(2,4)],'min',1,'max',nspk*(ceil(size(Ws2,2)/nspk)-1)+1,...
            'SliderStep',stepVec2,'value',hood2+1,'callback',['hood2=round((get(s12,''value'')-1)/nspk)*nspk;',...
                'set(s12,''value'',hood2+1),','spikeselect']);
    end
    uicontrol(spkfig,'style','text','units','norm','pos',[sll(3,1) sll(3,2) sll(3,3) sll(3,4)],'string',num2str(min(size(Ws2,2),1)));
    uicontrol(spkfig,'style','text','units','norm','pos',[sll(4,1) sll(4,2) sll(4,3) sll(4,4)],'string',num2str(size(Ws2,2)));
end

uicontrol(spkfig,'style','text','units','norm','pos',[sll(1,1) sll(1,2) sll(1,3) sll(1,4)],'string',num2str(min(size(Ws,2),1)));
uicontrol(spkfig,'style','text','units','norm','pos',[sll(2,1) sll(2,2) sll(2,3) sll(2,4)],'string',num2str(size(Ws,2)));

figure(spkfig)
spikeselect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
