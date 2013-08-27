DTotalSamplesRead=length(DData(:));
DSamplesRead=DTotalSamplesRead;
ATotalSamplesRead=0;
LoopIteration=0;
AData=[];
DData=double(DData);

PacketLength=1200;

NumberOfChannels = 96;
  Bundles = 32;
  ChannelsPerBundle = 3;
  BitsPerBundle = 36;
  Header = [0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1];
  HeaderLength = length(Header);
  FlagLength = 8;
  DataOffset = HeaderLength + FlagLength;
  cStart=0;
  DataStart=0;
  PacketStart=0;
  IterationStart = DTotalSamplesRead - DSamplesRead; % Jumps back to the first entry in the current Iteration
  %ViInt32 i1, i2, EqCount, AOffset, Offset;
  PacketsThisIteration = floor(DSamplesRead/PacketLength);
  HeaderFound = 0;
  %ViUInt32 cATotalSamplesRead;
  
  fprintf('\tEntering Decoder (DSample : %d, ASample : %d)...\n',IterationStart,ATotalSamplesRead);
  % Find Last/Next Header
  if (LoopIteration), % Search Backward
    for i1=1:PacketLength,
      EqCount = 0;
      for i2=1:HeaderLength,
        if DData(IterationStart-i1+i2) == Header(i2),
          EqCount=EqCount+1;
        end
      end
    end
    if EqCount == HeaderLength,
      Offset = -i1;
      HeaderFound = 1; 
      break;
    end
  else % SearchForward
    for i1=1:PacketLength,
      EqCount = 0;
      for i2=1:HeaderLength,
        if DData(IterationStart+i1+i2)==Header(i2),
          EqCount=EqCount+1;
        end
        if EqCount == HeaderLength,
          Offset = i1;
          HeaderFound = 1;
          PacketsThisIteration=PacketsThisIteration-1;
          break;
        end
      end
    end
  end
  
  if (~HeaderFound) 
    fprintf('\tHeader not found!!\n');
  else
    fprintf('\tHeader found at %d\n',Offset);
  end  
  
  % Recode Packages from the last header
  PacketStart = IterationStart + Offset; 
  for i1=1:PacketsThisIteration,
    DataStart = PacketStart + DataOffset;
    for i2=1:Bundles, % Loop over the Bundles in the data section in a packet
      cStart = DataStart + (i2-1)*BitsPerBundle+1;
      cATotalSamplesRead = (i1-1)+ATotalSamplesRead;
      AOffset = cATotalSamplesRead*NumberOfChannels + (i2-1)*3+1;
      AData(AOffset)     = -2048*DData(cStart)     + 1024*DData(cStart+3) + 512*DData(cStart+6) + 256*DData(cStart+9)   + 128*DData(cStart+12) + 64*DData(cStart+15) + 32*DData(cStart+18) + 16*DData(cStart+21) + 8*DData(cStart+24) + 4*DData(cStart+27) + 2*DData(cStart+30) + 1*DData(cStart+33);
      AData(AOffset+1) = -2048*DData(cStart+1) + 1024*DData(cStart+4) + 512*DData(cStart+7) + 256*DData(cStart+10) + 128*DData(cStart+13) + 64*DData(cStart+16) + 32*DData(cStart+19) + 16*DData(cStart+22) + 8*DData(cStart+25) + 4*DData(cStart+28) + 2*DData(cStart+31) + 1*DData(cStart+34);
      AData(AOffset+2) = -2048*DData(cStart+2) + 1024*DData(cStart+5) + 512*DData(cStart+8) + 256*DData(cStart+11) + 128*DData(cStart+14) + 64*DData(cStart+17) + 32*DData(cStart+20) + 16*DData(cStart+23) + 8*DData(cStart+26) + 4*DData(cStart+29) + 2*DData(cStart+32) + 1*DData(cStart+35);
     % AData(AOffset)     = sign(DData(cStart)-0.5)    .*( 1024*DData(cStart+3) + 512*DData(cStart+6) + 256*DData(cStart+9)   + 128*DData(cStart+12) + 64*DData(cStart+15) + 32*DData(cStart+18) + 16*DData(cStart+21) + 8*DData(cStart+24) + 4*DData(cStart+27) + 2*DData(cStart+30) + 1*DData(cStart+33));
      %AData(AOffset+1) = sign(DData(cStart+1)-0.5) .*( 1024*DData(cStart+4) + 512*DData(cStart+7) + 256*DData(cStart+10) + 128*DData(cStart+13) + 64*DData(cStart+16) + 32*DData(cStart+19) + 16*DData(cStart+22) + 8*DData(cStart+25) + 4*DData(cStart+28) + 2*DData(cStart+31) + 1*DData(cStart+34));
      %AData(AOffset+2) = sign(DData(cStart+2)-0.5) .*(1024*DData(cStart+5) + 512*DData(cStart+8) + 256*DData(cStart+11) + 128*DData(cStart+14) + 64*DData(cStart+17) + 32*DData(cStart+20) + 16*DData(cStart+23) + 8*DData(cStart+26) + 4*DData(cStart+29) + 2*DData(cStart+32) + 1*DData(cStart+35));
    end
    PacketStart = PacketStart + PacketLength;
  end
  
  ATotalSamplesRead = ATotalSamplesRead + PacketsThisIteration;
  A=reshape(AData,NumberOfChannels,ATotalSamplesRead)';
  B=reshape(A,size(A,1),3,32);
  B=permute(B,[1 3 2]);
  B=B(:,:);

  % After de-interleaving channels from A to B:
  %Channels 1-32: Center pin set
  %Channels 33-64: In front of omnetics face on center pin set
  %Channels 65-96: Behind omnetics face on center pin set
  