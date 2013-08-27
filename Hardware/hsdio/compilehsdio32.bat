setlocal

set MATLAB=C:\Program Files\MATLAB\R2010b

set VSINSTALLDIR=C:\Program Files\Microsoft Visual Studio 10.0

set VCINSTALLDIR=%VSINSTALLDIR%\VC

rem In this case, LINKERDIR is being used to specify the location of the SDK

set LINKERDIR=C:\Program Files\Microsoft SDKs\Windows\v7.0A

set PATH=%VSINSTALLDIR%\Common7\IDE;%VSINSTALLDIR%\Common7\Tools;%VCINSTALLDIR%\bin;%VCINSTALLDIR%\bin\VCPackages;%LINKERDIR%\Bin\NETFX 4.0 Tools;%LINKERDIR%\Bin;%MATLAB%\bin\win32;%MATLAB%\bin;%PATH%

set INCLUDE=%VCINSTALLDIR%\include;%LINKERDIR%\include;%LINKERDIR%\include\gl;%INCLUDE%

set LIB=%VCINSTALLDIR%\lib;%LINKERDIR%\lib;%MATLAB%\extern\lib\win32;%LIB%

set MW_TARGET_ARCH=win32

cl /c -I"C:\Program Files\Microsoft Visual Studio 10.0\VC\include" ^
 -I"C:\Program Files\IVI Foundation\IVI\include" ^
 -I"C:\Program Files\IVI Foundation\VISA\WinNT\include"  ^
 /Fohsdio_stream_dual.obj  /O2 /Oy- /DNDEBUG  ^
hsdio_stream_dual.c

link hsdio_stream_dual.obj niHSDIO.lib libcmt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib

endlocal