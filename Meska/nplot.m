function nplot(fname,recs,varargin)
% NPLOT(fname)
% NPLOT(fname, recs)
% NPLOT(fname, fname2, ...)
% NPLOT([fname; fname2; ...])
% NPLOT([fname; fname2; ...], recs)
%
% nplot uses getspikes and collapsespplot to display collective spike
% behavior in a new figure window.
% fname is a string containing the experiment and filename,
%  for example '225/30a07.a1-.fea' or 
%              '/software/daqsc/data/225/30a07.a1-.fea'
% recs is an optional range of which records to plot (default = all)
% (currently unimplemented)

if ~exist('recs');recs = [];end

if size(fname,1) == 1
 if ~ischar(recs)

 [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname,1);
 figure; collapsespplot(spdata,mf,fname,recs,paramdata,stonset,stdur,ddur,5)
 for mm=2:nUnit
  [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname,mm);
  figure; collapsespplot(spdata,mf,fname,recs,paramdata,stonset,stdur,ddur,5)
 end	 

 else % (recs isn't range, it's really another file)
  nplot(fname)
  nplot(recs)
  for mm = 1:length(varargin)
   nplot(varargin{mm})
  end
 end
else
 for mm = [1:size(fname,1)]
   nplot(fname(mm,:),recs)
 end
end
