function runclass=RunClassTable(ref,tar)

% Also, set the runclass:
if isempty(tar) && isempty(ref),
        runclass='NON';
elseif isempty(tar),
    
    switch  upper(get(ref,'descriptor'))
      case 'MORPHTORCTARC'
        runclass = 'MTT';
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
        case 'VBANDNOISE'
            runclass='VBN';       %varied Bandwidth bandpassed Noise -pby
        case 'SSA'
            runclass='SSA';       %varied Bandwidth bandpassed Noise -pby    
        case 'SPEECH'
            t = get(ref,'Subsets');
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
            t = get(ref,'LightSubset');
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
        case 'AMNOISE',
            runclass='AMN';
        case 'AMTONE',
            runclass='AMT';
        case {'NOISE','NOISEBAND'},
            runclass='NSE';
        case 'BIASEDSHEPARDPAIR'
            runclass='BSP';
        case 'BIASEDSHEPARDTUNING';
            runclass='BST';
        case 'SHEPARDTUNING'
            runclass='SHT';
        case 'SHEPARDPAIR';
            runclass='SHP';
        case 'RHYTHM'
            runclass='RHY';
        case 'FMSWEEP'
            runclass = 'FMS';
        case 'STREAMNOISE'
            runclass = 'SNS';
        case 'TONE'
            runclass = 'TON';
        case 'MASKTONE'
            runclass = 'MSK';
        case 'MONAURALHUGGINS'
            runclass = 'MHP';
        case 'MASKTONE'
            runclass = 'MSK';
        case 'REPTONE'
            runclass = 'BFG';
        case 'ALTTONESEQ';
            runclass = 'ATS';
      case 'PSYCHOLINGUISTICSTIMULI';
        runclass = 'PLS';
  
        otherwise
            runclass = '';
    end
else
        switch upper(get(tar,'descriptor'))
                case 'TARC'
            runclass = 'TAR';
        case 'CLICKDISCRIM'
            runclass = 'CLK';
        case 'TONE'
            if strcmpi(get(ref,'descriptor'),'NOISEBURST'),
                runclass = 'BVT';
            else
                runclass = 'PTD';
            end
        case 'MULTIPLETONES'
            runclass = 'MTD';
        case 'RANDOMTONE'
            runclass = 'RTD';
        case 'RANDOMMULTITONE'
            runclass = 'RMD';
        case 'TORCGAP'
            runclass = 'GAP';
        case 'TONEINTORC'
            runclass = 'VTL';
        case 'TONEINROVINGTORC'
            runclass = 'TRT';
        case 'TORCTONEDISCRIM'
            runclass = 'DIS';
        case 'TORCFMDISCRIM'
            runclass = 'TFD';
        case 'CLICK'
            runclass = 'CLT';  % Click detect(?)
        case 'AMTORC'
            runclass = 'AMT';
        case 'RANDOMAM'
            runclass = 'RAM';
        case 'MULTISTREAM';
            runclass = 'NON';
        case 'TORC'
            if strcmpi(get(ref,'descriptor'),'TSTUNING'),
                runclass = 'TST';
            else
                runclass = 'TOR';
            end
        case 'TSTUNING'
            runclass = 'TST';
        case 'VBANDNOISE'
            runclass='VBN';       %varied Bandwidth bandpassed Noise -pby
        case 'SSA'
            runclass='SSA';       %varied Bandwidth bandpassed Noise -pby
        case 'COMPLEXCHORD'
            try
                t = get(ref,'LightSubset');
                if isempty(t),
                    runclass = 'CCH';
                elseif strcmpi(get(ref,'descriptor'),'COMPLEXCHORD'),
                    runclass = 'LDS';
                else
                    runclass = 'ALM';
                end
            catch
                runclass='CCH';
            end
        case 'SILENCE'
            runclass = 'NON';
        case 'FMSWEEP'
            runclass = 'FMD';
        case 'MULTISOUND'
            runclass = 'MLS';
        case 'TONESEQUENCE'
            runclass= 'MTS';     %Tone Sequence - pby
        case 'NOISEBAND'
            runclass = 'BND';
        case 'AMFM'
            runclass = 'SIR';
        case 'COMPLEXTONE'
            runclass = 'CXT';
        case 'SINGLEDIGITS'
            runclass = 'DIG';
        case 'NOISEBURST'
            runclass = 'TVB';
        case 'AMNOISE',
            runclass='AMN';
        case 'BIASEDSHEPARDPAIR'
            runclass='BSP';
        case 'SPNOISERHYTHM'
            runclass='RDS';
        case 'RHYTHM'
            runclass='RDT';
        case 'SHEPARDTUNING'
            runclass='SHT';
        case 'SHEPARDPAIR';
            runclass='SHP';
        case 'MONAURALHUGGINS'
            runclass = 'MHP';
        case 'TRIPLET'
            runclass = 'TRP';
        case 'ROVINGTONE'
            runclass = 'ROT';
        case 'REPTONE'
            runclass = 'BFG';
        case 'TARGETSWITCH'
            runclass = 'SWC';
        case 'TONEVSFM'
            runclass = 'TVF';
        case 'SDWMTONE'
            runclass = 'WMD';
        case 'TARDURTONE'
            runclass = 'TDT';
        case 'ALTTONESEQ';
            runclass = 'ATS';
      case 'PSYCHOLINGUISTICSTIMULI';
        runclass = 'PLS';
        case 'RANDSEQTORC';
        runclass = 'RST';
        otherwise
            error('Enter a runclass into RunClassTable.m to avoid later confusion!');
    end
end
