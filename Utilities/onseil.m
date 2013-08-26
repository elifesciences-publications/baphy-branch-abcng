function r=onseil()

[s,host]=unix('hostname');
host=strtrim(host);
if ~isempty(findstr(lower(host),'seil.umd.edu')),
   r=1;
elseif strcmpi(host,'badger') || strcmpi(host,'capybara') ||...
        strcmpi(host,'microbat') || strcmpi(host,'hyrax'),
   r=2;
else
   r=0;
end
