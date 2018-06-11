function [CommonRef,BanksByChannel] = evpread5commonref(FileName,NSteps,useCommonRef)
% Reads the commonreference data for a given file
% The filename passed to it, should be the one for which the reference is required

persistent LastNFiles LastFileName

FilePieces=strsep(FileName,'.',1);
FileNameBase = [ ];
for i=1:length(FilePieces)-3  FileNameBase = [FileNameBase,FilePieces{i},'.'];  end
FileNameMean = [FileNameBase,FilePieces{i+1},'.mean.bin'];

% FILE WERE READ DURING WRITING (CAUGHT IN EVPREAD)
if useCommonRef==-1 delete(FileNameMean); CommonRef = NaN; return; end

if ~strcmp(LastFileName,FileNameBase) LastNFiles = []; end

Force = useCommonRef == 2;

% NUMBER OF CHANNELS PER BANK (IN BLACKROCK SYSTEM)
NAv = 32; 

 if ~exist(FileNameMean,'file') | Force
   % GET CURRENT SET OF FILES
   FileNameMask=[FilePieces{1} '.' FilePieces{2} '.*.' FilePieces{4}];
   Files=dir(FileNameMask); NFiles = length(Files);
   [Basename,Path] = basename(FileNameMask);
   % SORT FILES
   ChannelNums = zeros(NFiles,1); StartPos = length(FileNameBase) + 5; % 3 for Trial, 2 for Periods
   for i=1:NFiles 
     cPos = find(Files(i).name=='.',2,'last');
     ChannelNums(i) = str2num(Files(i).name(cPos(1)+1:cPos(2)-1)); 
   end
   [tmp,SortInd] = sort(ChannelNums,'ascend');
   Files = Files(SortInd);
   
   % CHECK WHETHER A FILE IS MISSING
   if strcmp(LastFileName,FileNameBase) & ~isempty(NFiles) & NFiles ~= LastNFiles
     CommonRef = NaN; return;
   end
   LastNFiles = NFiles;
   LastFileName = FileNameBase;
   
   % DETERMINE AVERAGING INDICES
   AverageBySetsOf32 = (mod(NFiles,NAv)==0);
   switch AverageBySetsOf32
     case 1; % AVERAGE ONLY WITHIN BANKS
       NBanks = round(NFiles/NAv);
       for i=1:NBanks AverageInds{i} = [round((i-1)*NAv +1) : round(i*NAv)]; end
       BanksByChannel = repmat(1:ceil(NFiles/NAv),32,1);
       BanksByChannel = BanksByChannel(:);
       
     case 0; % AVERAGE ALL FILES
       NBanks = 1;
       AverageInds = {1:NFiles};
       BanksByChannel = repmat(1,NFiles,1);   
   end
   
   % LOAD FILES AND AVERAGE
   CommonRef = [];
   FID = fopen(FileNameMean,'w'); % ONLY ONE FILE, DIFFERENT MEANS APPENDED
   for iB = 1:NBanks % ITERATE OVER BANKS     
     for iA=1:length(AverageInds{iB}) % ITERATE OVER CHANNELS PER BANK
       tmp = single(evpread5([Path Files(AverageInds{iB}(iA)).name]));
       if iA==1  cCommonRef = zeros([size(tmp,1),length(AverageInds{iB})],'single'); end
       % CHECK WHETHER WE ARE IN THE PROGRESS OF RECORDING
       if length(tmp) == length(cCommonRef) % everything OK
         cCommonRef(:,iA) = tmp;
       else % Signal to caller to stop here
         cCommonRef = NaN; return;
       end
     end
     cCommonRef=median(cCommonRef,2);
     fwrite(FID,cCommonRef,'single');
     CommonRef = [CommonRef,cCommonRef];
     
   end
   fclose(FID);
   
 else % JUST READ COMMON REFERENCE
   FID = fopen(FileNameMean,'r');
   CommonRef = fread(FID,inf,'single');
   NBanks = round(length(CommonRef)/NSteps);
   CommonRef = reshape(CommonRef,NSteps,NBanks);
   if NBanks == 1 % ASSUME AVERAGING OVER ALL
     BanksByChannel = ones(96,1);
   else % ASSUME THERE IS NBanks * NAv Channels
     BanksByChannel = repmat(1:NBanks,NAv,1);
     BanksByChannel = BanksByChannel(:);
   end
   fclose(FID);
 end
end