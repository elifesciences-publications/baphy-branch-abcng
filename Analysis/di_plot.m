function [di,rawid,dayN,s2]=di_plot(animal,runclass,stat2,training_flag);
    
    if ~exist('stat2','var'),
        stat2=[];
    end
    if ~exist('training_flag','var') || isempty(training_flag),
        training_flag=-1;
    end
    mintrials=25;
    
    dbopen;
    if isempty(stat2),
        sql=['SELECT gDataRaw.*,gData.value as DI,0 as stat2,"" as sstat2',...
             'gPenetration.pendate',...
             ' FROM gDataRaw INNER JOIN gData',...
             ' ON gDataRaw.id=gData.rawid',...
             ' AND gData.name="DiscriminationIndex"'];
    else
        sql=['SELECT gDataRaw.*,gData.value as DI,d2.value as stat2,d2.svalue as sstat2,',...
             'gPenetration.pendate',...
             ' FROM gDataRaw INNER JOIN gData',...
             ' ON gDataRaw.id=gData.rawid',...
             ' AND gData.name="DiscriminationIndex"',...
             ' INNER JOIN gData d2',...
             ' ON gDataRaw.id=d2.rawid',...
             ' AND d2.name="',stat2,'"'];
    end
    sql=[sql,' INNER JOIN gCellMaster ON gDataRaw.masterid=gCellMaster.id',...
         ' INNER JOIN gPenetration ON gPenetration.id=gCellMaster.penid',...
         ' WHERE gPenetration.animal like "',animal,'"',...
         ' AND not(gDataRaw.bad)',...
         ' AND gDataRaw.trials>',num2str(mintrials),...
         ' AND gDataRaw.runclass like "',runclass,'"'];
    
    if ismember(training_flag,[0 1]),
        sql=[sql ' AND gDataRaw.training=',num2str(training_flag)];
    end
    sql=[sql,' ORDER BY gDataRaw.id'];
    
    didata=mysql(sql);
    for ii=1:length(didata),
        if isempty(didata(ii).stat2),
            didata(ii).stat2=mean(str2num(didata(ii).sstat2));
        end
    end
    
    rawid=cat(1,didata.masterid);
    di=cat(1,didata.DI);
    s2=cat(1,didata.stat2);
    s2(s2<0)=0;
    
    dayN=zeros(size(di));
    masterid=cat(1,didata.masterid);
    umasterid=unique(masterid);
    di_day=zeros(size(umasterid));
    s2_day=zeros(size(umasterid));
    for ii=1:length(umasterid);
        ff=find(masterid==umasterid(ii));
        di_day(ii)=nanmean(di(ff));
        s2_day(ii)=nanmean(s2(ff));
        dayN(ff)=ii;
    end
    
    figure;
    if isempty(stat2),
        subplot(2,1,1);
        plot(di);
        hold on
        plot([0 length(di)],[50 50],'k--');
        hold off
        hl=legend('DI');
        xlabel('session');
        title(sprintf('%s - %s (DI)',animal,runclass));
        
        subplot(2,1,2);
        plot(di_day);
        hold on
        plot([0 length(di_day)],[50 50],'k--');
        hold off
        xlabel('day');
    else
        s2name=strsep(stat2,'_');
        s2name=s2name{end};
        subplot(2,1,1);
        plot([di s2]);
        hold on
        plot([0 length(di)],[50 50],'k--');
        hold off
        hl=legend('DI',s2name);
        xlabel('session');
        title(sprintf('%s - %s (DI + %s)',animal,runclass,s2name));
        
        subplot(2,1,2);
        plot([di_day s2_day]);
        hold on
        plot([0 length(di_day)],[50 50],'k--');
        hold off
        xlabel('day');
    end
    
    return
    
   
    
    if 0,
        animal='portabello';
        runclass='ptd';
        training_flag=1;
        mintrials=5;
        
        sql=['SELECT gDataRaw.*,gData.value as DI,0 as stat2,',...
             'gPenetration.pendate',...
             ' FROM gDataRaw LEFT JOIN gData',...
             ' ON gDataRaw.id=gData.rawid',...
             ' AND gData.name="DiscriminationIndex"',...
             ' INNER JOIN gCellMaster ON gDataRaw.masterid=gCellMaster.id',...
             ' INNER JOIN gPenetration ON gPenetration.id=gCellMaster.penid',...
             ' WHERE gPenetration.animal like "',animal,'"',...
             ' AND not(gDataRaw.bad)',...
             ' AND gDataRaw.behavior="active"',...
             ' AND gDataRaw.trials>',num2str(mintrials),...
             ' AND gDataRaw.runclass like "',runclass,'"'];
        
        if ismember(training_flag,[0 1]),
            sql=[sql ' AND gDataRaw.training=',num2str(training_flag)];
        end
        sql=[sql,' ORDER BY gDataRaw.id'];
    
        didata=mysql(sql);
        for ii=1:length(didata),
            if isempty(didata(ii).DI),
                close all
                drawnow
                fprintf('(%d/%d): calcing DI for %s\n',...
                        ii,length(didata),didata(ii).parmfile);
                replicate_behavior_analysis(...
                    [didata(ii).resppath didata(ii).parmfile],1);
            end
        end
        
    end
    