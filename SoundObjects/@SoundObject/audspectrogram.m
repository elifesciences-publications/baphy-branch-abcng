function stim=audspectrogram (o,param,fdecimate,forceCalculate)
% function stim=audspectrogram (o,param,fdecimate,forceCalculate);
% calculation of the auditory spectrogram of the stimulus
% param [frmlen, tc, fac, shft] 
%    fac: is the compression factor BUT not from wav2aud.
%
%
% april 2006, Nima Mesgarani
if nargin<4, forceCalculate = 0;end
if ~exist('fdecimate','var') || isempty(fdecimate), fdecimate=4;end
if ~exist('param','var') || isempty(param), param = [10 10 -2 log2(get(o,'SamplingRate')/16000)];end
if param(3)~=-2
    fac = param(3);
    param(3)=-2;
else
    fac=1;
end
fs = get(o,'SamplingRate');
CalculateFlag = 1;  % by default, calculate the spectrogram
Names = get(o,'Names');
object_spec = what(class(o));
soundpath = [object_spec.path];
% now load the last parameters, if they are the same load the stim
% instead of calculating it, its much faster.
if exist([soundpath filesep 'audspecparams.mat'],'file') ...
        && exist([soundpath filesep 'audspecstim.mat'],'file')
    load ([soundpath filesep 'audspecparams.mat']);
    if length(Names) == length(SNames)
        flag = 0;
        for cnt1 = 1:length(Names);
            if ~strcmpi(Names{cnt1},SNames{cnt1}) flag =1;end
        end
        if (flag == 0) ...% which means all names are equal
                & (Sparam==param) & (Sfs == fs) & ...
                (Sfdecimate == fdecimate) & forceCalculate~=1
            % yes this is the same!! do not calculate:
            CalculateFlag = 0 ;
        end
    end
end
if CalculateFlag == 0
    load ([soundpath filesep 'audspecstim.mat']);
else
    figure;loadload;close;
    stim=[];
    for cnt1=1:get(o,'MaxIndex')
        disp(cnt1);
        wav=waveform(o,cnt1);
        tparam=param;
        if fs~=16000,
           wav=resample(wav,16000,fs);
           tparam(4)=0;
        end
        
        if 0
            % for pc, use the dll compiled from the c code to speed things
            % up.
            temp = cochlear_filt(wav,tparam)';
        else
            temp = wav2aud(wav,tparam)'; % auditory spectrogram
        end
        temp(:,1:end-1)=temp(:,2:end);
        temp = temp.^fac;
        for cnt2=1:size(temp,2) % dowsample frequency axis
%             temp1(:,cnt2)=resample(temp(11:128,cnt2),1,fdecimate);
            temp1(:,cnt2)=decimate(temp(11:128,cnt2),fdecimate);
        end
        stim{cnt1}=max(0,temp1);
    end
    Sfs = fs;
    SNames = Names;
    Sparam = param;
    Sfdecimate = fdecimate;
    save([soundpath filesep 'audspecparams.mat'],'SNames',...
        'Sparam', 'Sfs', 'Sfdecimate');
    save([soundpath filesep 'audspecStim.mat'],'stim');
end
