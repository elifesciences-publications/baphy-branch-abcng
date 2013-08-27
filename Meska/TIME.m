function TIME(playorder, sweeps, records, npoint, spk,fname, direc, htemp, plotflag,orderflag)

for i = 1:length(spk), classvec(i) = ~isempty(spk{i,1}) | ~isempty(spk{i,2}); end
classvec = find(classvec);
numclass = length(classvec);
set(htemp,'Name',['JUSTIN - Temporal Distribution'],'NumberTitle','off')
title('Spike time distribution')
set(htemp,'pos',[400 115 500 750])

%%%% uicontrols
binstep = 5;

binplotscript = ['stime = get(gcf,''userdata'');','binnum = str2num(get(str2num(get(gcf,''tag'')),''string''));',...
    'for abc = 1:numclass,','switch plotflag,','case 1,','subplot(numclass,2,abc*2-1),','hist(stime{abc,plotflag},binnum),',...
    'ylabel(abc),','set(gca,''xtick'',[]),','axis tight,','subplot(numclass,2,1),','title([direc,''\_'',fname]),',...
    'subplot(numclass,2,numclass*2-1),','xlabel(''Experiment time -->''),','case 2,','subplot(numclass,2,abc*2),',...
    'hist(stime{abc,plotflag},binnum),','ylabel(abc),','set(gca,''xtick'',[]),','axis tight,','subplot(numclass,2,2),',...
    'title([direc,''\_'',fname]),','subplot(numclass,2,numclass*2),','xlabel(''Experiment time -->''),','case 0,',...
    'subplot(numclass,plotf,abc),','hist(stime{abc,plotf},binnum),','ylabel(abc),','set(gca,''xtick'',[]),','axis tight,',...
    'subplot(numclass,plotf,1),','title([direc,''\_'',fname]),','subplot(numclass,plotf,numclass),','xlabel(''Experiment time -->''),',...
    'end,','end,'];

%,'case 0,','subplot(numclass,1,abc),','hist(stime{abc,1},binnum),',...
%     'ylabel(abc),','set(gca,''xtick'',[]),','axis tight,','subplot(numclass,1,1),','title([direc,''\_'',fname]),',...
%     'subplot(numclass,1,numclass),','xlabel(''Experiment time -->''),'

% binplotscript = ['stime = get(gcf,''userdata'');','binnum = str2num(get(str2num(get(gcf,''tag'')),''string''));',...
%     'for abc = 1:numclass,','switch plotflag,','case 1,','subplot(numclass,plotf,abc*2-1),','hist(stime{abc,plotflag},binnum),',...
%     'ylabel(abc),','set(gca,''xtick'',[]),','axis tight,','subplot(numclass,plotf,1),','title([direc,''\_'',fname]),',...
%     'subplot(numclass,plotf,numclass*2-1),','xlabel(''Experiment time -->''),','case 2,','subplot(numclass,plotf,abc*2),',...
%     'hist(stime{abc,plotflag},binnum),','ylabel(abc),','set(gca,''xtick'',[]),','axis tight,','subplot(numclass,plotf,2),',...
%     'title([direc,''\_'',fname]),','subplot(numclass,plotf,numclass*2),','xlabel(''Experiment time -->''),','case 0,',...
%     'subplot(numclass,plotf,abc),','hist(stime{abc,plotf},binnum),','ylabel(abc),','set(gca,''xtick'',[]),','axis tight,',...
%     'subplot(numclass,plotf,1),','title([direc,''\_'',fname]),','subplot(numclass,plotf,numclass),','xlabel(''Experiment time -->''),',...
%     'end,','end,'];
% binplotscript = ['stime = get(gcf,''userdata'');','binnum = str2num(get(str2num(get(gcf,''tag'')),''string''));',...
% 'for abc = 1:numclass,','subplot(numclass,2,abc*2-1),','hist(stime{abc,1},binnum),',...
% 'ylabel(abc),','set(gca,''xtick'',[]),','axis tight,',...
% 'subplot(numclass,2,abc*2),','hist(stime{abc,2},binnum),',...
% 'ylabel(abc),','set(gca,''xtick'',[]),','axis tight,','end,',...
% 'subplot(numclass,2,1),','title([direc,''\_'',fname]),','subplot(numclass,2,2),','title([direc,''\_'',fname]),',...
% 'subplot(numclass,2,numclass*2-1),','xlabel(''Experiment time -->''),',...
% 'subplot(numclass,2,numclass*2),','xlabel(''Experiment time -->''),'];

