function info = setfilter(t,varargin)
% info = setfilter('Channels',channelnum,...
%       'Frequency',freq,...
%       'InputGain',ipgain,...
%       'OutputGain',opgain);
% Sets the filter values. Frequency is always specified in Hz and gain in dB
%
% Usage:
%   info = setfilter(t); returns info regarding Channels as channel specs
%
%   info = setfilter(t,'Info'); same as above
%
%   setfilter(t,'Mode','ac'); sets filter coupling to AC
%
%   setfilter(t,'Channels','All','Freq',2000,...); Changes the filter specs for
%   all channels and returns info
%
%   setfilter(t,'Channels',[1 2],'Freq',2000,...);Changes the filter specs for
%   channels 1 and 2 only and returns info for all

if nargin<1
    error('sorry atleast one input required');
end;

if ~isa(t,'khfilter')
    error('first input must be KHFILTER class');
end;
delim = ';';

status1 = get(t.gpib,'Status');
if strcmpi(status1,'Open')
    fclose(t.gpib);
end;
fopen(t.gpib);

info = updateSpecs(t);
%info = t.ChannelSpecs;
if nargin<2
    return;
elseif strcmpi('info',varargin{1}),
    return;
elseif rem(nargin-1,2)
    error('Property - Values must come in pairs');
elseif strcmpi(varargin{1},'Coupling')
    if strcmp(varargin{2},'ac')
        command = 'AC';
    else
        command = 'D';
    end;
    return;
elseif nargin>=3
    inargs = varargin(1:2:end);
    invals = varargin(2:2:end);
    n = find(strcmpi(inargs(:),'Channels'));
    if isempty(n)|strncmpi(invals{n},'All',2)
        command = 'AL ';
        inargs(n)=[];
        invals(n)=[];
        n = length(inargs);
        for i = 1:n
            switch lower(inargs{i})
                case {'frequency','freq','f','hz','h'}
                    for chin = 1:2:4
                        tmpcommand = ['CH' num2str(chin)];
                        curfreq = info(1,chin);
                        decadechk = max(floor(log10(curfreq))-floor(log10(invals{i})));
                        if decadechk>=2
                            for din = decadechk:-1:2
                                tmpinval = invals{i}*(10^(din-1));
                                freqstr = [num2str(getfreq(t,tmpinval)) 'F'];
                                fprintf(t.gpib,[tmpcommand delim freqstr]);
                            end;
                        elseif decadechk<=-2
                            for din = -decadechk:-1:2
                                tmpinval = invals{i}/(10^(din-1));
                                freqstr = [num2str(getfreq(t,tmpinval)) 'F'];
                                fprintf(t.gpib,[tmpcommand delim freqstr]);
                            end;
                        end;
                        tmpcommand = [tmpcommand delim num2str(getfreq(t,invals{i})) 'F' ];
                        fprintf(t.gpib,tmpcommand);
                        pause(0.05)
                    end;
                    command = [command delim num2str(getfreq(t,invals{i})) 'F' ];
                case {'inputgain','ig'}
                    command = [command delim 'IG' num2str(getig(t,invals{i}))];
                case {'outputgain','og'}
                    command = [command delim 'OG' num2str(getog(t,invals{i}))];
            end;
        end;
    else
        channum = invals{n};
        inargs(n)=[];
        invals(n)=[];
        command = '';
        n1 = length(inargs);
        for j = 1:length(channum)
            command = [command delim 'CH' num2str(channum(j))];
            for i = 1:n1
                switch lower(inargs{i})
                    case {'frequency','freq','f','hz','h'}
                        tmpcommand = ['CH' num2str(channum(j))];
                        curfreq = info(1,channum(j));
                        decadechk = floor(log10(curfreq))-floor(log10(invals{i}(j)));
                        if decadechk>1
                            for din = decadechk:-1:1
                                tmpinval = invals{i}(j)*(10^(din-1));
                                tmpcommand = [tmpcommand delim num2str(getfreq(t,tmpinval)) 'F'];
                                fprintf(t.gpib,tmpcommand);
                            end;
                        elseif decadechk<=-2
                            for din = -decadechk:-1:2
                                tmpinval = invals{i}/(10^(din-1));
                                freqstr = [num2str(getfreq(t,tmpinval)) 'F'];
                                fprintf(t.gpib,[tmpcommand delim freqstr]);
                            end;
                        end;
                        command = [command delim num2str(getfreq(t,invals{i}(j))) 'F'];
                        pause(0.01)
                    case {'inputgain','ig'}
                        command = [command delim 'IG' num2str(getig(t,invals{i}(j)))];
                    case {'outputgain','og'}
                        command = [command delim 'OG' num2str(getog(t,invals{i}(j)))];
                end;
            end;
        end;
        command(1) = '';
    end;
end;


fprintf(t.gpib,command);
pause(0.005)
idn = fscanf(t);
info = updateSpecs(t);
fclose(t.gpib);
if strcmpi(status1,'Open')
   fopen(t.gpib); 
end;

function f = getfreq(t,ip)
tmp1 = log10(ip);
tmp2 = floor(tmp1);
tmp1 = tmp1-tmp2;
tmp1 = floor(10^(tmp1+1));
f = tmp1*(10^(tmp2-1));

function i = getig(t,ip)
tmp1 = [0 10 20 30 40];
tmp2 = floor((ip-tmp1)/10);
i = tmp1(max(find(tmp2==0)));

function o = getog(t,ip)
tmp1 = [0 10 20];
tmp2 = floor((ip-tmp1)/10);
o = tmp1(max(find(tmp2==0)));  