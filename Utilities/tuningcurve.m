function baphy_tuningcurve(action)
a=path;
b=strsep(a,';');
c=(strfind(b,'baphy'));
newPath =[];
for cnt1 = length(c):-1:1  % so that we can delete them and index doesnt change
    if ~isempty(c{cnt1})
        rmpath(b{cnt1});
    end
end
addpath(matlabroot) % to access the config file
addpath('f:\users\alphaomega\code\behavior\signals');
addpath('f:\users\alphaomega\code\behavior\shared');
addpath('f:\users\alphaomega\code\behavior\signals\shared');
addpath('f:\users\alphaomega\code\behavior\daqhw');
addpath('f:\users\alphaomega\code\behavior\UserInterface');
addpath('f:\users\alphaomega\code\behavior\tuningcurve');
tuningcurve('init');