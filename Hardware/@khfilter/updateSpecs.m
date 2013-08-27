function info = updateSpecs(t)
status1 = get(t.gpib,'Status');
if strcmpi(status1,'Open')
    fclose(t.gpib);
end;
fopen(t.gpib);
% warning off instrument:fscanf:unsuccessfulRead
% errstatus = '';
% errstatus = fscanf(t.gpib);
% spaceindex = findstr(errstatus,' ');
% if ~isempty(errstatus)
%     if strncmpi(errstatus(spaceindex(1)+1:spaceindex(2)-1),'err',3)
%         fprintf(t.gpib,'CE');
%     end;
% end;

% Nima starts here, to fix timeout problem.It seems that the filter doesnot
% respond sometimes, but always respond to the next command. So, decrease
% the timeout from 10 (default) to 1 and retrieve if it fails:
set(t.gpib,'TimeOut',1);
for i = 1:4
    fprintf(t.gpib,['CH' num2str(i)]);
    chstatus = idstrip(fscanf(t.gpib));
    while isempty(chstatus)
        disp('!!!!!!!!!failed, retry...');
        chstatus = idstrip(fscanf(t.gpib));
    end
    chstatus(3) = [];
    tmp = chstatus(2);
    chstatus(2) = chstatus(1);
    chstatus(1) = tmp;
    info(:,i) = chstatus(:);
end;

fclose(t.gpib);

if strcmpi(status1,'Open')
   fopen(t.gpib); 
end;