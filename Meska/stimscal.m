function stim = stimscal(stim,REGIME,OPTION1,OPTION2,tsiz,xsiz);
% stim = stimscal(stim,REGIME,OPTION1,OPTION2,tsaf,xsaf);
%
% STIMSCAL: Stimulus scaling according the REGIME and OPTION# input strings.
% 
% Possibilities for REGIME and OPTION#:
%   REGIME            OPTION#
% 1) 'var': 	Variance normalization;
%		OPTION1 is the value of the variance. The default is unity.
%		OPTION2 is not required.
% 2) 'rip':	Ripple component magnitude normalization;
%		OPTION1 is the value of the magnitude. The default is unity.
%		OPTION2 is the number of ripples in the stimulus. Default: 6.
% 3) 'moddep':	Specified modulation depth;
%		OPTION1 is the modulation depth as a fraction of 1.
%		The default is 0.9.
%		OPTION2 is not required.
% 4) 'dB':	Stimulus produced with logarithmic amplitude.
%		OPTION1 is the modulation depth.  The default is 0.9.
%		OPTION2 is the base amplitude. The default is 75dB.

if nargin < 6, xsiz = size(stim,1); end
if nargin < 5, tsiz = size(stim,2); end
if nargin < 4,
	if strcmp(REGIME,'rip'), OPTION2 = 6; 
	else OPTION2 = 75; end
end
if nargin == 2, 
	if strcmp(REGIME,'var')|strcmp(REGIME,'rip'), OPTION1 = 1;
	else OPTION1 = 0.9; end
end

base1 = 0;
if (~strcmp(REGIME,'var')&~strcmp(REGIME,'rip')&...
	~strcmp(REGIME,'moddep')&~strcmp(REGIME,'dB')),
	error('Specified REGIME does not match any valid choice')
end

for abc = 1:size(stim,3),

	temp = stim(:,:,abc);

	if strcmp(REGIME,'moddep')|strcmp(REGIME,'dB')
		if xsiz~=size(temp,1) & tsiz~=size(temp,2),
		  temp1 = interpft(interpft(temp,xsiz,1),tsiz,2);
		else 
		  temp1 = temp;
		end
		scl = max(abs([min(min(temp1)),max(max(temp1))]));
	  	temp2 = base1 + temp*OPTION1/scl;
	end
	
	if strcmp(REGIME,'dB'),
		stim(:,:,abc) = OPTION2 -10*log10(size(stim,1))+...
				20*log10(temp2);
	elseif strcmp(REGIME,'var'),
		stim(:,:,abc) = ...
			temp/(sqrt((1/OPTION1)*mean(mean(temp.^2))));
	elseif strcmp(REGIME,'rip'),
		stim(:,:,abc) = ...
			OPTION1*temp/sqrt(mean(mean(temp.^2))/(OPTION2/2));
	elseif strcmp(REGIME,'moddep'),
		stim(:,:,abc) = temp2;
	end
end
