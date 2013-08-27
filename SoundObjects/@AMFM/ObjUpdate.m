function o = ObjUpdate (o);
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.


% Jonathan Z. Simon, March 2006
totalAM_Num=length(ifstr2num(get(o,'Freq_AM_List')))+1;
totalFM_Num=length(ifstr2num(get(o,'Freq_FM_List')))+1;

MaxIndex = totalAM_Num * totalFM_Num;
o = set(o,'MaxIndex', MaxIndex);

FullAMList = repmat([0 ifstr2num(get(o,'Freq_AM_List'))],1,totalFM_Num);
o = set(o,'FullAMList',FullAMList);

FullFMList = repmat([0 ifstr2num(get(o,'Freq_FM_List'))],totalAM_Num,1);
FullFMList = reshape(FullFMList,1,totalAM_Num*totalFM_Num);
o = set(o,'FullFMList',FullFMList);

Names = cell(1,MaxIndex);
for mm=1:MaxIndex
	Names{mm}=['AMFM_AM_' num2str(FullAMList(mm),'%06.2f') '_Hz_FM_'  num2str(FullFMList(mm),'%06.2f') '_Hz'];
end
o = set(o,'Names',Names);
