% function setfigurekeypress(fh);
%
% sets up figure fh to record keypresses for retrieval with figurekeypress
%
function setfigurekeypress(fh);

figure(fh);
clf
callstr = ['set(gcbf,''Userdata'',double(get(gcbf,''Currentcharacter''))) ; uiresume '] ;
set(fh,'keypressfcn',callstr); %set(fh,'windowstyle','modal'); 

