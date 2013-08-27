  spdata = getspikes(fnamespikes,u, expData, torcList);
  %stdef = round(1000*stonset+100);%basep;
  etdef = stonset + stdur; 
  
  [strfest,indstrfs,resp]=pastspec(spdata(round(stonset*1000):round(etdef*1000),:,:),ststims,basep,100,round(1000*stdur),hfreq,nrips,1,0);
  close(gcf)
