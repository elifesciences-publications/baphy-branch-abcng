function p = paramsfromfile(paramfile);
	fidparam = fopen(paramfile,'r');
	if fidparam == -1, pause(1), fidparam = fopen(paramfile);end
	p = fscanf(fidparam,'%c');
	fclose(fidparam);
