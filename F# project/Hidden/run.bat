@echo off
echo Running Student Grades Management System...
cd "F# project"
if exist "F# project.fsproj" (
    echo Starting application...
    dotnet run
) else (
    echo Error: Project file not found!
    echo Current directory: %CD%
    echo Looking for: F# project.fsproj
    echo.
    echo Please run this from: F# project directory
    pause
    exit /b 1
)
pause

