% parameters left in state to generate 4-4-48 torcs (4-48Hz), last used to
% generate super-duper high torcs (W,2-64KHz) for mouse experiments.
% - SVD 2012-07-27

%TorcFormat='standard-448';
TorcFormat='standard-424';

switch TorcFormat,
   case 'standard-448',
      a1rv = (4:4:48)';
      fname = 'TORC_448';
      AF=1;
      
   case 'log-448',
      a1rv = (4:4:48)';
      AF=0;
      ModDepthdB=50;
      fname = ['TORC_424_',num2str(ModDepthdB),'dB'];

   case 'standard-424',
      a1rv = (4:4:24)';
      fname = 'TORC_424';
      AF=1;
      
   case 'log-424',
      a1rv = (4:4:24)';
      AF=0;
      ModDepthdB=50;
      fname = ['TORC_424_',num2str(ModDepthdB),'dB'];
   otherwise
      error('unknown TorcFormat');
end

a1rf = (1.4:-0.2:-1.4);
f0 = [125, 250, 500, 1000 2000];
SF = [10000, 20000, 40000, 80000, 160000];
lev = 'lhvuw';

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
for level = [4],
    %cond = [T0, f0, BW, SF, CF, df, RO, AF, Mo, wM, Ph]; 
    T0=3;
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
       
        % skip WFM save
        %wfmname=[fname '_' str '_' lev(level) '501' '.wfm']
        %fid = fopen(wfmname,'wb', 'b')
        %fwrite(fid, s, 'float');
        %fclose(fid);
        
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
%         wavplay(s,fs);
        % save parameters with phase in degrees to be compaitble with ststims code
        a = writeTorcInfo([fname '_' str '_' lev(level) '501' '.txt'],rippleList,cond);
    end
end


