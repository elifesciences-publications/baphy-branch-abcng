function out=config(action,varargin)



if nargin<1
    action='init';
end

switch lower(action)
    case 'rootpath'
        out = 'F:\Users\alphaomega\code';
    case 'codepath' % the
        out = 'F:\Users\alphaomega\code\behavior';
    case 'datapath' % where data from expt will be stored
        out = 'W:';
    case 'localdata' % local data folder; needed in alphaomega system
        out = 'F:\Users\alphaomega\data';
    case 'wfmpath' % where all stored wfms are placed
        out = 'F:\Users\alphaomega\code\daqpcbank';
    case 'mapfpath' % the drive mapping for map files to be used in alphaomega commands
        out = 'W:\';    
    case 'calibration' % calibration file
        out = 'F:\Users\alphaomega\code\behavior\daqhw\calibration_map.mat';
    case 'fs_spike' % spike sampling rate
        out=25000;
    case 'fs_touch' % touch sampling rate
        out=1000;
    case 'mf' % fs.spike/1000
        out=25;
    case 'completestim' % stimulus for which spikes corresponding to [onset;duration;delay] are stored; used in old setup
        out = {'tonetable','toneloud','rippletable','combtable','gwnoisetable',...
            'misclicktable','ripplesent','ripplespeech'};
    case 'rasterstim' % stimulus for which raster display is needed
        out = {'tonetable','toneloud','combtable','gwnoisetable','misclicktable',...
            'ripplesent','ripplespeech'};
    case 'abastim' % aba category of stimulus
        out = {'complexABAtable','streamABtable'};
    case 'signals'
        if nargin<2     % user requested default settings
            out.Duration=1.5;
            out.Onset=0.7;
            out.Delay=0.4;
        else % get the default values for various signals
            switch lower(varargin{1})
                case {'tone-single','tone-level'}
                    out.Duration=0.3;
                    out.Onset=0.5;
                    out.Delay=0.5;
                case {'torc-nima','serin-sent','torc','torctone',...
                        'harmtorc','torc+sweep'}
                    out.Duration=3.0;
                    out.Onset=1.5970;
                    out.Delay=0.4;
                case 'supertorc'
                    out.Duration=4.0;
                    out.Onset=1.5970;
                    out.Delay=0.4;
                case 'torc + static ripple'
                    out.Duration=3.0;
                    out.Onset=0;
                    out.Delay=0;
                case 'fasttorc'
                    out.Duration=1.5;
                    out.Onset=0;
                    out.Delay=0;
                case 'complex-tone'
                    out.Duration=0.5;
                    out.Onset=0.45;
                    out.Delay=0.05;
                case 'modulated complex-tone'
                    out.Duration=1.0;
                    out.Onset=0.45;
                    out.Delay=0.05;
                case 'serin-stim'
                    out.Duration=1.0;
                    out.Onset=0.2;
                    out.Delay=0.2;
                case 'comb'
                    out.Duration=10.0;
                    out.Onset=0.4;
                    out.Delay=0.7;
                case 'misclick-nicol'
                    out.Duration=10.0;
                    out.Onset=0.4;
                    out.Delay=0.7;
                otherwise
                    out.Duration=1.5;
                    out.Onset=0.7;
                    out.Delay=0.4;
            end % end switch
        end % end if nargin<2
    case 'touch' % touchcron object
        out.OnsetStart=0.0;
        out.OnsetStop=1.0;
        out.OnsetFraction=0.05;
        out.DelayStart=0.4286;%0.2857,...% 2/27/03 from 0.2857
        out.DelayStop=1.000;%0.8571,...% 2/27/03 from 0.8571
        out.DelayFraction=0.05;
    case 'newtouch' % touchcron for newtouch daqpc
        out.OnsetStart=0.0;
        out.OnsetStop=1.0;
        out.OnsetFraction=0.05;
        out.DelayStart=0.4286;%0.2857,...% 2/27/03 from 0.2857
        out.DelayStop=1.000;%0.8571,...% 2/27/03 from 0.8571
        out.DelayFraction=0.05;
        out.SignalStart=0.0;
        out.SignalStop=1.0;
        out.SignalFraction=0.05;
    case 'hpmux' % settings for HP Mux
        if nargin<3
            chan=['001'];
        else
            chan=varargin{2};
        end
        if nargin<2
            out = '*RST';
        else switch lower(varargin{1})
                case 'reset'
                    out='*RST';
                case 'close'
                    out=['CLOSE (@' chan(3) chan(2) chan(1) ')'];
                case 'open'
                    out=['OPEN (@' chan(3) chan(2) chan(1) ')'];
                case 'view'
                    out=['VIEW (@' chan(3) chan(2) chan(1) ')'];
            end % end of switch
        end% end if nargin<2
    case 'attenuator'
        if nargin<2
        else
        end
    case 'khfilter'
        if nargin<2
        else
        end
    case 'equalizer'
        out='128.8.110.200';    %Changed from 128.8.140.162 on 8/12/05 by PY & CL
    case 'aichannels'
        if nargin<2
            mode='behavior';
        else
            mode=varargin{1};
        end
        if nargin<3
            chan=1;
        else
            chan=varargin{2};
        end
        switch lower(mode)
            case 'behavior'
                out={'Touch'};
            case 'passive'
                for i=1:chan
                    out{i}=['Spike' num2str(i)];
                end
            case 'behavior&physiology'
                out{1}='Touch';
                for i=1:chan
                    out{i+1}=['Spike' num2str(i)];
                end
        end
end % end switch


