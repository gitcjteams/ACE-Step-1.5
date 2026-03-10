@echo off
:: claude-code.bat - 해당 폴더에서 Claude Code 실행
cd /d "%~dp0"
start "" "%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe" -d "%~dp0." -- cmd /k "%USERPROFILE%\.local\bin\claude.exe" --dangerously-skip-permissions
