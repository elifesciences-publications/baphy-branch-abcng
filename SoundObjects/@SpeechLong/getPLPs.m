function plp = getPLPs (o,index)
% function plps = getPLPs (s,index)
% this function extract the PLP coeffieicients of the specified sound
%

% Nima
plp =[];
Name = get(o,'names');
Name = Name{index};
object_spec = what(class(o));
soundpath = [object_spec.path filesep 'Sounds'];
try 
    load ([soundpath filesep 'PLPs.mat']);   
    plpindex = find(strcmpi(Names,Name));
    plp = plps{plpindex};
catch
    disp(['can not load plps of ' Name]);
end
