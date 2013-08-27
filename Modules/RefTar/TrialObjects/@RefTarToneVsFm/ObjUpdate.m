function o = ObjUpdate (o)
%
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds

% Nima, november 2005
ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
if ~isempty(ref)
    ref = ObjUpdate(ref);
    o = set(o,'ReferenceHandle',ref);
    o = set(o,'ReferenceClass',class(ref));
    o = set(o,'ReferenceMaxIndex',get(ref,'MaxIndex'));
    o = set(o,'NumOfEvPerStim',3);
    o = set(o,'NumOfEvPerRef',3);
end
if ~isempty(tar)
    tar = ObjUpdate(tar);
    o = set(o,'TargetHandle',tar);
    o = set(o,'TargetClass',class(tar));
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    o = set(o,'NumOfEvPerTar',3);
    if isfield(get(tar),'NumOfEvPerTar')
        o = set(o,'NumOfEvPerTar',get(tar,'NumOfEvPerTar'));
    end
else
    o = set(o,'TargetClass','None');
end

% svd moved runclass functionality to a stand-alone command in the Config
% directory so that different trial objects can call the same function.
o = set(o,'RunClass', RunClassTable(ref,tar));

% % Also, set the runclass:
% if isempty(tar) || strcmpi(get(o,'TargetClass'),'none')
%     switch  upper(get(o,'ReferenceClass'))
%         case 'TORC'
%             runclass = 'TOR';
%         case 'PHONEME'
%             runclass = 'PHN';
%         case 'RANDOMTONE'
%             runclass = 'FTC';    % frequency tuning
%         case 'MULTIPLETONES'
%             runclass = 'MTP';    % frequency tuning
%         case 'TONESEQUENCE'
%             runclass= 'MTS';     %Tone Sequence - pby
%         case 'TSTUNING'
%             runclass= 'TST';     %Tone Sequence tuning - pby
%         case 'RANDTONESEQ'
%             runclass = 'RTS';    % long Random tone sequences - pby
%         case 'PFCSOUNDSET'
%             runclass = 'PFS';    %Pfc Screening sound set -pby
%         case 'MULTIRANGETASK'
%             runclass='MRD';      %multi-frequency-Range-Discrimination  - by pby
%         case 'SPEECH'
%             t = get(ref,'Subsets');
%             runclass = ['SP' num2str(t)];
%         case 'SPEECHLONG'
%             runclass = 'SPL';
%         case 'AMFM'
%             runclass = 'AFM';   % FM modulated AM
%         case 'CLICK'
%             runclass = 'CLT';  % Click rate tuning
%         case 'LEVELTUNING'
%             runclass = 'LTC';
%         case 'AMTORC'
%             runclass = 'AMT';
%         case 'RANDOMAM'
%             runclass = 'RAM';
%         case 'SPORC'
%             runclass = 'SPT';
%         case 'COMPLEXCHORD'
%             t = get(ref,'LightSubset');
%             if isempty(t),
%                 runclass = 'CCH';
%             else
%                 runclass = 'ALM';
%             end
%         case 'LIGHTENVELOPE';
%             runclass = 'LEV';
%         case 'SPNOISE';
%             runclass = 'SPN';
%         case 'SILENCE';
%             runclass = 'NON';
%         case 'FERRETVOCAL';
%             runclass = 'VOC';
%         case 'TORCGAP';
%             runclass = 'GAP';    
%         case 'FERRETVOCAL'
%             runclass = 'VOC';
%         case 'MOVINGSOA'
%             runclass = 'MSA';
%         case 'SOA'
%             runclass = 'SOA';
%         case 'NOISEBURST'
%             runclass = 'BNB';
%         case 'FREQLEVELTONE'
%             runclass = 'FLT';  
%         case 'COMPLEXTONE'
%             runclass = 'CXT'; 
%         case 'SINGLEDIGITS'
%             runclass = 'DIG';
%         case 'AMNOISE',
%             runclass='AMN';
%         case 'AMTONE',
%             runclass='AMT';
%         case {'NOISE','NOISEBAND'},
%             runclass='NSE';
%           case 'BIASEDSHEPARDPAIR'
%         runclass='BSP';
%           case 'RHYTHM'
%         runclass='RHY';
%         otherwise
%             runclass = '';
%     end
%     o = set(o,'RunClass', runclass);
% else
%     switch upper(get(o,'TargetClass'))
%         case 'CLICKDISCRIM'
%             runclass = 'CLK';
%         case 'TONE'
%             if strcmp(upper(get(o,'ReferenceClass')),'NOISEBURST'),
%                 runclass = 'BVT';
%             else
%                 runclass = 'PTD';
%             end
%         case 'MULTIPLETONES'
%             runclass = 'MTD';
%         case 'RANDOMTONE'
%             runclass = 'RTD';
%         case 'RANDOMMULTITONE'
%             runclass = 'RMD';
%         case 'TORCGAP'
%             runclass = 'GAP';
%         case 'TONEINTORC'
%             runclass = 'VTL';
%         case 'TORCTONEDISCRIM'
%             runclass = 'DIS';
%         case 'TORCFMDISCRIM'
%             runclass = 'TFD';
%         case 'CLICK'
%             runclass = 'CLT';  % Click rate tuning
%         case 'AMTORC'
%             runclass = 'AMT';
%         case 'RANDOMAM'
%             runclass = 'RAM';
%       case 'MULTISTREAM';
%         runclass = 'NON';
%         case 'TORC'
%             runclass = 'TOR';
%         case 'TONE'
%             runclass = 'TON';
%         case 'COMPLEXCHORD'
%             try,
%                 t = get(ref,'LightSubset');
%                 if isempty(t),
%                     runclass = 'CCH';
%                 elseif strcmp(upper(get(o,'ReferenceClass')),'COMPLEXCHORD'),
%                     runclass = 'LDS';
%                 else
%                     runclass = 'ALM';
%                 end
%             catch,
%                 runclass='CCH';
%             end
%         case 'SILENCE';
%             runclass = 'NON';
%         case 'FMSWEEP'
%             runclass = 'FMD';
%         case 'MULTISOUND'   
%             runclass = 'MLS';
%         case 'TONESEQUENCE'
%             runclass= 'MTS';     %Tone Sequence - pby
%         case 'NOISEBURST'
%             runclass = 'BNB';
%         case 'NOISEBAND'
%             runclass = 'BND';
%         case 'AMFM'
%             runclass = 'SIR'; 
%         case 'COMPLEXTONE'
%             runclass = 'CXT';
%         case 'SINGLEDIGITS'
%             runclass = 'DIG';
%         case 'NOISEBURST'
%             runclass = 'TVB';
%       case 'AMNOISE',
%         runclass='AMN';
%       case 'BIASEDSHEPARDPAIR'
%         runclass='BSP';
%       case 'SPNOISERHYTHM'
%         runclass='RDS';
%       case 'RHYTHM'
%         runclass='RDT';
%     end
%     o = set(o,'RunClass', runclass);
% end
