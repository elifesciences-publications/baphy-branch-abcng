function strf_meska(path,direc,fname,Rpath,spiketemp,spk,st,extras, ...
    plotflag, strffig, abaflag, xaxis, namefirst,direcfirst)

if plotflag ==0, 
    filen=1;
else
    filen= plotflag;
end
torcList=extras.torcList;

torcListtag= torcList.tag;
if strcmp(torcList.type, 'clicktrain')
        embdStimStart= get(torcListtag, 'ClickStart'); % percentage of the duration after which the click starts
else
        embdStimStart=1;
end

for i = 1:length(spk), classvec(i) = ~isempty(spk{i,1}) | ~isempty(spk{i,2}); end
classvec = find(classvec);
numclass = length(classvec);
sorter = 'temp';
com= [];
sflag = 0;

source = fullfile(path,direc,fname)
%if strcmp(computer,'SOL2'), % This stuff will be changed eventually
%	 savpath = '/homes/daqsc/matlab/meska/sorted';
% elseif strmatch('GLNX',computer),
%	savpath = '/home/djklein/matlab/meska/sorted';
% elseif strcmp(computer,'MAC2'),
%	 savpath = fullfile(pwd,'sorted');
% end
savpath = [Rpath filesep 'sorted'];
if ~exist(savpath,'dir')
   mkdir(savpath);
end; 
 destin = fullfile(savpath,['temp_' basename(fname)])  % Its only temporary
 savespikes(source,destin,st,spiketemp,spk(:,filen),sorter,sflag,com, extras, abaflag, xaxis);
 fnamespikes = [destin '.spk'];

 stimparam  = readinfo(torcList, extras.expData);
 
 [waveParams,W,Omega,nrips] = makewaveparams(stimparam.a1am,stimparam.a1rf,stimparam.a1ph,stimparam.a1rv);
 basep = round(1000/min(abs(diff([0 unique(abs(W(find(W))))]))));
 maxv = max(abs(W));
 maxf = max(max(abs(Omega))); 
 safdef = maxv*2 + 1000/basep;     
 numcompdef = maxf*2*5 + 1;
 % Need to modify stimscal call to accomodate for log amplitude torcs
 % Ignoring for now
 [ststims,freqs] = ststruct(waveParams,W,Omega,125,4000,numcompdef,basep,safdef);
 ststims = stimscal(ststims,'moddep',0.9,[],ceil(10*safdef*basep/1000),ceil(10*numcompdef/5));
 stonset = get(torcList.tag, 'Onset');
 stdur = get(torcList.tag, 'Duration');
 thandle = torcList.handle(1);
 hfreq = get(thandle,'Upper frequency component');
 
 eval(['figure(' 'strffig' ')'])
 emp= 0;
 for u = 1:numclass,
%   spdata = getspikes(fnamespikes,u, expData, torcList);
%   stdef = round(1000*stonset+100);%basep;
%   etdef = stonset + stdur; 
%   [strfest,indstrfs,resp]=pastspec(spdata,ststims,basep,stdef,round(1000*etdef),hfreq,nrips,1,0);
%   close(gcf)
if isempty(spk{u,filen})
    emp=emp+1;
else
  %spdata = getspikes(fnamespikes,u-emp, extras.expData, extras.torcList, extras.chanNum);
  [spdata,tags]=loadspikeraster(fnamespikes,str2num(extras.chanNum),u-emp,1000,1);
  
  if length(tags)>0,
     usetags=[];
     for ii=1:length(tags),
        if ~isempty(findstr(tags{ii},'TORC')) & isempty(findstr(tags{ii},'Target')),
           usetags=[usetags ii];
        end
     end
     spdata=spdata(:,:,usetags);
     tags={tags{usetags}};
  end
  
  spdata(isnan(spdata))=0;
  
  %stdef = round(1000*stonset+100);%basep;
  etdef = stonset + (stdur*embdStimStart); % added the multiplication by embdStimStart to exclude the refernce click or tone
  fr1=round(stonset*1000);
  if fr1==0,
      fr1=1;
  end
  [strfest,indstrfs,resp]=pastspec(spdata(fr1:round(etdef*1000),:,:),ststims,basep,100,round(1000*(stdur*embdStimStart)),hfreq,nrips,1,0);
  close(gcf)
  
  switch plotflag
  case 1,
      subplot(numclass,2,u*2-1)
      % Note: Not stplotting more than 250ms. Following changes are made 
      % to accomodate that.
      % -- Ray 04/29/2004
      
      strfest = interpft(interpft(strfest,256,1),basep,2);
      strfest = strfest(:,1:min(250,basep));
      stplot(strfest,hfreq/32,min(250,basep));
      %   if u==1, title([direc '/' fname '---' direc2 '/' f2name 'Class ' num2str(classvec(u))],'FontWeight', 'bold')
      title(['1st file Class ' num2str(classvec(u))], 'FontWeight', 'bold')
      if u == 1
          title(fname, 'FontWeight', 'bold');
      end
      figname =['MESKA - STRF : ', direc ,'_' ,fname ,'/'];
  case 2
      subplot(numclass,2,u*2)
      strfest = interpft(interpft(strfest,256,1),basep,2);
      strfest = strfest(:,1:min(250,basep));
      stplot(strfest,hfreq/32,min(250,basep));
      title(['2nd file Class ' num2str(classvec(u))], 'FontWeight', 'bold')
      if u == 1
          title(fname, 'FontWeight', 'bold');
      end
      figname =['MESKA - STRF : ', direcfirst ,'_' ,namefirst ,'/','     ', direc ,'_' ,fname];
      set(gcf,'Name',figname,'NumberTitle','off')
  case 0
      if numclass==1, columnNum=1; else, columnNum= 2; end
      subplot(ceil(numclass/2),columnNum,classvec(u))
      strfest = interpft(interpft(strfest,256,1),basep,2);
      strfest = strfest(:,1:min(250,basep));
      stplot(strfest,hfreq/32,min(250,basep));
      title(['Class ' num2str(classvec(u))]), 
      if u == 1
          title(fname, 'FontWeight', 'bold');
      end
      set(gcf,'Name',['MESKA - STRF : ',direc,'_',fname],'NumberTitle','off')
end
  
end
clear spdata 
end



