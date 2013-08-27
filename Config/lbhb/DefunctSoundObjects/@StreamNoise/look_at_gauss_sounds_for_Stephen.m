
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

sr=32000;

fcorrs = 1./[1 13.3 30 100 1000]*1.4528;
tetcorrs = 1./[1 15.3 30 100 1000];

figure('Position',[18 39 1184 936]);
k=0;
for f=1:5
    if corr_option==1 %vary spectral corr
        fcorr = fcorrs(f);
        tcorr = tcorrs(2);
    elseif corr_option==2 %vary temporal corr
        fcorr = fcorrs(2);
        tcorr = tcorrs(f);        
    end
    [target_sounds, target_grids] = generate_gauss_sounds_general(10,310,20,16000,40,fcorr,tcorr,.5,sr,1);
    
    temp = [];
    for t=1:10
        k=k+1;
        subplot(5,10,k);
        imagesc(flipud(20*log10(sound_energy_grid_full(target_sounds(t,:),sr,40,20,16000,20,1))));
        temp = [temp hann(target_sounds(t,:),10,sr) zeros(1,round(.3*sr))];
    end
    all_sounds(f,:) = temp;
    
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
    
end

pause
for f=1:5
    %sound(hann(.05*sin(400*2*pi*[1:10000]/24000),10,24000),24000);
    %pause(.5);
    sound(all_sounds(f,:)/4,sr);
    pause
end

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

