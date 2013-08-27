function paramver = getparamver(p);

paramver  = getfieldval(p,'nsl_fea_version'); % version
if isempty(paramver); 
  paramver  = getfieldval(p,'fea2spikeparam_ver'); % version
  if isempty(paramver); 
	paramver = 0; 
  end
end
