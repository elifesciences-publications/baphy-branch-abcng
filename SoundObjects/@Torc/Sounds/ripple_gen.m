a1rv = (4:4:24)';
T = round(1000/4); % base period

a1rf = (1.4:-0.2:-1.4);

velnum = length(a1rv);
frqnum = length(a1rf);

a1am = ones(velnum,frqnum);
a1ph = rand(velnum,frqnum)*360 - 180;
a1rv = a1rv*ones(1,frqnum); 
a1rf = ones(velnum,1)*a1rf; 

% Phase optimization
for s = 1:frqnum,
 disp(['Phase optimization: Stimulus ' num2str(s)])
 PLOT = 1;
 [yo,a1ph(:,s),mi,mo,mvec] = phsopt(a1am(:,s),a1rv(:,s),a1rf(:,s),a1ph(:,s),250,5,T,1000,PLOT);
end

% Inverse-polarity
a1am = [a1am a1am];
a1rv = [a1rv a1rv];
a1rf = [a1rf a1rf];
a1ph = [a1ph a1ph-180];

% generate ripples
nstim = size(a1am,2);
f0 = [125, 250, 500, 1000];
SF = [10000, 20000, 40000,80000];
lev = 'lhvu';
fname = 'tmp/RIP';
for level = 4 % 1:4
    %cond = [T0, f0, BW, SF, CF, df, RO, AF, Mo, wM, Ph]; 
    cond = [3, f0(level), 5, SF(level), 1, 1/100, 0, 1, 0.9, 120, 1];
    for abc = 1:nstim
       for efg= 1:size(a1rv,1),
          
          rippleList =  [a1am(efg,abc),a1rv(efg,abc),...
                         a1rf(efg,abc),a1ph(efg,abc)];
          s = multimvripfft1(rippleList, cond);
          
          str=sprintf('s%.2d_r%.02d',abc,efg);
          %str = num2str(abc);
          %if length(str)==1, str = ['0' str]; end
          fid = fopen([fname '_' str '_' lev(level) '501' '.wfm'],'wb', 'b');
          fwrite(fid, s, 'float');
          fclose(fid);
          a = writeTorcInfo([fname '_' str '_' lev(level) '501' '.txt'],rippleList,cond);
       end
    end
end


