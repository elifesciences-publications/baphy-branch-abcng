function  y = bindata3(x,binsize,mf);
% y = bindata3(x,binsize,mf);
%
% binsize : given in ms
% mf: multiplication factor

if nargin == 2, mf = 1; end

[spikes,records] = size(x);
if min(spikes,records) == 1,
 x = x(:);
 records = 1; spikes = length(x);
end

binsize = binsize*mf;  % Transform binsize to indices
intnumbins = ceil(spikes/binsize);
y = zeros(intnumbins,records);

for rec = 1:records,

 % Bring half of the last bin around to the front
 xshft = [x(spikes-(floor(binsize/2))+1:spikes,rec);...
          x(1:spikes-(floor(binsize/2)),rec)];

 for binnum = 1:intnumbins,

    llim = 1 + binsize*(binnum-1);
    ulim = min(binsize*binnum,spikes);
    y(binnum,rec) = sum(xshft(floor(llim):floor(ulim)));

 end

end