uicontrol(htemp,'style','frame','units','norm','pos',[.003 .945 .157 .052],'backgroundcolor',[.7 .7 .7])
uicontrol(htemp,'style','text','units','norm','pos',[.033 .974 .100 .020],'string','# Bins')
uicontrol(htemp,'style','push','units','norm','pos',[.006 .948 .05 .025],'string',['-' num2str(binstep)],'callback',...
['if str2num(get(str2num(get(gcf,''tag'')),''string''))>binstep,','set(str2num(get(gcf,''tag'')),''string'',num2str(str2num(get(str2num(get(gcf,''tag'')),''string''))-binstep)),',binplotscript,'end']);
etemp=uicontrol(htemp,'style','edit','units','norm','pos',[.056 .948 .05 .025],'backgroundcolor',[1 1 1],'string','60','callback',...
[binplotscript]);
set(htemp,'tag',num2str(etemp,100))
uicontrol(htemp,'style','push','units','norm','pos',[.106 .948 .05 .025],'string',['+' num2str(binstep)],'callback',...
['if str2num(get(str2num(get(gcf,''tag'')),''string''))<datatotal,','set(str2num(get(gcf,''tag'')),''string'',num2str(str2num(get(str2num(get(gcf,''tag'')),''string''))+binstep)),',binplotscript,'end']);

uicontrol(htemp,'style','push','units','norm','pos',[.163 .971 .157 .026],'string','Correlations','callback',...
['clear temp,','stime = get(gcf,''userdata'');','binnum = str2num(get(str2num(get(gcf,''tag'')),''string''));',...
'for abc = 1:classtot,','temp(abc,:)=hist(stime{abc},binnum);','end,','figure,','corrmat=corrcoef(temp'');','corrmat(find(isnan(corrmat)))=0,',...
'imagesc(corrmat,[-1 1]),','set(gca,''xtick'',1:classtot),','set(gca,''ytick'',1:classtot),','grid,',...
'colorbar,','title(''Temporal Distribution Correlations''),','xlabel(''Class #''),','ylabel(''Class #'')'])
%%%%
drawnow
if plotflag ==0
    plotf=1;
else
    plotf=plotflag;
end
classtot =length(spk);
stime = cell(classtot,2);

tempp1 = playorder(1:sweeps*records)'.*sweeps + reshape((ones(records,1)*(1:sweeps)),sweeps*records,1);%constrained the playorder to the number of repetitions and records
[dummy1,tempp1] = sort(tempp1);
if orderflag
    ordermult= [];
    for i = 1:records
        if i == 1
            ordermult(i)= npoint(playorder(i));
        else
            ordermult(i)= npoint(playorder(i))+ordermult(i-1);
        end
    end
    %tempp1= (tempp1-(1:sweeps*records)');
    tempp1= (tempp1-1);
    tempp1= ordermult((mod(tempp1,records)+(~mod(tempp1,records)*records)))'+ (ordermult(records)*(ceil(tempp1/records)-1));
%     tempp1(1:records)= ordermult(mod(tempp1(1:records),(records)))+ (ordermult(records)*floor(tempp1(1:records)/records));
%     tempp1(records+1:end)= ordermult((mod(tempp1(records+1:end),(records+1)+1)))+ (ordermult(records)*floor(tempp1(records+1:end)/records));
%     tempp1= (tempp1-(1:sweeps*records)').* ordermult()reshape(((npoint'*ones(1,sweeps)))',sweeps*records,1);

