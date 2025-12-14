# Quick Start Guide

## Prerequisites Check

1. **.NET SDK**: Run `dotnet --version` (should be 8.0 or later)
2. **SQL Server**: Ensure SQL Server is installed and running

## Quick Setup (3 Steps)

### Step 1: Navigate to Project Directory
**Important:** You must be in the project directory (where the `.fsproj` file is located).

```bash
cd "F# project/F# project"
```

**Alternative:** Run from the solution directory using the `--project` flag:
```bash
# You're already in "F# project" directory
dotnet run --project "F# project\F# project.fsproj"
```

### Step 2: Restore & Build
```bash
dotnet restore
dotnet build
```

### Step 3: Run
```bash
dotnet run
```

**Or from the solution directory:**
```bash
dotnet run --project "F# project\F# project.fsproj"
```

The application will:
- Start on `http://localhost:5039` (HTTP) or `https://localhost:7189` (HTTPS)
- Create the database automatically
- Create default users: `admin/admin123` and `viewer/viewer123`

## Quick Test

### 1. Test Login
```bash
curl -X POST "http://localhost:5039/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
```

### 2. Create a Student
```bash
curl -X POST "http://localhost:5039/api/students" \
  -H "Content-Type: application/json" \
  -H "X-Username: admin" \
  -d "{\"name\":\"John Doe\",\"studentId\":\"STU001\",\"email\":\"john@example.com\"}"
```

### 3. Add a Grade
```bash
curl -X POST "http://localhost:5039/api/grades" \
  -H "Content-Type: application/json" \
  -H "X-Username: admin" \
  -d "{\"studentId\":1,\"subject\":\"Math\",\"score\":85.5,\"maxScore\":100.0}"
```

### 4. Get Statistics
```bash
curl -X GET "http://localhost:5039/api/statistics" \
  -H "X-Username: admin"
```

## Default Credentials

- **Admin**: `admin` / `admin123` (Full access)
- **Viewer**: `viewer` / `viewer123` (Read-only)

## Connection String

If you need to change the database connection, edit:
`F# project/F# project/appsettings.json`

Default connection string:
```
Server=localhost;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

For LocalDB, use:
```
Server=(localdb)\\mssqllocaldb;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

## Troubleshooting

**Port in use?** Edit `Properties/launchSettings.json` and change ports.

**Database error?** Check SQL Server is running and connection string is correct.

**Build errors?** Run `dotnet clean` then `dotnet restore` and `dotnet build`.

