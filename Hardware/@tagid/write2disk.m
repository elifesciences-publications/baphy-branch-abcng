function dm = write2disk(tid,dm,prefix,parent,seqpos)
% WRITE2DISK - write tag information to specified file on disk
% dm = write2disk(tid,dm,prefix,parent,seqpos)
%   --- args ---
%   tid      - a scalar object from the class tagID
%   dm       - an object of class diskm
%   prefix   - (optional) string prefix having no white space characters
%              to add to fields of tagID. Default = ''
%   parent   - (optional) a string identifying the parent field of the tid
%   seqpos   - (optional) integer position in trial sequence.  If seqpos
%              is specified but parent is not, then parent defaults to
%              'trialstim'.  If neither parent nor seqpos are specified,
%              then it is assumed that there is no parent field.

  error(nargchk(2,5,nargin))
  if nargin == 2
    prefix = '';
  end
  
  if (nargin == 2) | (nargin == 3) | isempty(parent)
    if ~isempty(seqpos)
      dm = PutDataItem(dm,'trialstim',tid.tag,'', ...
		       [prefix 'tag(' num2str(seqpos) ')']);
      dm = PutDataItem(dm,'trialstim','',tid.tagval, ...
		       [prefix 'tagval(' num2str(seqpos) ')']);
    else
      dm = PutDataItem(dm,'tag',tid.tag);
      dm = PutDataItem(dm,'tagval',tid.tagval);
    end
  elseif nargin == 4
    dm = PutDataItem(dm,parent,tag,'',[prefix 'tag']);
    dm = PutDataItem(dm,parent,tagval,[prefix 'tagval']);
  else
    dm = PutDataItem(dm,parent,tag,'',[prefix 'tag(' num2str(seqpos) ')']);
    dm = PutDataItem(dm,parent,tagval,'',[prefix 'tagval(' ...
		    num2str(seqpos) ')']);
  end
  