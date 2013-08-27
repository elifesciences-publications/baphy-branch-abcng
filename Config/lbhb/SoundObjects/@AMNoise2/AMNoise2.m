function o = AMNoise2(varargin)
% AMnoise2 is the constructor for the object AMNoise2 which is a child of  
%       SoundObject class
%
% Run class: AMN (AN2?)
%
% SVD created 2013-03-22, based on AMNoise and SpNoise objects.
%
switch nargin
case {0,1}
    % if no input arguments, create a default object
    if nargin==1 && isa(varargin{1},'SoundObject')
       o = varargin{1};
       return;
    end
    
    s = SoundObject ('AMNoise2', 100000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',2,...
                  'LowFreq1','edit',250,...       
                  'HighFreq1','edit',8000,...
                  'AM1','edit',4,...
                  'LowFreq2','edit',250,...       
                  'HighFreq2','edit',8000,...
                  'AM2','edit',7,...
                  'ModDepth','edit',1,...
                  'SyncBands','popupmenu','No|Yes',...
                  'RelAttenuatedB','edit',0,...
                  'TonesPerOctave','edit',0,...
                  'UseBPNoise','edit',1,...
                  'SimultaneousCount','edit',1,...
                  });
    
    o.PreStimSilence=0.5;
    o.PostStimSilence=0.5;
    o.Duration = 3;
    o.LowFreq1 = 250;
    o.HighFreq1 = 8000;
    o.AM1=4;
    o.LowFreq2 = 250;
    o.HighFreq2 = 8000;
    o.AM2=7;
    o.SyncBands = 'No';
    o.RelAttenuatedB=0;
    o.ModDepth=0.9;
    o.TonesPerOctave=0;
    o.UseBPNoise=1;
    o.SimultaneousCount=1;
    o.IdxMtx=[];
    % if single argument of class SoundObject, return it
    if nargin==1 && isstruct(varargin{1}),
       % if structure, use it to create object, then fill empty
       % fields with defaults
       parms = varargin{1};
       ff=fields(parms);
       for ii=1:length(ff),
          o.(ff{ii})=parms.(ff{ii});
       end
    end
    
    o = class(o,'AMNoise2',s);
    o = ObjUpdate (o);
        
otherwise
    error('Wrong number of input arguments');
end