-- SQL Script to Create StudentGradesDB Database
-- Run this script in SQL Server Management Studio (SSMS) or using sqlcmd

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'StudentGradesDB')
BEGIN
    CREATE DATABASE StudentGradesDB;
    PRINT 'Database StudentGradesDB created successfully.';
END
ELSE
BEGIN
    PRINT 'Database StudentGradesDB already exists.';
END
GO

USE StudentGradesDB;
GO

PRINT 'Database StudentGradesDB is ready.';
PRINT 'The application will create the tables automatically when you run it.';
GO

