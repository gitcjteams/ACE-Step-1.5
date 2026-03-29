@echo off
:: claude-code.bat - 해당 폴더에서 Claude Code 실행
cd /d "%~dp0"

:: claude 실행 파일 경로 자동 탐색
where claude >nul 2>&1
if %ERRORLEVEL% == 0 (
    set CLAUDE_CMD=claude
    goto :run
)

if exist "%USERPROFILE%\AppData\Roaming\npm\claude.cmd" (
    set CLAUDE_CMD=%USERPROFILE%\AppData\Roaming\npm\claude.cmd
    goto :run
)

if exist "%USERPROFILE%\.local\bin\claude.exe" (
    set CLAUDE_CMD=%USERPROFILE%\.local\bin\claude.exe
    goto :run
)

echo [오류] Claude Code를 찾을 수 없습니다.
echo npm install -g @anthropic-ai/claude-code 로 설치해주세요.
pause
exit /b 1

:run
start "" "%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe" -d "%~dp0." -- cmd /k "%CLAUDE_CMD%" --dangerously-skip-permissions
