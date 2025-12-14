# Quick Run Guide

## Current Location
You are in: `C:\Users\Admin\Desktop\F# Project\F# project`

## ✅ EASIEST WAY TO RUN:

### Option 1: Double-click the batch file
```
RUN_FROM_HERE.bat
```

### Option 2: Command line (from current directory)
```bash
dotnet run --project "F# project\F# project.fsproj"
```

### Option 3: Navigate first, then run
```bash
cd "F# project"
dotnet run
```

## 📝 Your Connection String

You've configured it to use **SQL Server Express**:
```
Server=localhost\SQLEXPRESS;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

**Make sure:**
- SQL Server Express is installed and running
- The service is started (check Services.msc)
- Or use LocalDB if you prefer:
  ```
  Server=(localdb)\mssqllocaldb;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
  ```

## 🚀 What Happens When You Run

1. Application builds
2. Database `StudentGradesDB` is created automatically (if it doesn't exist)
3. Tables are created automatically
4. Default users are seeded:
   - `admin` / `admin123` (Admin role)
   - `viewer` / `viewer123` (Viewer role)
5. Application starts on:
   - HTTP: `http://localhost:5039`
   - HTTPS: `https://localhost:7189`

## ❌ If You Get Errors

**"Couldn't find a project to run"**
- You're in the wrong directory
- Use: `dotnet run --project "F# project\F# project.fsproj"`

**Database connection error**
- Check SQL Server Express is running
- Or change connection string to LocalDB in `F# project/appsettings.json`

