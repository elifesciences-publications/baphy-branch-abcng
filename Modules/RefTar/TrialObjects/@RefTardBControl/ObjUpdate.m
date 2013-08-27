function o = ObjUpdate (o)
%
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds

% Serin Atiani 2008
ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
if ~isempty(ref)
    ref = ObjUpdate(ref);
    o = set(o,'ReferenceHandle',ref);
    o = set(o,'ReferenceClass',class(ref));
    o = set(o,'ReferenceMaxIndex',get(ref,'MaxIndex'));
    [w,e] = waveform(ref,1);
    o = set(o,'NumOfEvPerStim',length(e));
    o = set(o,'NumOfEvPerRef',length(e));
end
if ~isempty(tar)
    tar = ObjUpdate(tar);
    o = set(o,'TargetHandle',tar);
    o = set(o,'TargetClass',class(tar));
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    [w,e] = waveform(tar,1);
    o = set(o,'NumOfEvPerTar',length(e));
else
    o = set(o,'TargetClass','None');
end

% Also, set the runclass:
if isempty(tar) || strcmpi(get(o,'TargetClass'),'none')
    switch  upper(get(o,'ReferenceClass'))
        case 'TORC'
            runclass = 'TOR';
        case 'PHONEME'
            runclass = 'PHN';
        case 'RANDOMTONE'
            runclass = 'FTC';    % frequency tuning
        case 'MULTIPLETONES'
            runclass = 'MTP';    % frequency tuning
        case 'TSTUNING'
            runclass= 'TST';  %Tone Sequence tuning
        case 'RANDTONESEQ'
            runclass = 'RTS';    % long Random tone sequences
        case 'SPEECH'
            t = get(ref,'Subsets');
            runclass = ['SP' num2str(t)];
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
            runclass = 'CCH';
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
        otherwise
            runclass = '';
    end
    o = set(o,'RunClass', runclass);
else
    switch upper(get(o,'TargetClass'))
        case 'CLICKDISCRIM'
            runclass = 'CLK';
        case 'TONE'
            runclass = 'PTD';
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
        case 'TORCTONEDISCRIM'
            runclass = 'DIS';
        case 'CLICK'
            runclass = 'CLT';  % Click rate tuning
        case 'AMTORC'
            runclass = 'AMT';
        case 'RANDOMAM'
            runclass = 'RAM';
        case 'TORC'
            runclass = 'TOR';
        case 'TONE'
            runclass = 'TON';
        case 'COMPLEXCHORD'
            runclass = 'CCH';
        case 'SILENCE';
            runclass = 'NON';
        case 'FMSWEEP'
            runclass = 'FMD';

    end
    o = set(o,'RunClass', runclass);
end
