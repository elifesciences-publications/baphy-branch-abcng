function tplot_meska(path,direc,fname,Rpath,st,spk,spiketemp,expData,torcList,unit,SEP,stonset,stdur,plotf)

disp('Preparing data...')
for i = 1:length(spk), classvec(i) = ~isempty(spk{i,1}) | ~isempty(spk{i,2}); end
classvec = find(classvec);
numclass = length(classvec);
sorter = 'temp';
com= [];
sflag = 0;
destin=[];
    
    
source = fullfile(path,direc,fname)

%if strcmp(computer,'SOL2'),
	%destin = fullfile('/homes/daqsc/matlab/meska/sorted',['temp_' fname])
%elseif strmatch('GLNX',computer),
	%destin = fullfile('/home/djklein/matlab/meska/sorted',['temp_' fname])
%elseif strcmp(computer,'MAC2'),
	%destin = fullfile(pwd,'sorted',['temp_' fname])
%end
destin = [Rpath filesep 'sorted'];
if ~exist(destin)
    mkdir(destin);
end;
spksv1 =cell(length(spk),1)

for i= 1:length(spk), spksv1{i}=spk{i,plotf}, end,

destin = [destin filesep 'temp_' fname];
savespikes(source,destin,st,spiketemp,spksv1,sorter,sflag,com,expData, torcList);
fnamespikes = [destin '.spk'];

if ~unit,
 if SEP, unit = 1:numclass;
 else,
   for u = 1:numclass,
    spdata(:,:,:,u) = getspikes(fnamespikes,u,expData,torcList);
   end
   figure; spikeplot(spdata,1,fnamespikes,[],expData); 
   set(gcf,'Name',['MESKA - Spike Raster : ',direc,'_',fname],'NumberTitle','off')
 end 
else
 unit = find(classvec==unit); 
end

if unit,
 for u = unit,
  spdata = getspikes(fnamespikes,u,expData,torcList);
  figure; spikeplot(spdata,1,fnamespikes,[],expData,[stonset stdur]);
  set(gcf,'Name',['MESKA - Spike Raster : ',direc,'_',fname,' Unit ',num2str(u)],'NumberTitle','off')
 end
end
   
