function [methodinfo,structs,enuminfo,ThunkLibName]=nidaqmx;
% NIDAQMX Create structures to define interfaces found in 'NIDAQmx'.
% REDUCED SET OF FUNCTION CALLS SUFFICENT FOR MANTA! (DECREASES LOADING TIME)
%This function was generated by loadlibrary.m parser version 1.1.6.22 on Fri May 27 02:04:32 2011
%perl options:'NIDAQmx.i -outfile=nidaqmx.m'
ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.
fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival);
structs=[];enuminfo=[];fcnNum=1;
ThunkLibName=[];


%% DEVICE MANAGEMENT
% int32 _stdcall DAQmxResetDevice ( const char deviceName []); 
fcns.name{fcnNum}='DAQmxResetDevice'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDevProductType ( const char device [], char * data , uInt32 bufferSize ); 
fcns.name{fcnNum}='DAQmxGetDevProductType'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'cstring', 'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDevProductNum ( const char device [], uInt32 * data ); 
fcns.name{fcnNum}='DAQmxGetDevProductNum'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDevSerialNum ( const char device [], uInt32 * data ); 
fcns.name{fcnNum}='DAQmxGetDevSerialNum'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;

%% TASK MANAGEMENT
% int32 _stdcall DAQmxLoadTask ( const char taskName [], TaskHandle * taskHandle ); 
fcns.name{fcnNum}='DAQmxLoadTask'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCreateTask ( const char taskName [], TaskHandle * taskHandle ); 
fcns.name{fcnNum}='DAQmxCreateTask'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxStartTask ( TaskHandle taskHandle ); 
fcns.name{fcnNum}='DAQmxStartTask'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxStopTask ( TaskHandle taskHandle ); 
fcns.name{fcnNum}='DAQmxStopTask'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxClearTask ( TaskHandle taskHandle ); 
fcns.name{fcnNum}='DAQmxClearTask'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWaitUntilTaskDone ( TaskHandle taskHandle , float64 timeToWait ); 
fcns.name{fcnNum}='DAQmxWaitUntilTaskDone'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'double'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxIsTaskDone ( TaskHandle taskHandle , bool32 * isTaskDone ); 
fcns.name{fcnNum}='DAQmxIsTaskDone'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxTaskControl ( TaskHandle taskHandle , int32 action ); 
fcns.name{fcnNum}='DAQmxTaskControl'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetTaskComplete ( TaskHandle taskHandle , bool32 * data ); 
fcns.name{fcnNum}='DAQmxGetTaskComplete'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;

%% TASK PROPERTIES
% int32 _stdcall DAQmxGetSampClkRate ( TaskHandle taskHandle , float64 * data ); 
fcns.name{fcnNum}='DAQmxGetSampClkRate'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'doublePtr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxSetSampClkRate ( TaskHandle taskHandle , float64 data ); 
fcns.name{fcnNum}='DAQmxSetSampClkRate'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'double'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxResetSampClkRate ( TaskHandle taskHandle ); 
fcns.name{fcnNum}='DAQmxResetSampClkRate'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetTaskChannels ( TaskHandle taskHandle , char * data , uInt32 bufferSize ); 
fcns.name{fcnNum}='DAQmxGetTaskChannels'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetTaskNumChans ( TaskHandle taskHandle , uInt32 * data ); 
fcns.name{fcnNum}='DAQmxGetTaskNumChans'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;

%% CHANNEL MANAGEMENT
% int32 _stdcall DAQmxAddGlobalChansToTask ( TaskHandle taskHandle , const char channelNames []); 
fcns.name{fcnNum}='DAQmxAddGlobalChansToTask'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCreateAIVoltageChan ( TaskHandle taskHandle , const char physicalChannel [], const char nameToAssignToChannel [], int32 terminalConfig , float64 minVal , float64 maxVal , int32 units , const char customScaleName []); 
fcns.name{fcnNum}='DAQmxCreateAIVoltageChan'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'cstring', 'int32', 'double', 'double', 'int32', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCreateAOVoltageChan ( TaskHandle taskHandle , const char physicalChannel [], const char nameToAssignToChannel [], float64 minVal , float64 maxVal , int32 units , const char customScaleName []); 
fcns.name{fcnNum}='DAQmxCreateAOVoltageChan'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'cstring', 'double', 'double', 'int32', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDevAIVoltageRngs ( const char device [], float64 * data , uInt32 arraySizeInSamples ); 
fcns.name{fcnNum}='DAQmxGetDevAIVoltageRngs'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'doublePtr', 'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDevAIMaxSingleChanRate ( const char device [], float64 * data ); 
fcns.name{fcnNum}='DAQmxGetDevAIMaxSingleChanRate'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'doublePtr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDevAIMaxMultiChanRate ( const char device [], float64 * data ); 
fcns.name{fcnNum}='DAQmxGetDevAIMaxMultiChanRate'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'doublePtr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDevAIPhysicalChans ( const char device [], char * data , uInt32 bufferSize ); 
fcns.name{fcnNum}='DAQmxGetDevAIPhysicalChans'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'cstring', 'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCreateDIChan ( TaskHandle taskHandle , const char lines [], const char nameToAssignToLines [], int32 lineGrouping ); 
fcns.name{fcnNum}='DAQmxCreateDIChan'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'cstring', 'int32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCreateDOChan ( TaskHandle taskHandle , const char lines [], const char nameToAssignToLines [], int32 lineGrouping ); 
fcns.name{fcnNum}='DAQmxCreateDOChan'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'cstring', 'int32'};fcnNum=fcnNum+1;

