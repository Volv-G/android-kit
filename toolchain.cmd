@echo off
rem Shared setup for build.cmd and deploy.cmd: not meant to be run itself.
rem Called without setlocal, so what it sets lands in the caller's scope:
rem
rem   KIT        this folder, with a trailing backslash
rem   PROJECT    the app's Android project - the folder the kit sits in
rem   TOOLCHAIN  JAVA_HOME  ANDROID_HOME  ANDROID_SDK_ROOT  ADB
rem   KIT_APPID  KIT_LOGTAGS   from the project's kit.properties
rem   APK        the debug APK
rem
rem The toolchain is the one bootstrap.ps1 installs. ANDROID_KIT_TOOLCHAIN
rem overrides where; without it %LOCALAPPDATA%\android-kit, or the older
rem %LOCALAPPDATA%\vme-android when only that exists - the same toolchain
rem from before the kit, which works as it is. VME_ANDROID_TOOLCHAIN, its
rem old override, is still honoured.

set "KIT=%~dp0"
for %%i in ("%KIT%..") do set "PROJECT=%%~fi"

if not defined ANDROID_KIT_TOOLCHAIN if defined VME_ANDROID_TOOLCHAIN set "ANDROID_KIT_TOOLCHAIN=%VME_ANDROID_TOOLCHAIN%"
if not defined ANDROID_KIT_TOOLCHAIN (
    set "ANDROID_KIT_TOOLCHAIN=%LOCALAPPDATA%\android-kit"
    if not exist "%LOCALAPPDATA%\android-kit" if exist "%LOCALAPPDATA%\vme-android" set "ANDROID_KIT_TOOLCHAIN=%LOCALAPPDATA%\vme-android"
)
set "TOOLCHAIN=%ANDROID_KIT_TOOLCHAIN%"
set "JAVA_HOME=%TOOLCHAIN%\jdk-17"
set "ANDROID_HOME=%TOOLCHAIN%\sdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "ADB=%ANDROID_HOME%\platform-tools\adb.exe"
set "APK=%PROJECT%\app\build\outputs\apk\debug\app-debug.apk"

set "KIT_APPID="
set "KIT_LOGTAGS="
if exist "%PROJECT%\kit.properties" (
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%PROJECT%\kit.properties") do set "KIT_%%a=%%b"
)
if not defined KIT_LOGTAGS set "KIT_LOGTAGS=AndroidRuntime:E"

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo.
    echo   No toolchain found at %TOOLCHAIN%
    echo   Run this once:
    echo.
    echo     powershell -NoProfile -ExecutionPolicy Bypass -File "%KIT%bootstrap.ps1"
    echo.
    exit /b 1
)
exit /b 0
