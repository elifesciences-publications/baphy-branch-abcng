
===========================================
Some useful tips for using gentonecloud21.m (in order of how much you might care)
[Trevor Agus, 15/09/2011, updated 04/07/2012 & 06/01/2015]
===========================================

1/ Running tdemo.m should generate a tone cloud using gentonecloud21 then play it.

2/ tdemo optionally takes some parameters to generate different types of tone clouds. Type "help tdemo" for further information.

3/ The parameters of the tone cloud are specified in the fields of the structure "sP" 
(look at the code of tdemo.m to see what fields are needed).

4/ A structure "sP" is also output from gentonecloud21. You can use this to regenerate 
the tonecloud at a future date. The advantage of saving sP (and not the wave-form) is 
that it doesn't use up as much disk-space, so you can just save all your stimuli. The 
trick is that the seed of the random-number generator is stored as sP.seed, 
enabling the same sequence of random numbers to be generated another time.

5/ There's also a handy function tplottonecloud21.m which does the same as gentonecloud21.m
but also displays a "sketch" of the spectrogram of the tonecloud (using lines for pure tones).

6/ The scariest looking part of the code in gentonecloud21 is now redundant and it's normally skipped (lines 
162-217). For further help on hacking the code: trevor@recoil.org

7/ gentonecloud22 was a variant that included frequency-sweeping tone pips. I can't remember why...