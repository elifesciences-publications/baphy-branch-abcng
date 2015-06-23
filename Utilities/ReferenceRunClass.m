function runclass=ReferenceRunClass(descriptor, ref)

switch upper(descriptor),
  case 'TORC'
    runclass = 'TOR';
  case 'PHONEME'
    runclass = 'PHN';
  case 'RANDOMTONE'
    runclass = 'FTC';    % frequency tuning
  case 'MULTIPLETONES'
    runclass = 'MTP';    % frequency tuning
  case 'TONESEQUENCE'
    runclass= 'MTS';     %Tone Sequence - pby
  case 'TSTUNING'
    runclass= 'TST';     %Tone Sequence tuning - pby
  case 'RANDTONESEQ'
    runclass = 'RTS';    % long Random tone sequences - pby
  case 'PFCSOUNDSET'
    runclass = 'PFS';    %Pfc Screening sound set -pby
  case 'MULTIRANGETASK'
    runclass='MRD';      %multi-frequency-Range-Discrimination  - by pby
  case 'SPEECH'
    if isstruct(ref),
      t=ref.Subsets;
    else
      t = get(ref,'Subsets');
    end
    runclass = ['SP' num2str(t)];
  case 'SPEECHLONG'
    runclass = 'SPL';
  case 'AMFM'
    runclass = 'AFM';   % FM modulated AM
  case 'CLICK'
    runclass = 'CLT';  % Click rate tuning
  case 'LEVELTUNING'
    runclass = 'LTC';
  case 'AMTORC'
    runclass = 'AMT';
  case 'RANDOMAM'
    runclass = 'RAM';
  case 'SPORC'
    runclass = 'SPT';
  case 'COMPLEXCHORD'
    if isstruct(ref),
      t=ref.LightSubset;
    else
      t = get(ref,'LightSubset');
    end
    if isempty(t),
      runclass = 'CCH';
    else
      runclass = 'ALM';
    end
  case 'LIGHTENVELOPE';
    runclass = 'LEV';
  case 'SPNOISE';
    runclass = 'SPN';
  case 'SILENCE';
    runclass = 'NON';
  case 'FERRETVOCAL';
    runclass = 'VOC';
  case 'TORCGAP';
    runclass = 'GAP';
  case 'FERRETVOCAL'
    runclass = 'VOC';
  case 'MOVINGSOA'
    runclass = 'MSA';
  case 'SOA'
    runclass = 'SOA';
  case 'NOISEBURST'
    runclass = 'BNB';
  case 'FREQLEVELTONE'
    runclass = 'FLT';
  case 'COMPLEXTONE'
    runclass = 'CXT';
  case 'SINGLEDIGITS'
    runclass = 'DIG';
  case 'BIASEDSHEPARDPAIR'
    runclass = 'BSP';
  case 'TEXTUREMORPHING'
    runclass = 'TMG';    
  otherwise
    runclass = '';
end
