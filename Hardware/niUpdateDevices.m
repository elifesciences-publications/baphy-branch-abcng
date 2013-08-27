% function HW=niUpdateDevices(HW,newdevice);
%
% add NI device to list of current cards in use if it's not already in the
% list.  Stored in the cell array HW.Devices{}
%
% created SVD 2012-05-29
%
function HW=niUpdateDevices(HW,newdevice);

if isfield(HW,'Devices'),
  if isempty(find(strcmp(HW.Devices,newdevice), 1)),
    HW.Devices{length(HW.Devices)+1}=newdevice;
  end
else
  HW.Devices={newdevice};
end