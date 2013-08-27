%function TORCgenerator(par)
%
%
function TORCgenerator(par)

soundpath=[fileparts(which('Torc2')) filesep 'Sounds' filesep];
tdir=pwd;
cd(soundpath)

a1rf = (1.4:-0.2:-1.4);
f0 = [125, 250, 500, 1000 2000];
SF = [10000, 20000, 40000, 80000, 160000];
lev = 'lhvuw';

HighestFrequency = par.FrequencyRange;
HighName = lower(HighestFrequency(1));
level=find(lev==HighName);

Rates = par.Rates;
Rates= strtrim(Rates);
switch Rates
   case '2:2:12',
      a1rv = (2:2:12)';
      RateName = '212';
   case '2:2:16',
      a1rv = (2:2:16)';
      RateName = '216';
   case '4:4:24',
      a1rv = (4:4:24)';
      RateName = '424';
   case '4:4:48',
      a1rv = (4:4:48)';
      RateName = '448';
   case '8:8:48',
      a1rv = (8:8:48)';
      RateName = '848';
   case '8:8:96',
      a1rv = (8:8:96)';
      RateName = '896';
   case '1:1:8',
      a1rv = (1:1:8)';
      RateName = 'SD';
end

if par.ModDepth<=1,
   AF=1;
   ModDepth=0.9;
   DepthName='_LIN';
else
   AF=0;
   ModDepthdB=par.ModDepth;
   DepthName=['_L',num2str(ModDepthdB)];
end
soundpath=[fileparts(which('Torc2')) filesep 'Sounds' filesep];
fname = [soundpath 'TORC_' RateName DepthName];

T = round(1000/min(a1rv)); % base period from lowest modulation freq
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
a1ph=round(a1ph);

% Inverse-polarity
a1am = [a1am a1am];
a1rv = [a1rv a1rv];
a1rf = [a1rf a1rf];
a1ph = [a1ph a1ph-180];

% generate ripples
nstim = size(a1am,2);
T0=3;

%cond = [T0, f0, BW, SF, CF, df, RO, AF, Mo, wM, Ph];
if AF==1,
   cond = [T0, f0(level), 5, SF(level), 1, 1/100, 0, AF, 0.9, 120, 1];
else
   cond = [T0, f0(level), 5, SF(level), 1, 1/100, 0, AF, ModDepthdB, 120, 1];
end

for abc = 1:nstim
   rippleList =  [a1am(:,abc),a1rv(:,abc),a1rf(:,abc),a1ph(:,abc)];
   rippleList_rad =  [a1am(:,abc),a1rv(:,abc),a1rf(:,abc),a1ph(:,abc)./180.*pi];
   s = multimvripfft1(rippleList_rad, cond);
   
   str = num2str(abc,'%02d');
   
   % save directly to wav instead
   wavname=[fname '_' str '_' lev(level) '501' '.wav'];
   fprintf('Saving to %s.\n',wavname);
   fs = length(s)/T0;
   s=s./(max(abs(s)));
   s=s.*0.9999;
   wavwrite(s, fs, wavname);
   stim=wav2spectral(s,'specgram',fs./2,100,32);
   figure(1);clf;imagesc(stim');axis xy;
   drawnow;
   if strcmp(computer,'GLNXA64'),
       sound(s,fs);
   else
       wavplay(s,fs);
   end
   % save parameters with phase in degrees to be compaitble with ststims code
   a = writeTorcInfo([fname '_' str '_' lev(level) '501' '.txt'],rippleList,cond);
end

cd(tdir);

