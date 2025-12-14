# Database Setup Instructions

## Option 1: Automatic Database Creation (Recommended)

The application will automatically create the database and tables when you run it for the first time, **IF** the database server exists and the connection string is correct.

### Steps:
1. Ensure SQL Server is running
2. Update the connection string in `F# project/appsettings.json` if needed
3. Run the application: `dotnet run`
4. The database `StudentGradesDB` will be created automatically

## Option 2: Manual Database Creation

If you prefer to create the database manually first:

### Using SQL Server Management Studio (SSMS):

1. Open SQL Server Management Studio
2. Connect to your SQL Server instance
3. Open the file `create_database.sql`
4. Execute the script (F5)
5. The database will be created
6. Run the application - it will create the tables automatically

### Using sqlcmd (Command Line):

```bash
sqlcmd -S localhost -E -i create_database.sql
```

For SQL Server with username/password:
```bash
sqlcmd -S localhost -U yourusername -P yourpassword -i create_database.sql
```

## Connection String Options

### Default (Windows Authentication):
```
Server=localhost;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

### SQL Server Express:
```
Server=localhost\SQLEXPRESS;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

### LocalDB:
```
Server=(localdb)\mssqllocaldb;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;
```

### With Username/Password:
```
Server=localhost;Database=StudentGradesDB;User Id=youruser;Password=yourpassword;TrustServerCertificate=True;
```

## Troubleshooting

### Error: "Cannot open database"
- Check SQL Server is running
- Verify the server name in connection string
- Ensure you have permissions to create databases

### Error: "Login failed"
- Check Windows Authentication is enabled
- Or update connection string with SQL Server credentials

### Error: "Database already exists"
- This is fine! The application will use the existing database
- Or delete it first if you want a fresh start

## Verify Database Creation

After running the application, you can verify the database was created:

```sql
USE StudentGradesDB;
GO

SELECT * FROM INFORMATION_SCHEMA.TABLES;
GO
```

You should see tables: Students, Grades, Users

