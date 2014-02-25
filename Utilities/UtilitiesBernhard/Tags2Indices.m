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
      
    case {'psycholinguisticstimuli'}
       CTags = {'a1','a2','a3',...
          'a_speaker_blocked1','a_speaker_blocked2','a_speaker_blocked3',...
          't1','t2','t3',...
          't_speaker_blocked1','t_speaker_blocked2','t_speaker_blocked3'};
        StartInd = find(Tags{i}==',',1,'first')+2;
        StopInd = find(Tags{i}=='.')-1;
        Indices(i) = find(strcmp(Tags{i}(StartInd:StopInd),CTags));
      
      otherwise error('Stimclass not implemented!');
  end
end