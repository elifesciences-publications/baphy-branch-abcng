function loadequalizer(t,levels)

% loads the equalizer

eqzmax=readparams('eqzLevel'); % max value for each block
%find number of equalizer blocks
eqzblks=readparams('equalizer');
numeqz=length(eqzblks);
% get the levels for each equalizer blocks
for i=1:numeqz
    if eqzmax==12
        range=0;
    else
        range=1;
    end
    sendcommand(t,'set',eqzblks(i),'range',range);
    sendcommand(t,'restore','equalizer',i);
    val=abs(levels)-eqzmax*(i-1);
    val(find(val>eqzmax))=eqzmax;
    val(find(val<0))=0;
    val=readparams('level2index',eqzblks(i).desc,val.*sign(levels));
    sendcommand(t,'set',eqzblks(i),'freq','all',val);
    sendcommand(t,'set',eqzblks(i),'bypass',0);
end