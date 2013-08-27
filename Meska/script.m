
addpath /dept/isr/labs/nsl/resources/meska
for i = 12:length(neuron)
    
	figure
    subplot(2,1,1)
	nstrfest= [];
	nstrfest = interpft(interpft(neuron(i).torstrfrev,256,1),basep,2);
	nstrfest = nstrfest(:,1:min(250,basep));
	stplot(nstrfest,hfreq/32,min(250,basep)); colorbar;
	
	sfft= fft2(neuron(i).torstrfrev);
	sfft(:,5:10)=0;
	strf= ifft2(sfft);
	
	neuron(i).torstrfred= strf;
	subplot(2,1,2)
	nstrfest= [];
	nstrfest = interpft(interpft(neuron(i).torstrfred,256,1),basep,2);
	nstrfest = nstrfest(:,1:min(250,basep));
	stplot(nstrfest,hfreq/32,min(250,basep)); colorbar;
    
end

