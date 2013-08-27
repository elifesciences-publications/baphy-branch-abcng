function mplot(fname,recs,varargin)
% MPLOT(fname)
% MPLOT(fname, recs)
% MPLOT(fname, fname2, ...)
% MPLOT([fname; fname2; ...])
% MPLOT([fname; fname2; ...], recs)
%%
% mplot uses getspikes and mpstplot to display spiketrain psts
% (and their linear fits).
% fname is a string containing the experiment and filename,
%  for example '225/30a07.a1-.fea' or 
%              '/software/daqsc/data/225/30a07.a1-.fea'
% recs is an optional range of which records to plot (default = all)
% (currently unimplemented)


if ~exist('recs');recs = [];end

if size(fname,1) == 1
 if ~ischar(recs)

 [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname,1);
 figure;mpstplot(spdata,mf,fname,recs,paramdata,stonset,stdur,ddur,16,125,ddur)
 for mm=2:nUnit
  [spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] = getspikes(fname,mm);
  figure;mpstplot(spdata,mf,fname,recs,paramdata,stonset,stdur,ddur,16,125,ddur)
 end	 

 else % (recs isn't range, it's really another file)
  mplot(fname)
  mplot(recs)
  for mm = 1:length(varargin)
   mplot(varargin{mm})
  end
 end
else
 for mm = [1:size(fname,1)]
   mplot(fname(mm,:),recs)
 end
end
