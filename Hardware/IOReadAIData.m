function [Aux, Spike, names] = IOReadAIData(HW)
% function d = IOReadAIData(HW);
%
% Read the analog data from Daq card.
% HW: handle of the hardware
% Aux: is the auxiliary data, which is everything except spike data
% Spike: is the spike data. If it doesn't exists (ex. no physiology or
%   alphaomega) will be empty
% names: is the name of the auxiliary channels.
% Aux and Spike are in Time X AIchancount formats
%
% 
% SVD update 2012-05-30 : added Nidaqmx support

% Nima, April 2006
names = []; Aux = []; Spike = [];

if HW.params.HWSetup==0,
    return
end

if strcmpi(IODriver(HW),'NIDAQMX'),
  d=niReadAIData(HW.AI(1));
  names=strsep(HW.AI(1).Names,',');
  Spike=[];
  
  % Also, if touch exists threshold it here:
  touchchannels = find(~cellfun(@isempty,strfind(names,'Touch')));
  if ~isempty(touchchannels) & size(d,2) >= max(touchchannels)
      d(:,touchchannels) = (d(:,touchchannels)>0.75); % threshold analog signal
      % CB 06 Oct. - want the whole signal for heartbeat and respiration
      if isfield(HW.params,'LickSign') && HW.params.LickSign == -1 % invert the signal
          d(:,touchchannels)=~d(:,touchchannels);
      end
  end
  
  % convert walk data from V to mV so that it survives conversion to
  % integer
  walkchannels = find(~cellfun(@isempty,strfind(names,'walk')));
  if ~isempty(walkchannels) & size(d,2) >= max(walkchannels)
      d(:,walkchannels) = d(:,walkchannels).*1000;
  end
  
  Aux=d;
  
  return
end

switch HW.params.HWSetup
    case 0
    otherwise
        if isrunning(HW.AI), return; end
        % Determine how many samples were acquired
        datacount = get(HW.AI,'SamplesAcquired');
        d = getdata(HW.AI,datacount);
        flushdata(HW.AI,'all');
        % now, get the names and extract spike and aux:
        names = HW.AI.Channel.ChannelName;
        spikechannel = find(strcmpi(names,'spike'));
        if ~isempty(spikechannel),
            Spike = d(:,spikechannel);
            if HW.params.fsAI ~= HW.params.fsSpike
                Spike = resample(Spike, HW.params.fsSpike, HW.params.fsAI);
            end
            d(:,spikechannel)   = [];
            names(spikechannel) = [];
        end
        % now, if auxiliary data is not samples at the correct frequency
        % resample it. 
        if HW.params.fsAI ~= HW.params.fsAux
            d = resample(d, HW.params.fsAux, HW.params.fsAI);
        end
        % Also, if touch exists threshold it here:
        touchchannels = find(~cellfun(@isempty,strfind(names,'Touch')));
        if ~isempty(touchchannels) & size(d,2) >= max(touchchannels)
            d(:,touchchannels) = (d(:,touchchannels)>0.75); % threshold analog signal
            if isfield(HW.params,'LickSign') && HW.params.LickSign == -1 % invert the signal
                d(:,touchchannels)=~d(:,touchchannels);
            end
        end
        
        walkchannels = find(~cellfun(@isempty,strfind(names,'walk')));
        if ~isempty(walkchannels) & size(d,2) >= max(walkchannels)
            % convert from V to mV
            d(:,walkchannels) = d(:,walkchannels).*1000;
        end
        
        pawchannel = find(strcmpi(names,'paw'));
        if ~isempty(pawchannel) & size(d,2)>=pawchannel
            d(:,pawchannel) = (d(:,pawchannel)>2.5); % threshold analog signal
            if isfield(HW.params,'PawSign') && HW.params.PawSign == -1 % invert the signal
                d(:,pawchannel)=~d(:,pawchannel);
            end
        end
        Aux = d;
end

