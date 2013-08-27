
% This script generates stimuli as in McDermott et al. (PNAS, 2011), but
% with different degrees of correlation in the spectral and temporal
% dimensions of a time-frequency decomposition.
%
% This version has a frequency range appropriate for animal physiology
% experiments
%
% corr_option has to be set to either 1 or 2, to vary either the spectral
% or temporal correlation
%
% 10 examples are generated for each setting and their spectrograms are
% plotted in rows of the figure.
% The settings used in the second row are the ones used in the paper (in
% which the correlations are approximately matched to those in many natural sounds).
%
% The script then plays the sounds one after another, pausing after each
% row. It then plays a mixture of each sound with another, followed by the
% sound in isolation. It should be difficult to segregate the mixture, i.e.
% to tell whether the sound was in the mixture.
% Finally, the script plays each sound repeatedly mixed with different
% other sounds, again followed by the sound in isolation. It should be
% easy to hear the sound repeating.
%
% June-27-2011 Josh McDermott

num_sounds=10;
low_lim=20;
high_lim=16000;
sr=high_lim*2;
dur_ms=310; %310;
gap_ms=0;

fcorrs = 1./[1 13.3 30 100 1000]*1.4528;
tcorrs = 1./[1 15.3 30 100 1000];

% these are presumably the values used in the study
fcorr=fcorrs(2);
tcorr=tcorrs(2);

[target_sounds, target_grids] = generate_gauss_sounds_general(num_sounds,dur_ms,low_lim,high_lim,40,fcorr,tcorr,.5,sr,1);

for t=1:num_sounds,
   target_sounds(t,:)=hann(target_sounds(t,:),10,sr);
end

figure;

repidx=2;
% rand means combine 2 random sounds, never two of the same one
randidx=shift(1:num_sounds,ceil(num_sounds./2));
randmix=[];
repmix=[];
repsingle=[];
for t=1:num_sounds,
   subplot(2,ceil(num_sounds./2),t);
   imagesc(flipud(20*log10(sound_energy_grid_full(target_sounds(t,:),sr,40,20,16000,20,1))));

   randmix=[randmix target_sounds(t,:)+target_sounds(randidx(t),:) zeros(1,round(gap_ms./1000*sr))];
   repmix=[repmix target_sounds(t,:)+target_sounds(repidx,:) zeros(1,round(gap_ms./1000*sr))];
   repsingle=[repsingle target_sounds(repidx,:) zeros(1,round(gap_ms./1000*sr))];
   
end

sound(randmix/4,sr);
sound(repmix/4,sr);
sound(repsingle/4,sr);


for t=1:10
   temp = [];
   for d = [1:t-1 t+1:10]
      temp = [temp hann(target_sounds(t,:)+target_sounds(d,:),10,sr)];
   end
   temp = [temp zeros(1,length(target_sounds)) hann(target_sounds(t,:),10,sr)];
   mix_sequences(t,:,f) = temp;
   temp = [1:t-1 t+1:10];
   d = temp(ceil(9*rand));
   single_mixture(t,:,f) = [hann(target_sounds(t,:)+target_sounds(d,:),10,sr) zeros(1,length(target_sounds)) hann(target_sounds(t,:),10,sr)];
end


%sound(hann(.05*sin(400*2*pi*[1:10000]/24000),10,24000),24000);
%pause(.5);
sound(all_sounds/4,sr);
pause



for f=1:5
    %sound(hann(.05*sin(400*2*pi*[1:10000]/24000),10,24000),24000);
    %pause(.5);
    for t=1:10
        sound(single_mixture(t,:,f)/4,sr);
        pause
    end
end

for f=1:5
    %sound(hann(.05*sin(400*2*pi*[1:10000]/24000),10,24000),24000);
    %pause(.5);
    for t=1:10
        sound(mix_sequences(t,:,f)/4,sr);
        pause
    end
end

