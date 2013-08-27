function Lick = IOLickRead(HW,LickNames)
% function Lick = IOLickRead (HW,LickName)
%
% This function reads the lick signal from the daq card and return it in l
% if global.LickSign is one, the function return one if the DI is one,
% otherwise, it returns one when the DIO is zero.
%
% Nima, November 2005
% SVD, 2005-11-20 - generic recording setup support
% SVD, 2006-02-17 - support for new training setup with m-series daq card
% SVD, 2006-02-21 - removed m-series daq card support
% BE, 2010/7 - integrate multiple lick support.
% SVD update 2012-05-31 : added Nidaqmx support

if ~exist('LickNames','var') LickNames = {'Touch'}; end
if ~iscell(LickNames) && ischar(LickNames) LickNames = {LickNames}; end

switch HW.params.HWSetup
  case 0     % Test mode
      global BAPHYHOME TOUCHSTATE0
      TestFile=[BAPHYHOME filesep 'Config' filesep 'BaphyTestSettings.mat'];
      if exist(TestFile,'file'),
          g=[];
          cc=0;
          while cc<5 && isempty(g),
              try
                  g=load(TestFile);
                  TOUCHSTATE0=g.TOUCHSTATE0;
              catch
                  disp('error loading test licks. trying again');
              end
          end
          Lick=TOUCHSTATE0;
      else
          %     Lick = TOUCHSTATE0; Lick = rand(size(LickNames))<0.01;
          Lick=1;
      end
  otherwise % Real setups
    % finds appropriate digital line based on the name
    if strcmpi(IODriver(HW),'NIDAQMX'),
      if isnumeric(LickNames),
        LickIndices=LickNames;
      else
        dnames={HW.Didx.Name};
        LickIndices=zeros(size(LickNames));
        for ii=1:length(LickNames),
          jj=find(strcmp(LickNames{ii},dnames), 1 );
          if ~isempty(jj),
            LickIndices(ii)=jj;
          end
        end
      end
        
      Lick=zeros(size(LickNames));
      lasttask=0;
      for ii=1:length(LickIndices),
        if LickIndices(ii)>0,
          if lasttask~=HW.Didx(LickIndices(ii)).Task,
            lasttask=HW.Didx(LickIndices(ii)).Task;
            v=niGetValue(HW.DIO(lasttask));
          end
          Lick(ii)=v(HW.Didx(LickIndices(ii)).Line);
        end
      end
    else
      if isnumeric(LickNames)
        LickIndices = LickNames;
      else
        for i=1:length(LickNames)
          LickIndices(i)=find(strcmp(HW.DIO.Line.LineName,LickNames{i}));
        end
      end
      Lick = getvalue(HW.DIO.Line(LickIndices));
    end
    TOUCHSTATE0=Lick;
end

if isfield(HW.params,'LickSign') & HW.params.LickSign == -1 % invert the signal
  Lick = ~Lick;
end

