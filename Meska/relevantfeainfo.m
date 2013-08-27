function [ylabels,ylabelstring,paramstring] = relevantfeainfo(fname,paramdata,deltat);

 paramstring = '';
 intsty = getfieldval(paramdata,'unitNum');
 if ~isempty(intsty)
	 paramstring = [paramstring,sprintf('Unit %d, ',intsty(1))];
 end
 paramstring = [sprintf('\\Deltat = %g ms, ', deltat), paramstring];
 paramstring = [sprintf('%d sweeps, ',getfieldval(paramdata,'num_swps')),...
  paramstring];
 if strcmp('m2',fname(end-6:end-5))
  ylabels = getfieldval(paramdata,'cycles');
  if find(abs(ylabels) < 1e-6);ylabels(find(abs(ylabels) < 1e-6))= 0;end
  ylabelstring = 'Ripple Frequency (cyc/oct)';
  paramstring = [sprintf('%.3g kHz low, ', ...
    getfieldval(paramdata,'lower_freq')), paramstring];
  intsty = getfieldval(paramdata,'dB'); intsty = intsty(1);
  paramstring = [sprintf('%d dB, ',intsty),paramstring];
  paramstring = [sprintf('%d Hz, ',...
   getfieldval(paramdata,'angular_freq')), paramstring];
 elseif strcmp('tc',fname(end-6:end-5))
  ylabels = getfieldval(paramdata,'cycles');
  for mm = [1:length(ylabels)/2];
	ylabels(2*mm-1)=ylabels(2*mm-1)+i;ylabels(2*mm)=ylabels(2*mm)-i;
  end
  if find(abs(ylabels) < 1e-6);ylabels(find(abs(ylabels) < 1e-6))= 0;end
  ylabelstring = 'Ripple Frequency (cyc/oct)';
  paramstring = [sprintf('%.3g kHz low, ', ...
    getfieldval(paramdata,'lower_freq')), paramstring];
  intsty = getfieldval(paramdata,'dB'); intsty = intsty(1);
  paramstring = [sprintf('%d dB, ',intsty),paramstring];
  paramstring = [sprintf('%d Hz, ',...
   getfieldval(paramdata,'angular_freq')), paramstring];
 elseif strcmp('m1',fname(end-6:end-5))
  ylabels = getfieldval(paramdata,'ang_freq');
  ylabelstring = 'Ripple Velocity (Hz)';
  paramstring = [sprintf('%.3g kHz low, ', ...
    getfieldval(paramdata,'lower_freq')), paramstring];
  intsty = getfieldval(paramdata,'dB'); intsty = intsty(1);
  paramstring = [sprintf('%d dB, ',intsty),paramstring];
  paramstring = [sprintf('%g c/o, ',...
   getfieldval(paramdata,'ripple_freq')), paramstring];
 elseif strcmp('t1',fname(end-6:end-5))
  ylabels = getfieldval(paramdata,'frequency');
  ylabelstring = 'Frequency (kHz)';
  intsty = getfieldval(paramdata,'dB'); intsty = intsty(1);
  paramstring = [sprintf('%d dB, ',intsty),paramstring];
 elseif strcmp('k3',fname(end-6:end-5))
  ylabels = getfieldval(paramdata,'frequency');
  ylabelstring = 'Frequency (kHz)';
  intsty = getfieldval(paramdata,'dB'); intsty = intsty(1);
  paramstring = [sprintf('%d dB, ',intsty),paramstring];
 elseif strcmp('t1l',fname(end-6:end-4))
  ylabels = getfieldval(paramdata,'dB');
  ylabelstring = 'Intensity (dB)';
  frqcy = getfieldval(paramdata,'frequency'); frqcy = frqcy(1);
  paramstring = [sprintf('%g kHz, ', frqcy),paramstring];
else
  recs = getfieldval(paramdata,'Records');
  if isempty(recs); recs = getfieldval(paramdata,'Number of data records');;end
  ylabels =[1:recs]';
  ylabelstring = 'Stimuli';
  intsty = getfieldval(paramdata,'dB'); intsty = intsty(1);
  paramstring = [sprintf('%d dB, ',intsty),paramstring];
 end
