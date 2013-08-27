function stimparam = readinfo(t,exptdata)
% stimparam = readinfo(sigstruct)
% sigstruct.type
%           tag
%           handle
% exptdata
% Returns structure with the following fields:
%     numrecs   - number of records
%     mf        - multiplication factor
%     ddur      - data duration
%     stdur     - stimulus duration
%     stonset   - stimulus onset
%     lfreq     - low freq
%     hfreq     - high freq
%     a1am      - ripple amplitude (cell array of amplitudes of ripples)
%     a1ph      - ripple phases
%     a1rf      - ripple frequency
%     a1rv      - ripple velocity

stimparam.numrecs   = get(t.tag,'Index');
stimparam.mf        = round(get(exptdata,'AcqSamplingFreq')/1000);
onset = get(t.tag,'Onset');
delay = get(t.tag,'Delay');
duration = get(t.tag,'Duration');
stimparam.ddur      = round(1000*(onset+delay+duration));
stimparam.stdur     = round(1000*duration);
stimparam.stonset   = round(1000*onset);
stimparam.stdelay   = round(1000*delay);

torc_param  = t.handle(1);
stimparam.lfreq     = get(torc_param,'Lower frequency component');
stimparam.hfreq     = get(torc_param,'Upper frequency component');
stimparam.a1am{1}   = get(torc_param,'Ripple amplitudes');
stimparam.a1rf{1}   = get(torc_param,'Ripple frequencies');
stimparam.a1ph{1}   = get(torc_param,'Ripple phase shifts');
stimparam.a1rv{1}   = get(torc_param,'Angular frequencies');

for j = 2:stimparam.numrecs
    torc_param  = t.handle(j);
    stimparam.a1am{j} = get(torc_param,'Ripple amplitudes');
    stimparam.a1rf{j} = get(torc_param,'Ripple frequencies');
    stimparam.a1ph{j} = get(torc_param,'Ripple phase shifts');
    stimparam.a1rv{j} = get(torc_param,'Angular frequencies');
end;