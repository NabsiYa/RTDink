REM ** Make sure american code page is used, otherwise the %DATE environmental var might be wrong
CHCP 437
echo "Make sure you already built "Release GL Beta" x64 before running this, it's just going to use the exe it finds!

REM first clean out any bogus files
cd ..\
cd media
set NO_PAUSE=1
:call update_media.bat
cd ..
cd script

:setup for VS 2017
:call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\"vcvars32.bat

set C_TARGET_EXE=..\bin\dink.exe

REM erase it so we know it got built right
del %C_TARGET_EXE% > NUL

copy "..\bin\winRTDink_Release GL Beta.exe" %C_TARGET_EXE%


set CL=/DRT_SCRIPT_BUILD
:This would need to be "Release GL|x64" for the 64 bit build.  But I don't think we really need to do one yet

:for full rebuild
:devenv ..\windows_vs2017\iphoneRTDink.sln /rebuild "ReleaseBeta GL|Win32" 

:for no rebuild
:devenv ..\windows_vs2017\iphoneRTDink.sln /build "ReleaseBeta GL|Win32" 

REM Make sure the file compiled ok
if not exist %C_TARGET_EXE% %RT_PROTON_UTIL%\beeper.exe /p

:Sign it with the RTsoft cert (optional)

echo "Waiting 5 seconds "
timeout 5

call %RT_PROJECTS%\Signing\sign.bat %C_TARGET_EXE% "Dink Smallwood HD"

REM Do a little cleanup in  the dink bin dir as well
del ..\bin\dink\continue_state.dat
del ..\bin\dink\save*.dat
del ..\bin\dink\quicksave.dat

REM make the windows installer part
SET C_FILENAME=DinkSmallwoodHDInstaller.exe
del %C_FILENAME% > NUL
del DinkSmallwoodHDInstallerBeta.exe > NUL

REM get version information from the source code
echo Grabbing version # information from source code.

%RT_PROTON_UTIL%\ctoenv.exe ..\source\App.cpp "m_version = " C_VERSION /r
if errorlevel 1 %RT_PROTON_UTIL%\beeper.exe /p
call setenv.bat
del setenv.bat

%RT_PROTON_UTIL%\ctoenv.exe ..\source\App.cpp "m_versionString = \"" C_TEXT_VERSION_TEMP
if errorlevel 1  %RT_PROTON_UTIL%\beeper.exe /p
call setenv.bat
del setenv.bat
SET C_TEXT_VERSION=%C_TEXT_VERSION_TEMP%
REM done with temp var, kill it
SET C_TEXT_VERSION_TEMP=
echo Building installer: %C_FILENAME% %C_TEXT_VERSION%

cd win_installer
..\..\..\..\util\NSIS\makensis.exe dink.nsi

SET C_FILENAME=DinkSmallwoodHDInstallerBeta.exe
del %C_FILENAME%
cd ..
copy DinkSmallwoodHDInstaller.exe %C_FILENAME%
del DinkSmallwoodHDInstaller.exe

set d_fname=%C_FILENAME%

echo "Waiting 5 seconds because NSIS does something and ruins the signing if I don't"
timeout 5

call %RT_PROJECTS%\Signing\sign.bat %C_FILENAME% "Dink Smallwood HD"

:call FTPToSiteWin.bat
cd script
pause