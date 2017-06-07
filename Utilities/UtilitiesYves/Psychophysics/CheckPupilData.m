[~,~,E,AuxTrialIdS] = evpread('C:\Data\Test\Test_2017_05_23_TMP_5.evp','auxchans',2);
clear TrialNb PupilperTrial
TrialNb = length(AuxTrialIdS);%length(LTTrialidx);
TrialPos = AuxTrialIdS;
for TrialNum = 1:TrialNb-1
PupilperTrial{TrialNum} = E(TrialPos(TrialNum):TrialPos(TrialNum+1),:);
end
for ii=1:length(PupilperTrial);hold all;plot(PupilperTrial{ii});end