-- SQL Script to Add StudentId Column to Users Table
-- Run this script in SQL Server Management Studio (SSMS) or using sqlcmd

USE StudentGradesDB;
GO

-- Check if column already exists, if not add it
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'StudentId'
)
BEGIN
    ALTER TABLE [Users]
    ADD [StudentId] INT NULL;
    
    PRINT 'Column StudentId added successfully to Users table.';
END
ELSE
BEGIN
    PRINT 'Column StudentId already exists in Users table.';
END
GO

