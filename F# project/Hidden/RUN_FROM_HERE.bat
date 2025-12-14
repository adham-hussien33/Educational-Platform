@echo off
REM This batch file should be run from: C:\Users\Admin\Desktop\F# Project\F# project
REM It will run the project from the correct location

echo ========================================
echo Student Grades Management System
echo ========================================
echo.
echo Running from: %CD%
echo.

REM Check if we're in the right directory
if exist "F# project\F# project.fsproj" (
    echo Found project file. Starting application...
    echo.
    dotnet run --project "F# project\F# project.fsproj"
) else (
    echo ERROR: Project file not found!
    echo.
    echo Please make sure you're in the directory: F# project
    echo (The directory containing F# project.sln)
    echo.
    echo Current directory: %CD%
    pause
    exit /b 1
)

