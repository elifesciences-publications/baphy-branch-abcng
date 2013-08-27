
disp('Preparing data...')
for i = 1:length(spk), classvec(i) = ~isempty(spk{i,1}) | ~isempty(spk{i,2}); end
classvec = find(classvec);
numclass = length(classvec);
sorter = 'temp';
com= [];
sflag = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if MEAN,
% 
% clear tem tem2
% for abc = 1:classtot,
%  temps = spiketemp(:,find(ismember(st,spk{abc,1})));
%  temps2 = spiketemp2(:,find(ismember(st2,spk{abc,2})));
%  % tempst=[temps';temps2']';
%  if ~isempty(temps) | ~isempty(temps2),
%    tem(:,abc) = mean(temps,2);
%    tem2(:,abc) = mean(temps2,2);
%  else
%    tem(:,abc) = zeros(length(ts),1);
%    tem2(:,abc) = zeros(length(ts),1);
%  end
% end
% 
% figure
% set(gcf,'Name','JUSTIN - Combined Mean Waveforms ','NumberTitle','off')
% title('Combined Mean waveform for each class')
% subplot(2,1,1)
% plot(ts,tem)
% grid on
% legend(num2str((1:numclass)'))
% %hold on
% subplot(2,1,2)
% plot (ts,tem2)
% suptitle([direc,'\_',fname,'   ',direc2,'\_',f2name])
% grid on
% legend(num2str((1:numclass)'))
% 
% clear temps temps2
% MEAN=0;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% if TIME,
% 
% htemp = figure;
% set(htemp,'Name',['JUSTIN - Temporal Distribution'],'NumberTitle','off')
% title('Spike time distribution')
% set(htemp,'pos',[400 115 500 750])
% 
% %%%% uicontrols
% binstep = 5;
% binplotscript = ['stime = get(gcf,''userdata'');','binnum = str2num(get(str2num(get(gcf,''tag'')),''string''));',...
% 'for abc = 1:numclass,','subplot(numclass,2,abc*2-1),','hist(stime{abc,1},binnum),',...
% 'ylabel(abc),','set(gca,''xtick'',[]),','axis tight,',...
% 'subplot(numclass,2,abc*2),','hist(stime{abc,2},binnum),',...
% 'ylabel(abc),','set(gca,''xtick'',[]),','axis tight,','end,',...
% 'subplot(numclass,2,1),','title([direc,''\_'',fname]),','subplot(numclass,2,2),','title([direc,''\_'',fname]),',...
% 'subplot(numclass,2,numclass*2-1),','xlabel(''Experiment time -->''),',...
% 'subplot(numclass,2,numclass*2),','xlabel(''Experiment time -->''),'];
% 
% uicontrol(htemp,'style','frame','units','norm','pos',[.003 .945 .157 .052],'backgroundcolor',[.7 .7 .7])
% uicontrol(htemp,'style','text','units','norm','pos',[.033 .974 .100 .020],'string','# Bins')
% uicontrol(htemp,'style','push','units','norm','pos',[.006 .948 .05 .025],'string',['-' num2str(binstep)],'callback',...
% ['if str2num(get(str2num(get(gcf,''tag'')),''string''))>binstep,','set(str2num(get(gcf,''tag'')),''string'',num2str(str2num(get(str2num(get(gcf,''tag'')),''string''))-binstep)),',binplotscript,'end']);
% etemp=uicontrol(htemp,'style','edit','units','norm','pos',[.056 .948 .05 .025],'backgroundcolor',[1 1 1],'string','20','callback',...
% [binplotscript]);
% set(htemp,'tag',num2str(etemp,100))
% uicontrol(htemp,'style','push','units','norm','pos',[.106 .948 .05 .025],'string',['+' num2str(binstep)],'callback',...
% ['if str2num(get(str2num(get(gcf,''tag'')),''string''))<datatotal,','set(str2num(get(gcf,''tag'')),''string'',num2str(str2num(get(str2num(get(gcf,''tag'')),''string''))+binstep)),',binplotscript,'end']);
% 
% uicontrol(htemp,'style','push','units','norm','pos',[.163 .971 .157 .026],'string','Correlations','callback',...
% ['clear temp,','stime = get(gcf,''userdata'');','binnum = str2num(get(str2num(get(gcf,''tag'')),''string''));',...
% 'for abc = 1:classtot,','temp(abc,:)=hist(stime{abc},binnum);','end,','figure,','corrmat=corrcoef(temp'');','corrmat(find(isnan(corrmat)))=0,',...
% 'imagesc(corrmat,[-1 1]),','set(gca,''xtick'',1:classtot),','set(gca,''ytick'',1:classtot),','grid,',...
% 'colorbar,','title(''Temporal Distribution Correlations''),','xlabel(''Class #''),','ylabel(''Class #'')'])
% %%%%
% drawnow
% 
% 
% 
% stime = cell(classtot,2);
% tempp1 = reshape(((sweeps*playOrder(1,1:30)')*ones(1,sweeps)) + (ones(records,1)*(1:sweeps)),sweeps*records,1);
% tempp2 = reshape(((sweeps2*playOrder2(1,1:30)')*ones(1,sweeps2)) + (ones(records2,1)*(1:sweeps2)),sweeps2*records2,1);
% [dummy1,tempp1] = sort(tempp1);
% [dummy2,tempp2] = sort(tempp2);
% 
% tempp1 = (tempp1 - (1:sweeps*records)') * npoint;
% tempp2 = (tempp2 - (1:sweeps2*records2)') * npoint2;
% 
% for abc = 1:classtot,
% stime{abc,1} = sort(spk{abc,1} + tempp1(ceil(spk{abc,1}/npoint)));
% stime{abc,2} = sort(spk{abc,2} + tempp2(ceil(spk{abc,2}/npoint2)));
% end
% 
% clear tempp1 tempp2 dummy1 dummy2
% 
% set(htemp,'userdata',stime), clear stime
% eval(binplotscript)
% 
% TIME=0;
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TPLOT,

source = fullfile(path,direc,fname)
source2 = fullfile(path2,direc2,f2name)

%if strcmp(computer,'SOL2'),
	%destin = fullfile('/homes/daqsc/matlab/justin/sorted',['temp_' fname])
%elseif strmatch('GLNX',computer),
	%destin = fullfile('/home/djklein/matlab/justin/sorted',['temp_' fname])
%elseif strcmp(computer,'MAC2'),
	%destin = fullfile(pwd,'sorted',['temp_' fname])
%end
destin = [JUSTIN_ROOT filesep 'sorted'];
if ~exist(destin)
    mkdir(destin);
end;
spksv1 =cell(length(spk),1)
spksv2 =cell(length(spk),1)

for i= 1:length(spk)
    spksv1{i}=spk{i,1}
    spksv2{i}=spk{i,2}
end
destin2 = [destin filesep 'temp_' f2name];    
destin = [destin filesep 'temp_' fname];
savespikes(source,destin,st,spiketemp,spksv1,sorter,sflag,com,expData, torcList, xaxis);
fnamespikes = [destin '.spk'];


savespikes(source2,destin2,st2,spiketemp2,spksv2,sorter,sflag,com,expData2, torcList2, xaxis);
fnamespikes2 = [destin '.spk'];



if ~unit,
 if SEP, unit = 1:numclass;
 else,
   for u = 1:numclass,
    spdata(:,:,:,u) = getspikes(fnamespikes,u,expData,torcList);
    spdata2(:,:,:,u) = getspikes(fnamespikes2,u,expData2, torcList2);
   end
   figure; spikeplot(spdata,1,fnamespikes); 
   set(gcf,'Name',['JUSTIN - Spike Raster : ',direc,'_',fname],'NumberTitle','off')
   figure; spikeplot(spdata,1,fnamespikes); 
   set(gcf,'Name',['JUSTIN - Spike Raster : ',direc,'_',fname],'NumberTitle','off')
 end 
else
 unit = find(classvec==unit); 
end

if unit,
 for u = unit,
  spdata = getspikes(fnamespikes,u,expData,torcList);
  spdata2 = getspikes(fnamespikes2,u,expData2,torcList2);
  figure; spikeplot(spdata,1,fnamespikes,[],expData,[stonset stdur]);
  set(gcf,'Name',['JUSTIN - Spike Raster : ',direc,'_',fname,' Unit ',num2str(u)],'NumberTitle','off')
  figure; spikeplot(spdata2,1,fnamespikes2,[],expData2,[stonset2 stdur2]);
  set(gcf,'Name',['JUSTIN - Spike Raster : ',direc2,'_',f2name,' Unit ',num2str(u)],'NumberTitle','off')
 end
end
   
%clear spdata
TPLOT = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if ISI,
% 
% maxint = 50; % ms
% binsize = 0.5; %ms
% numbins = maxint/binsize;
% 
% figure, 
% set(gcf,'Name',['JUSTIN - ISI'],'NumberTitle','off')
% isi = zeros(numbins,numclass); isi2 =zeros(numbins,numclass);
% for u = 1:numclass,
%  tempi1 = spk{classvec(u),1};
%  tempi2 = spk{classvec(u),2};
%  tempi1 = tempi1(:);
%  tempi2 = tempi2(:);
%  bnd = [0;find(diff(ceil(tempi1/npoint)));length(tempi1)];
%  bnd2 = [0;find(diff(ceil(tempi2/npoint2)));length(tempi2)];
%  isis = []; isis2=[];
%  for abc = 1:length(bnd)-1,
%   data = tempi1(bnd(abc)+1:bnd(abc+1));
%   isis = [isis; ceil(diff(data)/binsize*1000/rate)];
%  end
%  
%  for abc = 1:length(bnd2)-1,
%   data2 = tempi2(bnd2(abc)+1:bnd2(abc+1));
%   isis2 = [isis2; ceil(diff(data2)/binsize*1000/rate2)];
%  end
%  
%  for abc = 1:numbins,
%   isi(abc,u) = length(find(isis==abc));
%   isi2(abc,u) = length(find(isis2==abc));
%  end
% 
%  subplot(numclass,2,classvec(u)*2-1)
%  bar((1:numbins)*binsize,isi(:,u)) 
%  title(['Class ' num2str(classvec(u))])
%  axis tight
%  
%  subplot(numclass,2,classvec(u)*2)
%  bar((1:numbins)*binsize,isi2(:,u)) 
%  title(['Class ' num2str(classvec(u))])
%  axis tight
%  
% 
% end 
% 
% xlabel('Interval (ms)')
% clear tempi1 tempi2 ;
% 
% ISI = 0;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if STRF,
% 
% source = fullfile(path,direc,fname)
% source2= fullfile(path2,direc2,f2name)
% %if strcmp(computer,'SOL2'), % This stuff will be changed eventually
% %	 savpath = '/homes/daqsc/matlab/justin/sorted';
% % elseif strmatch('GLNX',computer),
% %	savpath = '/home/djklein/matlab/justin/sorted';
% % elseif strcmp(computer,'MAC2'),
% %	 savpath = fullfile(pwd,'sorted');
% % end
% savpath = [JUSTIN_ROOT filesep 'sorted'];
% if ~exist(savpath,'dir')
%    mkdir(savpath);
% end; 
%  destin = fullfile(savpath,['temp_' fname])  % Its only temporary
%  savespikes(source,destin,st,spiketemp,spk(:,1),sorter,sflag,com, expData, torcList);
%  fnamespikes = [destin '.spk'];
% 
%  destin2 = fullfile(savpath,['temp_' f2name])  % Its only temporary
%  savespikes(source2,destin2,st2,spiketemp2,spk(:,2),sorter,sflag,com, expData2, torcList2);
%  f2namespikes = [destin2 '.spk'];
%  
% 
%  stimparam  = readinfo(torcList)
%  stimparam2 = readinfo(torcList2)
% %   inffile = getfieldstr(paramdata,'inf_file');
% %   [wfmTotal,a1s_freqs,a1infodata,speechwfm]=geta1info([path direc '/' inffile]);
% %   a1am = get(torcList,'Ripple amplitudes');
% %   a1rf = get(torcList,'Ripple frequencies');
% %   a1ph = get(torcList,'Ripple phase shifts');
% %   a1rv = get(torcList,'Angular frequencies');
%  
% %   inffile2 = getfieldstr(paramdata2,'inf_file');
% %   [wfmTotal2,a1s_freqs2,a1infodata2,speechwfm2]=geta1info([path2 direc2 '/' inffile2]);
% %   a1am2 = get(torcList2,'Ripple amplitudes');
% %   a1rf2 = get(torcList2,'Ripple frequencies');
% %   a1ph2 = get(torcList2,'Ripple phase shifts');
% %   a1rv2 = get(torcList2,'Angular frequencies');
%  
%   
%  [waveParams,W,Omega,nrips] = makewaveparams(stimparam.a1am,stimparam.a1rf,stimparam.a1ph,stimparam.a1rv);
%  basep = round(1000/min(abs(diff([0 unique(abs(W(find(W))))]))));
%  maxv = max(abs(W));
%  maxf = max(max(abs(Omega))); 
%  safdef = maxv*2 + 1000/basep;     
%  numcompdef = maxf*2*5 + 1;
%  % Need to modify stimscal call to accomodate for log amplitude torcs
%  % Ignoring for now
%  [ststims,freqs] = ststruct(waveParams,W,Omega,125,4000,numcompdef,basep,safdef);
%  ststims = stimscal(ststims,'moddep',0.9,[],ceil(10*safdef*basep/1000),ceil(10*numcompdef/5));
%  
%  [waveParams2,W2,Omega2,nrips2] = makewaveparams(stimparam2.a1am,stimparam2.a1rf,stimparam2.a1ph,stimparam2.a1rv);
%  basep2 = round(1000/min(abs(diff([0 unique(abs(W2(find(W2))))]))));
%  maxv2 = max(abs(W2));
%  maxf2 = max(max(abs(Omega2))); 
%  safdef2 = maxv2*2 + 1000/basep2;     
%  numcompdef2 = maxf2*2*5 + 1;
%  % Need to modify stimscal call to accomodate for log amplitude torcs
%  % Ignoring for now
%  [ststims2,freqs2] = ststruct(waveParams2,W2,Omega2,125,4000,numcompdef2,basep2,safdef2);
%  ststims2 = stimscal(ststims2,'moddep',0.9,[],ceil(10*safdef2*basep2/1000),ceil(10*numcompdef2/5));
%  
%  
%  figure
%  for u = 1:numclass,
%   spdata = getspikes(fnamespikes,u, expData, torcList);
%   spdata2 =getspikes(f2namespikes,u, expData2, torcList2);
%   stdef = round(1000*stonset+100);%basep;
%   etdef = stonset + stdur; 
%   etdef2 = stonset2 + stdur2;
%   [strfest,indstrfs,resp]=pastspec(spdata,ststims,basep,stdef,round(1000*etdef),hfreq,nrips,1,0);
%    close(gcf)
%   [strfest2,indstrfs2,resp2]=pastspec(spdata2,ststims2,basep2,stdef,round(1000*etdef2),hfreq2,nrips2,1,0);
%    close(gcf)
% 
%   subplot(numclass,2,u*2-1)
%   
%   % Note: Not stplotting more than 250ms. Following changes are made 
%   % to accomodate that.
%   % -- Ray 04/29/2004
%       
%   strfest = interpft(interpft(strfest,256,1),basep,2);
%   strfest = strfest(:,1:min(250,basep));
%   stplot(strfest,hfreq/32,min(250,basep));
%   
% %   if u==1, title([direc '/' fname '---' direc2 '/' f2name 'Class ' num2str(classvec(u))],'FontWeight', 'bold')
%      title(['1st file Class ' num2str(classvec(u))], 'FontWeight', 'bold')
% 
%   
%   subplot(numclass,2,u*2)
%   strfest2 = interpft(interpft(strfest2,256,1),basep2,2);
%   strfest2 = strfest2(:,1:min(250,basep2));
%   stplot(strfest2,hfreq2/32,min(250,basep2));
%   title(['2nd file Class ' num2str(classvec(u))], 'FontWeight', 'bold')
%   %
%   
%  
%  end
% set(gcf,'Name',['JUSTIN - STRF : ', direc ,'_' ,fname ,'/' ,direc2 ,'_' ,f2name],'NumberTitle','off')
% % set(gcf,'pos',[425 50 550 850])
% 
% 
% clear spdata
% clear spdata2
% STRF = 0;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
