function [Ws, Wt, Ss, St, st, spiketemp, spk]=importfile(filename, path,ts, spkraw,num,chanNum, abaflag);

s = load(fullfile(path,filename));
spk = cell(num,1);
%spk = cell(s.Ncl,1);
if length(s.sortinfo)==16
    if ~abaflag
        for u = 1:s.sortinfo{chanNum}{1}(1).Ncl,	
            spk{u} = ((s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)-1)*s.npoint + s.sortinfo{chanNum}{1}(u).unitSpikes(2,:))';
        end
    else
        for x= 1:length(s.npoint)
          trialdur(x)= sum(s.npoint(1:x)*s.nsweep);
        end
        for u = 1:s.sortinfo{chanNum}{1}(1).Ncl,	
            % calculate spike times from ABA files
            %spk{u}= (trialdur(max(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep)-1,1)).*min(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep)-1,1) +(((mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)+~mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)-1)*s.nsweep).*s.npoint(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep)))+s.sortinfo{chanNum}{1}(u).unitSpikes(2,:))'
            spk{u} = (trialdur(max(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep),2)-1).*min(floor(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep),1) + ((mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)+(~mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)*s.nsweep)-1).*s.npoint(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep))) + s.sortinfo{chanNum}{1}(u).unitSpikes(2,:))';            
            % 
            %length of cummulative sum of prior stimulus sweeps + (number of trials with in that sweep * duration of stimulus) + spike time with in that trial
            %
        end
    end
else
    for u = 1:s.sortinfo{1}(1).Ncl,	
	    spk{u} = ((s.sortinfo{1}(u).unitSpikes(1,:)-1)*s.npoint + s.sortinfo{1}(u).unitSpikes(2,:))';
    end
end

Ws = []; Wt = []; Ss = []; St = [];
%st = unique(cat(2,spk{:}))';
st = unique(cat(1,spk{:}));
spiketemp = spkraw(round(min(max((ts'*ones(1,length(st)))+(ones(length(ts),1)*st'),1),length(spkraw))));


