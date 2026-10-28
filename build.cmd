@echo off
setlocal
rem Build entry point for an app on the kit; the app's own android\build.cmd
rem hands over to this.
rem
rem Runs the kit's Gradle wrapper on the app's project with the toolchain
rem that bootstrap.ps1 installs, so nothing has to be on PATH and no
rem JAVA_HOME has to be set machine-wide. One wrapper for every app: one
rem Gradle version, one download in the cache.
rem
rem   build.cmd              assemble the debug APK
rem   build.cmd install      hand off to deploy.cmd (build + install + run)
rem   build.cmd clean        wipe build outputs
rem   build.cmd <task...>    any other gradle task, passed straight through

call "%~dp0toolchain.cmd" || exit /b 1

if not exist "%KIT%gradle\wrapper\gradle-wrapper.jar" (
    echo.
    echo   The Gradle wrapper jar is missing ^(it is not committed^). Run:
    echo.
    echo     powershell -NoProfile -ExecutionPolicy Bypass -File "%KIT%bootstrap.ps1"
    echo.
    exit /b 1
)

cd /d "%PROJECT%"

set "TASK=%*"
if "%TASK%"=="" set "TASK=assembleDebug"

rem Hand "install" to deploy.cmd rather than running gradle's installDebug.
rem They do the same job, but installDebug's failure mode with nothing
rem plugged in is a bare "DeviceException: No connected devices!" wrapped in
rem a gradle stack trace, which says nothing about wireless debugging.
if /i "%TASK%"=="install" (
    call "%KIT%deploy.cmd"
    exit /b %ERRORLEVEL%
)
if /i "%TASK%"=="installDebug" (
    call "%KIT%deploy.cmd"
    exit /b %ERRORLEVEL%
)

call "%KIT%gradlew.bat" -p "%PROJECT%" %TASK%
set "RC=%ERRORLEVEL%"

if %RC%==0 if exist "%APK%" (
    echo.
    echo   APK: %APK%
)

exit /b %RC%
