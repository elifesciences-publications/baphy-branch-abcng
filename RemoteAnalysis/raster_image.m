function data2=raster_image(data,newstim,options);

global ES_LINE ES_SHADE

if ~exist('options','var'),
   options=[];
end
PreStimSilence=options.PreStimSilence;
PostStimSilence=options.PostStimSilence;
rasterfs=options.rasterfs;
smwindow=getparm(options,'smwindow',10);

% some color info for shading
if isfield(options,'spc'),
   spc=options.spc;
else
   spc={[0 0 1],[1 0 0],[0 1 0],[0 0 0],[1 0 1],[1 1 0],[0 0.9 0.9],[1 ...
                    0 1],[1 1 0],[0 0.9 0.9]};
   spc=ES_LINE;
end
if isfield(options,'ssc'),
   ssc=options.ssc;
else
   gl=0.85;
   ssc={[gl gl 1],[1 gl gl],[gl 1 gl],[0.95 0.95 0.95],...
        [0.95 0.95 0.95],[0.95 0.95 0.95],[0.95 0.95 0.95],...
        [0.95 0.95 0.95],[0.95 0.95 0.95],[0.95 0.95 0.95]};
   ssc=ES_SHADE;
end

dn=double(isnan(data));
data(isnan(data))=0;

% bin at smwindow ms
smfilt=ones(1,smwindow)./smwindow;
data2=conv2(data,smfilt,'same');
data2=data2(:,5:10:end);
dn2=conv2(dn,smfilt,'same');
dn2=dn2(:,5:10:end);

data2=(0.2-data2)./0.2;
data2(data2>1)=1;
data2(data2<0)=0;
data3=data2;
data3(dn2>=0.5)=0.7; %1
data2(dn2>=0.5)=0.7; %0
data2=cat(3,data3,data2,data2);

ff=find(newstim);
%ff=ff(2:end);
blankstep=5;
ff=ff+blankstep*(0:(length(ff)-1));

for di=1:length(ff),
   if di>1,
      data2=[data2(1:(ff(di)-blankstep-1),:,:); ones(blankstep,size(data2,2),size(data2,3));
             data2((ff(di)-blankstep):end,:,:)];
   end
   if di<length(ff),
      muckrange=(ff(di)):(ff(di+1)-blankstep-1);
   else
      muckrange=(ff(di)):size(data2,1);
   end
   timerange=round(PreStimSilence.*rasterfs./10+1):round(size(data2,2)-(PostStimSilence.*rasterfs./10));
   
   for ggidx=1:3,
      td2=data2(muckrange,timerange,ggidx);
      bgidx=find(td2==1);
      td2(td2==1)=ssc{mod(di-1,length(ssc))+1}(ggidx);
      data2(muckrange,timerange,ggidx)=td2;
   end
   
end

return

imagesc(-PreStimSilence:(1./rasterfs):(size(data,2)./rasterfs)-PreStimSilence,...
        (1./size(data,1)):(1./size(data,1)):1,data2);

colormap(gray);
axis([-PreStimSilence size(data,2)./rasterfs-PreStimSilence 0 1]);
axis xy
