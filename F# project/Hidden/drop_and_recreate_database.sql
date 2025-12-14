-- SQL Script to Drop and Recreate StudentGradesDB Database
-- ⚠️ WARNING: This will delete ALL data in the database!
-- Run this script in SQL Server Management Studio (SSMS) or using sqlcmd

USE master;
GO

-- Drop the database if it exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'StudentGradesDB')
BEGIN
    ALTER DATABASE StudentGradesDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE StudentGradesDB;
    PRINT 'Database StudentGradesDB dropped successfully.';
END
ELSE
BEGIN
    PRINT 'Database StudentGradesDB does not exist.';
END
GO

-- Create the database
CREATE DATABASE StudentGradesDB;
PRINT 'Database StudentGradesDB created successfully.';
GO

USE StudentGradesDB;
GO

PRINT 'Database is ready. Run the application to create tables automatically.';
GO