%% CHANNEL PROPERTIES
% int32 _stdcall DAQmxGetAIMax ( TaskHandle taskHandle , const char channel [], float64 * data ); 
fcns.name{fcnNum}='DAQmxGetAIMax'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'doublePtr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxSetAIMax ( TaskHandle taskHandle , const char channel [], float64 data ); 
fcns.name{fcnNum}='DAQmxSetAIMax'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'double'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxResetAIMax ( TaskHandle taskHandle , const char channel []); 
fcns.name{fcnNum}='DAQmxResetAIMax'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetAIMin ( TaskHandle taskHandle , const char channel [], float64 * data ); 
fcns.name{fcnNum}='DAQmxGetAIMin'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'doublePtr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxSetAIMin ( TaskHandle taskHandle , const char channel [], float64 data ); 
fcns.name{fcnNum}='DAQmxSetAIMin'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'double'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxResetAIMin ( TaskHandle taskHandle , const char channel []); 
fcns.name{fcnNum}='DAQmxResetAIMin'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring'};fcnNum=fcnNum+1;
% TERM_CONFIGS
% int32 _stdcall DAQmxGetAITermCfg ( TaskHandle taskHandle , const char channel [], int32 * data ); 
fcns.name{fcnNum}='DAQmxGetAITermCfg'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'int32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxSetAITermCfg ( TaskHandle taskHandle , const char channel [], int32 data ); 
fcns.name{fcnNum}='DAQmxSetAITermCfg'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'int32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxResetAITermCfg ( TaskHandle taskHandle , const char channel []); 
fcns.name{fcnNum}='DAQmxResetAITermCfg'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetAOTermCfg ( TaskHandle taskHandle , const char channel [], int32 * data ); 
fcns.name{fcnNum}='DAQmxGetAOTermCfg'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'int32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxSetAOTermCfg ( TaskHandle taskHandle , const char channel [], int32 data ); 
fcns.name{fcnNum}='DAQmxSetAOTermCfg'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'int32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxResetAOTermCfg ( TaskHandle taskHandle , const char channel []); 
fcns.name{fcnNum}='DAQmxResetAOTermCfg'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring'};fcnNum=fcnNum+1;

