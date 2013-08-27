/*=================================================================
 HSDIO Continuous Data Streaming To Disk (Used in Conjunction with MANTA)
 *=================================================================*/
#include <math.h>
#include <time.h>
#include <string.h>
//include "mex.h"
//include <conio.h>
//include <windows.h>

/* from ContinuousAcquisition */
#include <stdio.h>
#include "niHSDIO.h"

/* Defines */
#define DEBUG 1

//int createData(char* FileName,int NumberOfChannels,int DSamplingRate, int NIterationsMax, int SamplesPerIteration);

///////////////////////////////////////////////////////////////////////////////////////////
int createData(char* FileName,int NumberOfChannels,int DSamplingRate, int NIterationsMax, int ASamplesPerIteration) {

  FILE *FileID;
  short *AnalogData;
  long ASamplesTotal = 0, ASamplesWritten, Done, kk, iTotal=0, i,j,k;
  double TimePerIteration, Elapsed = 0, ASamplingRate;
  clock_t Clock1, Clock2;
  double Time1, Time2;
  
  if (DEBUG) printf("Entering Data Creation Function...\n");
  ASamplingRate = DSamplingRate/1600; // Assuming 16 bits here
  if (DEBUG) printf("Analog Sampling Rate : %f\n",ASamplingRate);
  TimePerIteration = (double) (ASamplesPerIteration/ASamplingRate);
// OPEN FILE FOR WRITING
  FileID = fopen(FileName, "wb");
  if (FileID == NULL) { printf("Targetfile for Data could not be opened!\n"); return -1;}
  
// SETUP DATA MATRIX
  ASamplesTotal = (int) (ASamplesPerIteration*NumberOfChannels);
  if (DEBUG) printf("Analog Samples per Iteration : %d\n", ASamplesTotal);
  AnalogData = (short*)malloc(ASamplesTotal*sizeof(short));
  for (i=0;i<ASamplesTotal;i++) AnalogData[i] = 0; // Initialize to 0
  
  for (k=0;k<NIterationsMax;k++) {
    // KILL SOME TIME IN ORDER TO PRODUCE DATA IN NEAR REALTIME
    if (DEBUG) printf("%d %2.2f ",k,TimePerIteration);
    Elapsed = 0;
    Clock1 = clock();
    if (DEBUG) printf("Clock: %d ",Clock1);
    Time1 = (double)Clock1/ (double)CLOCKS_PER_SEC;
    if (DEBUG) printf("Time1 : %2.2f ",Time1);
    while (Elapsed<TimePerIteration) {
      Clock2= clock();
      Time2= (double)Clock2/(double)CLOCKS_PER_SEC ;
      Elapsed = Time2 - Time1;
    }
    printf("Time2 : %2.2f ",Time2);
    printf("%f s -  ",Elapsed);
    fflush(stdout);
    
    // GENERATE DATA
    for (i=0;i<ASamplesPerIteration;i++) {
      for (j=0;j<NumberOfChannels;j++) {
        // Simulate Continuous 60Hz Noise
        AnalogData[i*NumberOfChannels+j] = (short) (10000*sin(2*3.14159*5.123*(i+iTotal+100*j)/ASamplingRate));
      }
    }
    iTotal = iTotal + ASamplesPerIteration;
    
    // WRITE OUT DATA
    ASamplesWritten = fwrite(AnalogData, sizeof(short), (size_t) (ASamplesTotal), FileID);
    if (DEBUG) printf("Available : %d || Written : %d\n",ASamplesTotal,ASamplesWritten);
    if (ASamplesWritten != ASamplesTotal) { printf("Samples could not be written!\n"); return -1;}
        
  }
  fclose(FileID);
  return 1;
}

/////////////////////////////////////////////////////////////////////////////////
// MAIN FUNCTION //////////////////////////////////////////////////////////////
int main(int argc, char *argv[]) {
  // Arguments: 
  // FileName : Filename where the temporary file is saved
  // DSamplingRate : Sampling rate of the digital acquisition
  // SamplesPerIteration : Number of Samples Per Iteration
  // NIterationsMax : Maximal Iterations to Acquire
  // DeviceName : Name of the digital NI-DAQ device
  // ChannelNumber : Digital channel to acquire
  // NumberOfChannels : Number of analog channels to decode
  // BitLength : Bit Length of the headstage
  // SimulationMode : Whether to acquire the data or generate it for testing
  
  char FileName[100], DeviceName[2]; 
  int DSamplingRate = 0, SamplesPerIteration = 0, NIterationsMax = 0;
  int ChannelNumber = 0 , NumberOfChannels = 0, BitLength = 0, SimulationMode = 0;
  int i, ALength;
  
  // CHECK NUMBER OF ARGUMENTS
  if (argc != 10) { printf("Nine input arguments required (%d provided).\n",argc-1); return 0; };
  
  // ASSIGN INPUT ARGUMENTS TO LOCAL VARIABLES
  strcpy(FileName, argv[1]); if (DEBUG) printf("Filename for temporary data : %s \n",FileName);
  sscanf(argv[2], "%d", &DSamplingRate);  if (DEBUG) printf("Digital Sampling Rate : %d \n", DSamplingRate);
  sscanf(argv[3],"%d",&SamplesPerIteration); if (DEBUG) printf("Samples Per Iteration : %d \n",SamplesPerIteration);
  sscanf(argv[4],"%d",&NIterationsMax);  if (DEBUG) printf("Maximal Number of Iterations : %d \n",NIterationsMax);
  strcpy(DeviceName, argv[5]); if (DEBUG) printf("DeviceName : %s \n",DeviceName);
  sscanf(argv[6],"%d",&ChannelNumber); if (DEBUG) printf("Digital Channel Number : %d \n",ChannelNumber);
  sscanf(argv[7],"%d",&NumberOfChannels); if (DEBUG) printf("Number of Analog Channels : %d \n",NumberOfChannels);
  sscanf(argv[8],"%d",&BitLength); if (DEBUG) printf("Resolution of Headstage in Bits : %d \n",BitLength);
  sscanf(argv[9],"%d",&SimulationMode); if (DEBUG) printf("Simulation Mode : %d \n",SimulationMode);
  
  // CALL DATA COLLECTION /GENERATION FUNCTIONS
  if (SimulationMode==0) {// ACQUIRE READ DATA
    //acquireData(FileName,DSamplingRate,SamplesPerIteration,NIterationsMax,NumberOfChannels,DeviceName,ChannelNumber,BitLength);
  }
  else {// GENERATE SURROGATE DATA
    if (DEBUG) printf("Entering Data Creation Function...\n");
    createData( FileName, NumberOfChannels, DSamplingRate, NIterationsMax,SamplesPerIteration);
  }
    
  return;
}
