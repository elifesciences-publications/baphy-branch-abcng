function Indices = Tags2Indices(Tags,Stimclass)

Indices = [];
for i=1:length(Tags)
  switch lower(Stimclass)
    case {'torcs','torc','clickdiscrim'};
      cInd = find(Tags{i}=='_');
      if ~isempty(cInd)
        Indices(end+1) = str2num(Tags{i}(cInd(2)+1:cInd(3)-1));
      end
      
    case {'biasedshepardpair','biasedshepardtuning','monauralhuggins'}
      cInd = find(Tags{i}==' ');
      Indices(i) = str2num(Tags{i}(cInd(3)+1:cInd(4)-1));
      
      otherwise error('Stimclass not implemented!');
  end
end