%% DATA ACQUISITION / PRODUCTION 
% IN
% int32 _stdcall DAQmxGetReadAvailSampPerChan ( TaskHandle taskHandle , uInt32 * data ); 
fcns.name{fcnNum}='DAQmxGetReadAvailSampPerChan'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetReadTotalSampPerChanAcquired ( TaskHandle taskHandle , uInt64 * data ); 
fcns.name{fcnNum}='DAQmxGetReadTotalSampPerChanAcquired'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint64Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadAnalogF64 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , float64 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadAnalogF64'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'doublePtr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadAnalogScalarF64 ( TaskHandle taskHandle , float64 timeout , float64 * value , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadAnalogScalarF64'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'double', 'doublePtr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadBinaryI16 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , int16 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadBinaryI16'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'int16Ptr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadBinaryU16 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , uInt16 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadBinaryU16'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'uint16Ptr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadBinaryI32 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , int32 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadBinaryI32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'int32Ptr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadBinaryU32 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , uInt32 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadBinaryU32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'uint32Ptr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadDigitalU8 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , uInt8 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadDigitalU8'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'uint8Ptr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadDigitalU16 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , uInt16 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadDigitalU16'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'uint16Ptr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadDigitalU32 ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , uInt32 readArray [], uInt32 arraySizeInSamps , int32 * sampsPerChanRead , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadDigitalU32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'uint32Ptr', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadDigitalScalarU32 ( TaskHandle taskHandle , float64 timeout , uInt32 * value , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadDigitalScalarU32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'double', 'uint32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxReadDigitalLines ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , uInt8 readArray [], uInt32 arraySizeInBytes , int32 * sampsPerChanRead , int32 * numBytesPerSamp , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxReadDigitalLines'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'double', 'uint32', 'uint8Ptr', 'uint32', 'int32Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCfgSampClkTiming ( TaskHandle taskHandle , const char source [], float64 rate , int32 activeEdge , int32 sampleMode , uInt64 sampsPerChan ); 
% OUT
% int32 _stdcall DAQmxWriteAnalogF64 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const float64 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteAnalogF64'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'doublePtr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteAnalogScalarF64 ( TaskHandle taskHandle , bool32 autoStart , float64 timeout , float64 value , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteAnalogScalarF64'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32', 'double', 'double', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteBinaryI16 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const int16 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteBinaryI16'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'int16Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteBinaryU16 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const uInt16 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteBinaryU16'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'uint16Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteBinaryI32 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const int32 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteBinaryI32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'int32Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteBinaryU32 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const uInt32 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteBinaryU32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'uint32Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteDigitalU8 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const uInt8 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteDigitalU8'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'uint8Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteDigitalU16 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const uInt16 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteDigitalU16'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'uint16Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteDigitalU32 ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const uInt32 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteDigitalU32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'uint32Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteDigitalScalarU32 ( TaskHandle taskHandle , bool32 autoStart , float64 timeout , uInt32 value , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteDigitalScalarU32'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32', 'double', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxWriteDigitalLines ( TaskHandle taskHandle , int32 numSampsPerChan , bool32 autoStart , float64 timeout , bool32 dataLayout , const uInt8 writeArray [], int32 * sampsPerChanWritten , bool32 * reserved ); 
fcns.name{fcnNum}='DAQmxWriteDigitalLines'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32', 'uint32', 'double', 'uint32', 'uint8Ptr', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;

%% TRIGGERS
% int32 _stdcall DAQmxSendSoftwareTrigger ( TaskHandle taskHandle , int32 triggerID ); 
fcns.name{fcnNum}='DAQmxSendSoftwareTrigger'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32'};fcnNum=fcnNum+1;
fcns.name{fcnNum}='DAQmxCfgSampClkTiming'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'double', 'int32', 'int32', 'uint64'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCreateAIVoltageChan ( TaskHandle taskHandle , const char physicalChannel [], const char nameToAssignToChannel [], int32 terminalConfig , float64 minVal , float64 maxVal , int32 units , const char customScaleName []); 
fcns.name{fcnNum}='DAQmxCreateAIVoltageChan'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'cstring', 'int32', 'double', 'double', 'int32', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCfgDigEdgeStartTrig ( TaskHandle taskHandle , const char triggerSource [], int32 triggerEdge ); 
fcns.name{fcnNum}='DAQmxCfgDigEdgeStartTrig'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'int32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCfgAnlgEdgeStartTrig ( TaskHandle taskHandle , const char triggerSource [], int32 triggerSlope , float64 triggerLevel ); 
fcns.name{fcnNum}='DAQmxCfgAnlgEdgeStartTrig'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'int32', 'double'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetStartTrigType ( TaskHandle taskHandle , int32 * data ); 
fcns.name{fcnNum}='DAQmxGetStartTrigType'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32Ptr'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxSetStartTrigType ( TaskHandle taskHandle , int32 data ); 
fcns.name{fcnNum}='DAQmxSetStartTrigType'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'int32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxResetStartTrigType ( TaskHandle taskHandle ); 
fcns.name{fcnNum}='DAQmxResetStartTrigType'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxGetDigEdgeStartTrigSrc ( TaskHandle taskHandle , char * data , uInt32 bufferSize ); 


% int32 _stdcall DAQmxCreateLinScale ( const char name [], float64 slope , float64 yIntercept , int32 preScaledUnits , const char scaledUnits []); 
fcns.name{fcnNum}='DAQmxCreateLinScale'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'double', 'double', 'int32', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCreateAIMicrophoneChan ( TaskHandle taskHandle , const char physicalChannel [], const char nameToAssignToChannel [], int32 terminalConfig , int32 units , float64 micSensitivity , float64 maxSndPressLevel , int32 currentExcitSource , float64 currentExcitVal , const char customScaleName []); 
fcns.name{fcnNum}='DAQmxCreateAIMicrophoneChan'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'cstring', 'cstring', 'int32', 'int32', 'double', 'double', 'int32', 'double', 'cstring'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCfgInputBuffer ( TaskHandle taskHandle , uInt32 numSampsPerChan ); 
fcns.name{fcnNum}='DAQmxCfgInputBuffer'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32'};fcnNum=fcnNum+1;
% int32 _stdcall DAQmxCfgOutputBuffer ( TaskHandle taskHandle , uInt32 numSampsPerChan ); 
fcns.name{fcnNum}='DAQmxCfgOutputBuffer'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'uint32', 'uint32'};fcnNum=fcnNum+1;
% int32 DAQmxGetBufferAttribute ( TaskHandle taskHandle , int32 attribute , void * value ); 


methodinfo=fcns;