else
   tempp1 = (tempp1 - (1:sweeps*records)') * npoint;
end

for abc = 1:classtot,
    if plotflag==0
        if orderflag 
            for a= 1:length(npoint)
                spkpoints(a)= sum(npoint(1:a)*sweeps);
            end
             spkindx=[];
            for a = 1:length(spkpoints)
                if a==1
                    spkindx= [spkindx;ceil(spk{abc,1}(find(spk{abc,1}<=spkpoints(a)))/npoint(a))];%(ceil(spk{abc,1}(find(spk{abc,1}<=spkpoints(a)))/npoint(a)))];
                else
                    spkindx= [spkindx;sweeps*(a-1)+ceil((spk{abc,1}(find(spk{abc,1}>spkpoints(a-1) & spk{abc,1}<=spkpoints(a)))-spkpoints(a-1))/npoint(a))];%((sweeps*(a-1))+ceil((spk{abc,1}(find(spk{abc,1}<=spkpoints(a) & spk{abc,1}>spkpoints(a-1)))-spkpoints(a-1))/npoint(a)))];
                end
                
            end
            stime{abc,1} = sort(spk{abc,1}-((spkpoints(max(ceil(spkindx/sweeps)-1,1)).*min(ceil(spkindx/sweeps)-1,1)')'+(npoint(ceil(spkindx/sweeps))'.*(mod(spkindx,sweeps)+(~mod(spkindx,sweeps)*sweeps)-1))) + tempp1(spkindx));
            %stime{abc,1} = sort(spk{abc,1} + tempp1(spkindx));
            %stime(abc,1)= sort(spk{abc,1} + tempp1(ceil(spk{abc,1}./(reshape(((npoint'*ones(1,sweeps)))',sweeps*records,1)))));
        else
            stime{abc,1} = sort(spk{abc,1} + tempp1(ceil(spk{abc,1}/npoint)));
        end
    else
        if orderflag
            %stime(abc,plotflag) = sort(spk{abc,plotflag} + tempp1(ceil(spk{abc,plotflag}./(reshape((npoint'*ones(1,sweeps)),sweeps*records,1))))); 
%            spkpoints= npoint*sweeps;
            for a= 1:length(npoint)
                spkpoints(a)= sum(npoint(1:a)*sweeps);
            end
             spkindx=[];
            for a = 1:length(spkpoints)
                if a==1
                    spkindx= [spkindx;ceil(spk{abc,plotflag}(find(spk{abc,plotflag}<=spkpoints(a)))/npoint(a))];%(ceil(spk{abc,plotflag}(find(spk{abc,plotflag}<=spkpoints(a)))/npoint(a)))];
                else
                    spkindx= [spkindx;sweeps*(a-1)+ceil((spk{abc,plotflag}(find(spk{abc,plotflag}>spkpoints(a-1) & spk{abc,plotflag}<=spkpoints(a)))-spkpoints(a-1))/npoint(a))];%((sweeps*(a-1))+ceil((spk{abc,plotflag}(find(spk{abc,plotflag}<=spkpoints(a) & spk{abc,plotflag}>spkpoints(a-1)))-spkpoints(a-1))/npoint(a)))];
                end
                
            end     
%             spkindx=[];
%             for j = 1:length(spkpoints)
%                 if j==1
%                     spkindx= [spkindx;(ceil(spk{abc,plotflag}(find(spk{abc,plotflag}<=spkpoints(j)))/npoint(j)))];
%                 else
%                     spkindx= [spkindx;((sweeps*(j-1))+ceil((spk{abc,plotflag}(find(spk{abc,plotflag}<=spkpoints(j) & spk{abc,plotflag}>spkpoints(j-1)))-spkpoints(j-1))/(npoint(j)*sweeps)))];
%                 end
%                 %(sweeps*(j-1))+
%             end                   
%             stime{abc,plotflag}(1:sweeps) = sort(spk{abc,plotflag}(1:sweeps) -((spkpoints(floor(spkindx(1:sweeps)/sweeps))+npoint(floor(spkindx(1:sweeps)/sweeps)))*(mod(spkindx(1:sweeps),sweeps+1))) + tempp1(spkindx));
%             stime{abc,plotflag}(sweeps+1:end) = sort(spk{abc,plotflag}(sweeps+1:end)-((spkpoints(floor(spkindx(sweeps+1:end)/sweeps))+npoint(floor(spkindx(sweeps+1:end)/sweeps)))*(mod(spkindx(sweeps+1:end),sweeps+1)+1)) + tempp1(spkindx));
            stime{abc,plotflag} = sort(spk{abc,plotflag}-((spkpoints(max(ceil(spkindx/sweeps)-1,1)).*min(ceil(spkindx/sweeps)-1,1)')'+(npoint(ceil(spkindx/sweeps))'.*(mod(spkindx,sweeps)+(~mod(spkindx,sweeps)*sweeps)-1))) + tempp1(spkindx));
        else
            stime{abc,plotflag} = sort(spk{abc,plotflag} + tempp1(ceil(spk{abc,plotflag}/npoint))); 
        end
   end
end

clear tempp1 dummy1 

set(htemp,'userdata',stime), clear stime
eval(binplotscript)

