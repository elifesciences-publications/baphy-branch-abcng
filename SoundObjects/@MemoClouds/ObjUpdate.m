function o = ObjUpdate (o)
%  14/05-TP/YB

% TorcDur = get(o,'TorcDuration');
% TorcFreq = get(o,'FrequencyRange');
% TorcRates = get(o,'TorcRates');
% SeqGap = get(o,'SequenceGap');
% PastRef = get(o,'PastRef');   % duration is second

if isempty(get(o,'ReseedKey')) && isempty(get(o,'Key')) || length(get(o,'Key'))<get(o,'MemoCloudNb')
    for MemoCloudNum = 1:get(o,'MemoCloudNb')
        Key(MemoCloudNum) = round(prod(clock)*5/10000);
        pause(rand(1)/3);
    end
%   Key = round(prod(clock)*5/10000);
  %Key = round( Rtoday.rand(1,1)*100 );   % With RandStream('mrg32k3a'), it is important to work with large numbers,
  %because there is a heavy correlation between two seeds that belong to the same integer interval [n,n+1[
elseif ~isempty(get(o,'Key'))
  Key = get(o,'Key');
elseif ~isempty(get(o,'ReseedKey'))
  Key = get(o,'ReseedKey');
end
o = set(o,'Key',Key);