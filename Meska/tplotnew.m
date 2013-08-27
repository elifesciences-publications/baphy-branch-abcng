function tplotnew(fname,recs,varargin)
% tplotnew(fname)
% tplotnew(fname, recs)
% tplotnew(fname, fname2, ...)
% tplotnew([fname; fname2; ...])
% tplotnew([fname; fname2; ...], recs)
%
% tplot uses getspikes and spikeplotnew to display spiketrain rasters 
% in a new figure window.
% fname is a string containing the experiment and filename,
%  for example '225/30a07.a1-.fea' or 
%              '/software/daqsc/data/225/30a07.a1-.fea'
% recs is an optional range of which records to plot (default = all)
%
% uses [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname);
%      figure; spikeplotnew(spdata,mf,fname,[],paramdata,[stonset stdur]);

if ~exist('recs');recs = [];end

if size(fname,1) == 1
 if ~ischar(recs)

 [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname,1,1);
 figure; spikeplotnew(spdata,mf,fname,recs,paramdata,[stonset stdur]);
 for mm=2:nUnit
  [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname,mm,1);
  figure; spikeplotnew(spdata,mf,fname,recs,paramdata,[stonset stdur]);
 end
 if nUnit > 1
	 Ncl = getfieldval(paramdata,'Ncl');
	 Template = getfieldvec(paramdata,'Template');size(Template);
	 rate = getfieldval(paramdata,'mult_fact_orig')*1000;
	 thresh = getfieldval(paramdata,'spthr2')*getfieldval(paramdata,'unitThr');
  showTemplates(reshape(Template,size(Template,2)/Ncl,Ncl),Ncl,rate,thresh)
 end

 else % (recs isn't range, it's really another file)
  tplot(fname)
  tplot(recs)
  for mm = 1:length(varargin)
   tplot(varargin{mm})
  end
 end
else
 for mm = [1:size(fname,1)]
   tplot(fname(mm,:),recs)
 end
end



