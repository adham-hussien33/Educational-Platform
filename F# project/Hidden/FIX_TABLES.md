# Fix: Tables Not Showing in Database

## 🔍 Problem Identified

Your application connection string is pointing to **LocalDB**, but you're viewing **SQL Express** in SSMS. That's why you don't see the tables!

## ✅ Solution

I've updated your `appsettings.json` to use SQL Express to match your SSMS connection.

### Option 1: Restart the Application (Recommended)

1. **Stop the running application** (Ctrl+C in the terminal where it's running)

2. **Restart it:**
   ```bash
   cd "F# project"
   dotnet run --project "F# project\F# project.fsproj"
   ```

3. The application will now:
   - Connect to SQL Express (where you created the database)
   - Create all tables automatically
   - Seed the default users

4. **Refresh SSMS** - Right-click "Tables" folder → Refresh
   - You should now see: `Students`, `Grades`, and `Users` tables

### Option 2: Verify Tables Exist

Run this SQL script in SSMS to check:

```sql
USE StudentGradesDB;
GO

-- List all tables
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';
GO
```

### Option 3: Force Table Creation

If tables still don't appear, you can drop and recreate them:

**⚠️ WARNING: This will delete all data!**

```sql
USE StudentGradesDB;
GO

-- Drop tables if they exist (in correct order due to foreign keys)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Grades')
    DROP TABLE [Grades];
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Students')
    DROP TABLE [Students];
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users')
    DROP TABLE [Users];
GO
```

Then restart the application - it will recreate the tables.

## 📋 Connection String Reference

**SQL Express (Current - matches your SSMS):**
```
Server=localhost\SQLEXPRESS;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

**LocalDB (if you want to use that instead):**
```
Server=(localdb)\mssqllocaldb;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

## ✅ After Fixing

Once you restart the application with the correct connection string, you should see:
- ✅ `Students` table
- ✅ `Grades` table  
- ✅ `Users` table (with admin and viewer users)

Refresh the Tables folder in SSMS to see them!

