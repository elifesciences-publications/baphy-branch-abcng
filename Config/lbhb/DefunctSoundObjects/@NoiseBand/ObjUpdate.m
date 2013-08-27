function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% SVD 2007-03-30

Frequencies=get(o,'Frequencies');
Bandwidth= get(o, 'Bandwidth');

FrequenciesCount=length(Frequencies);
BandwidthCount= length(Bandwidth);

TotalCombinations=FrequenciesCount*BandwidthCount;
CombinationSet=cat(2,...
    reshape(repmat(Frequencies,[BandwidthCount 1]),[],1),...
    reshape(repmat(Bandwidth',[1 FrequenciesCount]),[],1));

%CombinationSet
Names=cell(1,TotalCombinations);
for ii=1:TotalCombinations,   
    Name1=[num2str(CombinationSet(ii,1))];
    Name2=[num2str(CombinationSet(ii,2))];
    Names{ii}=[Name2 '+' Name1];
end

o = set(o,'MaxIndex',TotalCombinations);
o = set(o,'CombinationSet',CombinationSet);
o = set(o,'Names',Names);
