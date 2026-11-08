@echo off
  :: rmk.bat - Wrapper para Windows (cmd.exe)
  :: Llama a rmk.ps1 mediante PowerShell.
  :: Uso: rmk.bat "C:\ruta\archivo"
  ::      rmk.bat "C:\ruta\carpeta"

setlocal

if "%~1"=="" (
    echo Uso: rmk.bat ^<archivo|carpeta^>
    exit /b 1
)

set "script=%~dp0rmk.ps1"
if not exist "%script%" (
    echo Error: no se encuentra rmk.ps1 junto a este archivo.
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%script%" -Path "%~1" %*
endlocal
