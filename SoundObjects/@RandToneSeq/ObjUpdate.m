function o = ObjUpdate (o);
% Update the changes of a Stream_AB object
% Pingbo, December 2005
% modified in Aprul, 2006

Type=lower(get(o,'Type'));
if strcmpi(Type(1),'f')
    o=set(o,'Type','FixedStep');
elseif strcmpi(Type(1),'m')    %under construction
    o=set(o,'Type','MultiStep');
elseif strcmpi(Type(1),'s')    %two chrods sequence from Daniel Pressnitzer
    o=set(o,'Type','Seq_Daniel');
elseif strcmpi(Type(1),'n')    %two chrods sequence from Daniel Pressnitzer
    o=set(o,'Type','New_Daniel');
elseif strcmpi(Type,'addstream')
    o=set(o,'Type','AddStream'); %add a tone stream
elseif strcmpi(Type,'addstream2')
    o=set(o,'Type','AddStream2'); %add a tone stream    
elseif strcmpi(Type(1),'r')
    o=set(o,'Type','RShepard'); %sequence use using Roger Shepard tones
elseif strcmpi(Type(1),'o')
    o=set(o,'Type','oddball2'); %two vaiables oddball sequence
elseif strcmpi(Type(1),'3')
    o=set(o,'Type','3stream'); %two vaiables oddball sequence
else
    error('Wrong Type!!! Stim Type must be: ''PsudoRand,Rand''');
end
Type=get(o,'Type');
if strcmpi(Type,'3stream')
      %frist 2 elements was the frequency of tone streams, 
      %3th element- the 3rd stream (1 -light, non zero-tone stream frequency
      strms=get(o,'CenterFrequency');
      if length(strms)==1
          strms=[strms strms*2 1]; 
          o=set(o,'CenterFrequency',strms);
      end
      Names{1}=sprintf('%d %d %d %d',strms(1:2),0,0);  %2 stream
      for i=3:length(strms)
          Names{end+1}=sprintf('%d %d %d %d',strms([1 2 i]),1);  %synchroniing with 1st tone stream
          Names{end+1}=sprintf('%d %d %d %d',strms([1 2 i]),2);  %synchroniing with 2nd tone stream
      end
      MaxIndex=length(Names);
elseif strcmpi(Type,'oddball2')  %three vaiables oddball sequence (freq,Amp,dur)
    Names{1}='FAD_f10AD+Fa10D+FAd10';   % 10 likelyhood for deviant
    Names{2}='fAD_F10AD+fa10D+fAd10';   % 10 likelyhood for deviant
    Names{3}='FaD_f10aD+FA10D+Fad10';   % 10 likelyhood for each deviant
    Names{4}='FAd_f10Ad+Fa10d+FAD10';   % 10 likelyhood for each deviant
    
    Names{5}='FAD_f10AD';        % 10 likelyhood for each deviant
    Names{6}='FAD_f30AD';        % 30 likelyhood for each deviant
    Names{7}='FAD_Fa10D';        % 10 likelyhood for each deviant
    Names{8}='FAD_Fa30D';        % 30 likelyhood for each deviant
    Names{9}='FAD_FAd10';        % 10 likelyhood for each deviant
    Names{10}='FAD_FAd30';       % 30 likelyhood for each deviant
    
    Names{11}='fAD_F10AD';        % 10 likelyhood for each deviant    
    Names{12}='fAD_F30AD';       % 30 likelyhood for each deviant   
    Names{13}='FaD_FA10D';       % 10 likelyhood for each deviant    
    Names{14}='FaD_FA30D';       % 30 likelyhood for each deviant
    Names{15}='FAd_FAD10';       % 10 likelyhood for each deviant
    Names{16}='FAd_FAD30';       % 30 likelyhood for each deviant
    MaxIndex=length(Names);
elseif strcmpi(Type,'New_Daniel')  %two sequence
    Names{1}='up';   %up sequence
    Names{2}='dw';   %down seq
    Names{3}='rd';   %random seq
    Names{4}='upr';   %up sequence (reversed)
    Names{5}='dwr';   %down seq (reversed)
    Names{6}='rdr';   %random seq (reversed)
    Names{7}='sig';   %single chrod 
    MaxIndex=length(Names);
    %o=set(o,'SamplingRate',44100);
elseif strcmpi(Type,'Seq_Daniel')  %two sequence
    fn=dir([fileparts(which('randToneSeq')) '\sounds\*.wav']);
    Names=cellstr(char(fn.name));
    Names{3}='seq1_Last3Rep';
    Names{4}='seq2_Last3Rep';
    Names{5}='seq1_Last2Rep';
    Names{6}='seq2_Last2Rep';
    Names{7}='LastRep';
    MaxIndex=length(Names);
    %o=set(o,'SamplingRate',44100);
elseif strcmpi(Type,'RShepard') % 3 seq (ascending, descending, random)
    MaxIndex=3;
    Names=cellstr(num2str([1:3]'));
    o=set(o,'NoteDur',0.125);    %fixed note duration, sampling rate, and notenum
    %o=set(o,'SamplingRate',44100);
    num=get(o,'NoteNumber');
    o=set(o,'NoteNumber',ceil(num/12)*12);
    %o=set(o,'NoteGap',0.125);
else
    fs = get(o,'SamplingRate');
    Frequency = get(o,'CenterFrequency');
    range=get(o,'SemiToneRange');
    if fs<(Frequency*2)*2^(max(range)/12)
        o=set(o,'SamplingRate',ceil((Frequency*4)*2^(max(range)/12))); end
%     NoteDur= get(o,'NoteDur');
%     NoteGap = get(o,'NoteGap');
    step=get(o,'SemiToneStep');
    step=min(range):step:max(range);
    MaxIndex=length(step);
    for i=1:MaxIndex
        Names{i}=num2str(round([Frequency*2^(step(i)/12)]));
    end
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',MaxIndex);
