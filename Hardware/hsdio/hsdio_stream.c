/*=================================================================
 HSDIO test script based on ContinuousAcquisition-StreamToMemory.c
 example program 
 *=================================================================*/
//include <math.h>
#include <time.h>
//include "mex.h"
//include <conio.h>
//include <windows.h>

/* from ContinuousAcquisition */
#include <stdio.h>
#include "niHSDIO.h"

/* Defines */
//#define WAVEFORM_SIZE 100000
#define DEBUG 1

/* DECLARE INITIALLIZATION FUNCTIONS */
ViStatus setupGenerationDevice (ViRsrc genDeviceID, ViConstString genChannelList, ViConstString sampleClockOutputTerminal,
        ViReal64 sampleClockRate, ViConstString dataActiveEventDestination, ViConstString startTriggerSource, ViInt32 StartTriggerEdge,
        ViUInt16 *waveformData,ViConstString waveformName, ViSession *genViPtr);

ViStatus setupAcquisitionDevice (ViRsrc acqDeviceID, ViConstString acqChannelList, ViConstString sampleClockSource,
        ViReal64 sampleClockRate,  ViUInt32 SamplesToRead, ViConstString startTriggerSource, ViInt32 StartTriggerEdge, ViSession *genViPtr);

void decodeData(ViUInt8 *DData,ViInt16 *AData,
        ViUInt32 DTotalSamplesRead, ViUInt32 DSamplesRead, 
        ViUInt32 *ATotalSamplesRead, ViUInt32 *ASamplesRead, 
        ViUInt32 Bits, ViInt32 PacketLength,ViUInt32 LoopIteration);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int getdata(ViUInt8 *DData, ViInt16 *AData, ViUInt32 DSamplesToRead, ViUInt32 LoopIterations, ViReal64 SampleClockRate) {
  ViRsrc deviceID = "D1";
  
  /* ACQUISITION PARAMETERS */
  ViConstString acqChannelList = "0";
  ViSession vi = VI_NULL;
  ViUInt32 readTimeout = (ViInt32) (DSamplesToRead/SampleClockRate*1000+10000); /* milliseconds */
  ViUInt32 dataWidth = 1;
  ViUInt32 BackLogSamples;
  ViUInt32 DSamplesRead = 0;
  ViUInt32 ASamplesRead = 0;
  ViUInt32 DTotalSamplesRead = 0;
  ViUInt32 ATotalSamplesRead = 0;
  ViUInt32 ASamplesWritten = 0;
  ViUInt32 ATotalSamplesWritten = 0;
  ViInt32 PacketLength, Bits = 12;
  clock_t time1, time2;
  float ExpectedTimeToPass;
  float TimePassed;
  
  
  FILE *DataFile;
  //ViUInt32 Buf_Size;
  //TCHAR szName[]=TEXT("Global\\MESKAtemp");

  /* GENERATION PARAMETERS */
  ViConstString genChannelList = "1";
  ViSession genVi = VI_NULL;
  ViInt32 msTimeout = (ViInt32) (DSamplesToRead/SampleClockRate*1000+10000);
  ViConstString GenTriggerTerminal = NIHSDIO_VAL_PFI1_STR; // Generation triggered by external trigger, sends trigger to Acquisition trigger
  ViConstString AcqTriggerTerminal = NIHSDIO_VAL_PFI0_STR; // Acquisition trigger received by Generation device, otherwise timing not reliable.
  ViInt32 StartTriggerEdge =  NIHSDIO_VAL_RISING_EDGE; // Mysteriously, one needs to connect the trigger inverted between GND and +. Probably better in a closed circuit/with a switch
  ViConstString sampleClockOutputTerminal = NIHSDIO_VAL_DDC_CLK_OUT_STR;
  ViUInt16 *waveformData; /* data type of waveformData needs to change if data width is not 2 bytes. */
  ViConstString waveformName = "myWfm";
  ViUInt32 i;
  ViUInt32 Aoffset;
  ViUInt16 constlevel = 2;
  ViUInt32 NumberOfChannels = 96;
  
  /* ERROR VARIABLES */
  ViChar errDesc[1024];
  ViStatus error = VI_SUCCESS;
  
  char FileName[] = "F:\\data\\test.dat" ;
  DataFile = fopen(FileName,"wb");
  if (DataFile == NULL) { printf("Targetfile for Data could not be opened!\n"); return -1;}

  // PARSE OPTIONS FOR DIFFERENT BITS
  if (Bits==12) PacketLength = 1200;
  if (Bits==16) PacketLength = 1600;
  
// GENERATION CODE
  /* create data for output */
  waveformData = (ViUInt16*) calloc(sizeof(ViUInt16),LoopIterations*DSamplesToRead);
  for (i = 0; i < LoopIterations*DSamplesToRead; i++)  waveformData[i] = constlevel*(i % 2);
  
  time1 = clock();
  ExpectedTimeToPass=(float)DSamplesToRead*LoopIterations / (float)SampleClockRate;
  printf("Expected time (s): %.3f\n",ExpectedTimeToPass);

  /* Initialize, configure, and write waveforms to generation device */
  checkErr(setupGenerationDevice (deviceID, genChannelList, sampleClockOutputTerminal,
          SampleClockRate, AcqTriggerTerminal, GenTriggerTerminal, StartTriggerEdge,  waveformData, waveformName, &genVi));  
  time2 = clock(); printf("Time Difference : %f seconds\n",difftime (time2,time1)/CLOCKS_PER_SEC);
  /* Commit settings to start sample clock, run before initiate the acquisition */
  checkErr(niHSDIO_CommitDynamic(genVi));
  
  // ACQUISITION CODE
  checkErr(setupAcquisitionDevice(deviceID, acqChannelList, NIHSDIO_VAL_ON_BOARD_CLOCK_STR,
          SampleClockRate,  DSamplesToRead, AcqTriggerTerminal , StartTriggerEdge, &vi));
  /* Query Data Width */
  checkErr(niHSDIO_GetAttributeViInt32(vi, VI_NULL, NIHSDIO_ATTR_DATA_WIDTH, &dataWidth));
  /* Configure Fetch */
  checkErr(niHSDIO_SetAttributeViInt32 (vi, "",NIHSDIO_ATTR_FETCH_RELATIVE_TO, NIHSDIO_VAL_FIRST_SAMPLE));
      
  checkErr(niHSDIO_Initiate(genVi));
  
  checkErr(niHSDIO_SetAttributeViInt32 (vi, "",NIHSDIO_ATTR_FETCH_RELATIVE_TO,NIHSDIO_VAL_CURRENT_READ_POSITION));

  // START ACQUISITION
  time1 = clock();
  for (i=0; i<LoopIterations; i++)  {
    /*printf(">> Starting loop %d\n",i); */
    /* Configure Fetch */
    checkErr(niHSDIO_SetAttributeViInt32 (vi, "",NIHSDIO_ATTR_FETCH_OFFSET, 0));
    /* Read Waveform data from device */
    checkErr(niHSDIO_FetchWaveformU8(vi, DSamplesToRead, readTimeout,&DSamplesRead, &(DData[DTotalSamplesRead])));
    DTotalSamplesRead = DTotalSamplesRead + DSamplesRead;
    //printf("\tNumber of Samples read : %d\n",DTotalSamplesRead);
    /* Check Remaining Samples */
    checkErr(niHSDIO_GetAttributeViInt32 (vi, "",NIHSDIO_ATTR_FETCH_BACKLOG, &BackLogSamples));
    //printf("\tSamples left in buffer %d\n",BackLogSamples);
    
    // Decode channels to real int16 (although the current headstage is probably 12-bit)
    decodeData(DData,AData,DTotalSamplesRead,DSamplesRead,&ATotalSamplesRead,&ASamplesRead,Bits,PacketLength,i);
    //printf("ASamples this loop %d/%d\n",ASamplesRead,ATotalSamplesRead);
    // Write data to common file for later reading
    Aoffset=(ATotalSamplesRead-ASamplesRead)*NumberOfChannels;
    ASamplesWritten = fwrite(&(AData[Aoffset]),sizeof(ViInt16),(size_t) (ASamplesRead*NumberOfChannels),DataFile);
    if (ASamplesWritten != ASamplesRead*NumberOfChannels) { printf("Samples could not be written!\n"); return -1;}
    //printf("\tSamples written : %d from offset %d\n",ASamplesWritten,Aoffset);
    ATotalSamplesWritten = ATotalSamplesWritten + ASamplesWritten;
    
    time2=clock();
    TimePassed=difftime(time2,time1)/CLOCKS_PER_SEC;
    if (TimePassed > ExpectedTimeToPass+1) {
      if (DEBUG) {
        printf("Overtime. Quitting?\n");
      }
      i=LoopIterations;
    }
  }
  niHSDIO_reset(vi);
  
  fclose(DataFile);
  
  Error:
    
    if (error == VI_SUCCESS) { /* print result */
      printf("Done without error.\n");
      printf("Number of samples read = %d.\n", DTotalSamplesRead);}
    else { /* Get error description and print */
      niHSDIO_GetError(vi, &error, sizeof(errDesc)/sizeof(ViChar), errDesc);
      printf("\nError encountered\n===================\n%s\n", errDesc);}
    
    niHSDIO_close(vi); /* close the session */
    return error;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void decodeData(ViUInt8 *DData,ViInt16 *AData,ViUInt32 DTotalSamplesRead, ViUInt32 DSamplesRead, 
        ViUInt32 *ATotalSamplesRead, ViUInt32 *ASamplesRead, ViUInt32 Bits, ViInt32 PacketLength, ViUInt32 LoopIteration) {
  
  ViUInt32 NumberOfChannels = 96;
  ViInt32 Bundles = 32;
  ViUInt32 ChannelsPerBundle = 32;
  ViUInt32 BitsPerBundle = 36;
  ViUInt8 Header[] = {0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1};
  ViInt32 HeaderLength = sizeof(Header)/sizeof(ViUInt8);
  ViInt32 FlagLength = 8;
  ViInt32 DataOffset = HeaderLength + FlagLength;
  ViInt32 cStart, DataStart, PacketStart, IterationStart = DTotalSamplesRead - DSamplesRead; // Jumps back to the first entry in the current Iteration
  ViInt32 i1, i2, i3, EqCount, AOffset, Offset;
  ViInt32 PacketsThisIteration = (ViInt32) (floor(DSamplesRead/PacketLength));
  ViInt32 HeaderFound = 0;
  ViInt32 HeaderStart = 0;
  ViUInt32 cATotalSamplesRead;
  
  //printf("\tEntering decoder (DSample : %d, ASample : %d)...\n",IterationStart,ATotalSamplesRead[0]);
  // Find Last/Next Header
  Offset=0;
  if (LoopIteration != 0) { // Search Backward
    for (i1=0; i1<PacketLength; i1++) {
      EqCount = 0;
      for (i2=0; i2<HeaderLength; i2++) {
        //if (DData[IterationStart-i1+i2] == Header[i2]) EqCount++; 
        if (DData[IterationStart-PacketLength+1+i1+i2] == Header[i2] & DData[IterationStart+1+i1+i2] == Header[i2]) EqCount++; 
      }
      // found a match
      if (EqCount == HeaderLength) {
        //Offset = -i1; 
        Offset = -PacketLength+1+i1; 
        HeaderFound = 1; 
        break;
      }
    }
  } else { // SearchForward
    for (i1=0; i1<PacketLength; i1++) {
      EqCount = 0;
      for (i2=0; i2<HeaderLength; i2++) {
        if (DData[IterationStart+i1+i2] == Header[i2] & DData[IterationStart+PacketLength+i1+i2] == Header[i2]) EqCount++; }
      if (EqCount == HeaderLength) {Offset = i1; HeaderFound = 1; PacketsThisIteration--; break;}
    }
  }
  if (DEBUG) {
    if (!HeaderFound) {
      printf("\tHeader not found. Trying next packet.\n");
      for (i1=0; i1<PacketLength; i1++) {
        EqCount = 0;
        for (i2=0; i2<HeaderLength; i2++) {
          //if (DData[IterationStart+PacketLength-i1+i2] == Header[i2]) EqCount++;
          if (DData[IterationStart+1+i1+i2] == Header[i2]) EqCount++;
        }
        // found a match
        if (EqCount == HeaderLength) {
          Offset = i1-PacketLength;
          HeaderFound = 2;
          break;
        }
      }
      if (HeaderFound) {
        printf("Found a match this time: %d\n",Offset);
      } else {
        printf("Still no match\n");
      }
    //} else {
    //  printf("\tHeader found at %d\n",Offset);
    }
  }
  
  // Recode Packages from the last header
  PacketStart = IterationStart + Offset; 
  for (i1 = 0; i1<PacketsThisIteration; i1++) { // Loop over the number of expected analog packets (samples in time)
    HeaderStart=PacketStart;
    EqCount = 0;
    for (i2=0; i2<HeaderLength; i2++) {
      if (DData[HeaderStart+i2] == Header[i2]) EqCount++;
    }
    if (EqCount < HeaderLength) {
      if (DEBUG) {
        printf("ASamp: %d DSamp: %d  Think header offset is %d but no header match on iteration %d\n",i1+ATotalSamplesRead[0],HeaderStart,Offset,i1);
      }
      for (i3=0; i3<PacketLength; i3++) {
        EqCount = 0;
        for (i2=0; i2<HeaderLength; i2++) {
          if (DData[HeaderStart-(PacketLength/2)+i3+i2] == Header[i2]) EqCount++;
        }
        // found a match
        if (EqCount == HeaderLength) {
          if (DEBUG) {
            printf("Found a new match, adjusting offset from %d to %d\n",Offset,Offset-(PacketLength/2)+i3);
          }
          Offset = Offset-(PacketLength/2)+i3;
          PacketStart=PacketStart-(PacketLength/2)+i3;
          HeaderFound = 2;
          break;
        }
      }
    }
    
    DataStart = PacketStart + DataOffset;
    for (i2 = 0; i2<Bundles ; i2++ ) { // Loop over the Bundles in the data section in a packet
      cStart = DataStart + i2*BitsPerBundle;
      cATotalSamplesRead = i1+ATotalSamplesRead[0];
      AOffset = cATotalSamplesRead*NumberOfChannels + i2*3;
      AData[AOffset]     = -2048*DData[cStart]     + 1024*DData[cStart+3] + 512*DData[cStart+6] + 256*DData[cStart+9]   + 128*DData[cStart+12] + 64*DData[cStart+15] + 32*DData[cStart+18] + 16*DData[cStart+21] + 8*DData[cStart+24] + 4*DData[cStart+27] + 2*DData[cStart+30] + 1*DData[cStart+33];
      AData[AOffset+1] = -2048*DData[cStart+1] + 1024*DData[cStart+4] + 512*DData[cStart+7] + 256*DData[cStart+10] + 128*DData[cStart+13] + 64*DData[cStart+16] + 32*DData[cStart+19] + 16*DData[cStart+22] + 8*DData[cStart+25] + 4*DData[cStart+28] + 2*DData[cStart+31] + 1*DData[cStart+34];
      AData[AOffset+2] = -2048*DData[cStart+2] + 1024*DData[cStart+5] + 512*DData[cStart+8] + 256*DData[cStart+11] + 128*DData[cStart+14] + 64*DData[cStart+17] + 32*DData[cStart+20] + 16*DData[cStart+23] + 8*DData[cStart+26] + 4*DData[cStart+29] + 2*DData[cStart+32] + 1*DData[cStart+35];
    };
    PacketStart = PacketStart + PacketLength;
  }
  ASamplesRead[0]=PacketsThisIteration;
  ATotalSamplesRead[0] = ATotalSamplesRead[0] + ASamplesRead[0];
  
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ViStatus setupGenerationDevice(ViRsrc genDeviceID, ViConstString genChannelList, ViConstString sampleClockOutputTerminal,
        ViReal64 SampleClockRate,
        ViConstString dataActiveEventDestination, ViConstString StartTriggerSource, ViInt32 StartTriggerEdge,
        ViUInt16 *waveformData, ViConstString waveformName, ViSession *genViPtr)  {
  
  ViStatus error = VI_SUCCESS;
  ViSession vi = VI_NULL;
  
  /* Initialize generation session */
  checkErr(niHSDIO_InitGenerationSession(genDeviceID, VI_FALSE, VI_TRUE, VI_NULL, &vi));
  /* Assign channels for dynamic generation */
  checkErr(niHSDIO_AssignDynamicChannels (vi, genChannelList));  
  /* Configure Sample Clock */
  checkErr(niHSDIO_ConfigureSampleClock (vi, NIHSDIO_VAL_ON_BOARD_CLOCK_STR, SampleClockRate));
  /* Export Sample Clock */
  checkErr(niHSDIO_ExportSignal (vi, NIHSDIO_VAL_SAMPLE_CLOCK, VI_NULL, sampleClockOutputTerminal));
  /* Export data active event */
  checkErr(niHSDIO_ExportSignal(vi, NIHSDIO_VAL_DATA_ACTIVE_EVENT, VI_NULL, dataActiveEventDestination));
    /* Configure start trigger */
  //checkErr(niHSDIO_ConfigureDigitalEdgeStartTrigger(vi,StartTriggerSource, StartTriggerEdge));
  /* Write waveform to device |  use different Write function if default data width is not 4 bytes. */
  checkErr(niHSDIO_WriteNamedWaveformU16(vi, waveformName, sizeof(waveformData)/sizeof(ViUInt16), waveformData));
  
  Error:  
    *genViPtr = vi;
    return error;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ViStatus setupAcquisitionDevice (ViRsrc acqDeviceID, ViConstString acqChannelList, ViConstString sampleClockSource,
        ViReal64 SampleClockRate,  ViUInt32 SamplesToRead, ViConstString startTriggerSource, ViInt32 StartTriggerEdge,
        ViSession *acqViPtr)
{
  ViStatus error = VI_SUCCESS;
  ViSession vi = VI_NULL;
  ViUInt32 TotalAcqMem;
  ViUInt32 DataWidth = 1;
  
  /* Initialize acquisition session */
  checkErr(niHSDIO_InitAcquisitionSession(acqDeviceID, VI_FALSE, VI_FALSE, VI_NULL, &vi));
  /* Assign channels for dynamic acquisition */
  checkErr(niHSDIO_AssignDynamicChannels (vi, acqChannelList));
  /* Configure Sample clock parameters */
  checkErr(niHSDIO_ConfigureSampleClock(vi, sampleClockSource, SampleClockRate));
  /* Configure the acquistion to be continuous (not finite). */
  checkErr(niHSDIO_SetAttributeViBoolean (vi, "",NIHSDIO_ATTR_SAMPLES_PER_RECORD_IS_FINITE, VI_FALSE));
  /* Configure the number of samples to acquire to device */
  //checkErr(niHSDIO_ConfigureAcquisitionSize(vi, SamplesToRead, 1));
  /* Configure start trigger */
  checkErr(niHSDIO_ConfigureDigitalEdgeStartTrigger(vi,startTriggerSource, StartTriggerEdge));
   /* Set the Data Width Attribute */
   checkErr(niHSDIO_SetAttributeViInt32(vi, VI_NULL, NIHSDIO_ATTR_DATA_WIDTH, DataWidth));
  /* Set the Data Width Attribute */
   checkErr(niHSDIO_GetAttributeViInt32(vi, VI_NULL, NIHSDIO_ATTR_TOTAL_ACQUISITION_MEMORY_SIZE, &TotalAcqMem));
  
   printf("Total Memory/Channel : %i Mb\n",TotalAcqMem*2/DataWidth/(1024^2));
   
  /* Initiate Acquisition */
  checkErr(niHSDIO_Initiate (vi));
  
  Error:
    *acqViPtr = vi;
    return error;   
}


int main(int argc, char *argv[]) {
  char *DData;
  short *AData;
  int ASamplesToRead[1], DSampleClockRate[1], LoopIterations[1];
  int NumberOfChannels = 96;
  int PacketLength = 1200;        
  int DSamplesToRead;
  int i, ALength;
  
  /* Check for proper number of arguments */
  if (argc != 4) {
    printf("Three input arguments required (%d provided).\n",argc-1);
    return 0;
  };
  
  /* Assign pointers to the various parameters */
  sscanf(argv[1],"%d",ASamplesToRead); // number of analog samples to acquire (timesteps)
  sscanf(argv[2],"%d",LoopIterations); // number of analog samples to acquire (timesteps)
  sscanf(argv[3],"%d",DSampleClockRate); // number of analog samples to acquire (timesteps)
  //LoopIterations = ToDecimal(argv[2]); // number of samples to acquire
  //DSampleClockRate = ToDecimal(argv[3]); // Sampling Rate
  printf("ASamples: %d Iter %d DSamples %d\n",ASamplesToRead[0],LoopIterations[0],DSampleClockRate[0]);
  DSamplesToRead =  (int) (ASamplesToRead[0]*PacketLength); // corresponding number of digital samples to acquire
  printf("DSamplesToRead: %d\n",DSamplesToRead);
 /* Create a matrix for the analog (decoded) data */
  ALength=ASamplesToRead[0]*LoopIterations[0] * NumberOfChannels;
  
  //plhs[0] = mxCreateNumericMatrix((int) ALength,1, mxINT16_CLASS, mxREAL);
  AData = (short*)malloc(ALength*sizeof(short));
  
  printf("Analog Length : %d\n",ALength);
  for (i=0;i<ALength;i++) AData[i] = 0; // Initialize to 0
  
  /* Create a matrix for the digital (raw) data */
  //plhs[1] = mxCreateNumericMatrix((int) (DSamplesToRead*LoopIterations[0]), 1, mxUINT8_CLASS, mxREAL);
  //DData = mxGetPr(plhs[1]); // Data vector
  DData=(char*)malloc(DSamplesToRead*LoopIterations[0]*sizeof(char));
  
  getdata((ViUInt8 *) DData, (ViInt16 *) AData, DSamplesToRead, (ViUInt32) (LoopIterations[0]), (ViUInt32) (DSampleClockRate[0]));
  
  return;
}
