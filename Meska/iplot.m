function iplot(fname, varargin)
% IPLOT(fname)
% IPLOT(fname, fname2, ...)
% IPLOT([fname; fname2; ...])
%
% iplot displays 'inf' files in a new terminal window.
% fname is a string containing the experiment and filename,
%  for example '225/30a07.a1-.fea' or 
%              '/software/daqsc/data/225/30a07.a1-.fea'

if size(fname,1) == 1
 if length(varargin)==0
	 
	 [featxtdir,sstr,ctag] = spikefile(fname);
	 inffile = [featxtdir sstr '.inf'];

  if strcmp(computer,'MAC2')
	  edit(inffile);
	 else
	  unix(['/usr/dt/bin/dtterm -title ', fname ,...
        ' -e /usr/local/bin/less ', inffile,...
         ' &']);
 end
 

 else % (recs isn't range, it's really another file)
  iplot(fname)
  for mm = 1:length(varargin)
   iplot(varargin{mm})
  end
 end
else
 for mm = [1:size(fname,1)]
   iplot(fname(mm,:))
 end
end



