function outfile=gunzip(filename,outdir);

if ~exist('outdir','var'),
   outdir=fileparts(filename);
end

outfile=fullfile(outdir,basename(filename));
outfile=strrep(outfile,'.gz','');

disp(['gunzip < ',filename,' > ',outfile]);

unix(['gunzip < ',filename,' > ',outfile]);
