# Complete Testing Guide - All Requirements

This guide shows how to test each requirement of the Student Grades Management System.

## Prerequisites

1. **Application must be running** in one terminal:
   ```bash
   cd "F# project"
   dotnet run --project "F# project\F# project.fsproj"
   ```

2. **Use another terminal** or Postman/curl to test the API

3. **Base URL**: `http://localhost:5039`

---

## Requirement 1: Student Model Designer ✅
**F# records + data structures**

### Test: Verify Student Model Structure

**Test 1.1: Create a Student (tests the model)**
```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Alice Johnson\",\"studentId\":\"STU001\",\"email\":\"alice@example.com\"}"
```

**Expected Response:**
```json
{
  "id": 1,
  "name": "Alice Johnson",
  "studentId": "STU001",
  "email": "alice@example.com",
  "createdAt": "2025-12-03T..."
}
```

**Test 1.2: Get Student (verify model structure)**
```bash
curl -X GET "http://localhost:5039/api/students/1" ^
  -H "X-Username: admin"
```

---

## Requirement 2: CRUD Developer ✅
**Add/edit/delete student records**

### Test 2.1: CREATE (Add Student)

```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Bob Smith\",\"studentId\":\"STU002\",\"email\":\"bob@example.com\"}"
```

**Expected**: Status 201 Created with student data

### Test 2.2: READ (Get All Students)

```bash
curl -X GET "http://localhost:5039/api/students" ^
  -H "X-Username: admin"
```

**Expected**: Array of all students

### Test 2.3: READ (Get Student by ID)

```bash
curl -X GET "http://localhost:5039/api/students/1" ^
  -H "X-Username: admin"
```

**Expected**: Single student object

### Test 2.4: UPDATE (Edit Student)

```bash
curl -X PUT "http://localhost:5039/api/students/1" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Alice Johnson Updated\",\"studentId\":\"STU001\",\"email\":\"alice.updated@example.com\"}"
```

**Expected**: Status 200 OK with updated student data

**Verify Update:**
```bash
curl -X GET "http://localhost:5039/api/students/1" ^
  -H "X-Username: admin"
```

### Test 2.5: DELETE (Delete Student)

```bash
curl -X DELETE "http://localhost:5039/api/students/2" ^
  -H "X-Username: admin"
```

**Expected**: Status 204 No Content

**Verify Deletion:**
```bash
curl -X GET "http://localhost:5039/api/students/2" ^
  -H "X-Username: admin"
```

**Expected**: Status 404 Not Found

### Test 2.6: Role-Based Access (Viewer cannot create/edit/delete)

**Try to create as Viewer (should fail):**
```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: viewer" ^
  -d "{\"name\":\"Test Student\",\"studentId\":\"STU999\",\"email\":\"test@example.com\"}"
```

**Expected**: Status 401 Unauthorized with message "Only Admin can create students"

---

## Requirement 3: Grade Calculation Developer ✅
**Averages, totals**

### Test 3.1: Add Grades to a Student

**Add multiple grades:**
```bash
curl -X POST "http://localhost:5039/api/grades" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"studentId\":1,\"subject\":\"Mathematics\",\"score\":85.5,\"maxScore\":100.0}"

curl -X POST "http://localhost:5039/api/grades" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"studentId\":1,\"subject\":\"Science\",\"score\":92.0,\"maxScore\":100.0}"

curl -X POST "http://localhost:5039/api/grades" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"studentId\":1,\"subject\":\"English\",\"score\":78.0,\"maxScore\":100.0}"
```

### Test 3.2: Calculate Student Average

```bash
curl -X GET "http://localhost:5039/api/students/1/average" ^
  -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "studentId": 1,
  "average": 85.17
}
```
*(85.5 + 92.0 + 78.0) / 3 = 85.17%*

### Test 3.3: Calculate Student Total

```bash
curl -X GET "http://localhost:5039/api/students/1/total" ^
  -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "totalScore": 255.5,
  "totalMaxScore": 300.0
}
```

### Test 3.4: Get Student with All Grades and Calculations

```bash
curl -X GET "http://localhost:5039/api/students/1/grades" ^
  -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "student": { ... },
  "grades": [
    { "subject": "Mathematics", "score": 85.5, "maxScore": 100.0, "percentage": 85.5 },
    { "subject": "Science", "score": 92.0, "maxScore": 100.0, "percentage": 92.0 },
    { "subject": "English", "score": 78.0, "maxScore": 100.0, "percentage": 78.0 }
  ],
  "average": 85.17,
  "total": {
    "totalScore": 255.5,
    "totalMaxScore": 300.0
  }
}
```

---

## Requirement 4: Statistician ✅
**Class-wide metrics (highest, lowest, pass rate)**

### Test 4.1: Create Multiple Students with Grades

**Create Student 2:**
```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Charlie Brown\",\"studentId\":\"STU003\",\"email\":\"charlie@example.com\"}"

curl -X POST "http://localhost:5039/api/grades" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"studentId\":3,\"subject\":\"Mathematics\",\"score\":95.0,\"maxScore\":100.0}"

curl -X POST "http://localhost:5039/api/grades" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"studentId\":3,\"subject\":\"Science\",\"score\":88.0,\"maxScore\":100.0}"
```

**Create Student 3:**
```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Diana Prince\",\"studentId\":\"STU004\",\"email\":\"diana@example.com\"}"

curl -X POST "http://localhost:5039/api/grades" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"studentId\":4,\"subject\":\"Mathematics\",\"score\":55.0,\"maxScore\":100.0}"

curl -X POST "http://localhost:5039/api/grades" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"studentId\":4,\"subject\":\"Science\",\"score\":58.0,\"maxScore\":100.0}"
```

### Test 4.2: Get Class Statistics

```bash
curl -X GET "http://localhost:5039/api/statistics" ^
  -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "highestAverage": {
    "student": {
      "id": 3,
      "name": "Charlie Brown",
      ...
    },
    "average": 91.5
  },
  "lowestAverage": {
    "student": {
      "id": 4,
      "name": "Diana Prince",
      ...
    },
    "average": 56.5
  },
  "passRate": 66.67,
  "totalStudents": 3,
  "totalGrades": 7
}
```

**Verification:**
- **Highest Average**: Student with highest average (Charlie: 91.5%)
- **Lowest Average**: Student with lowest average (Diana: 56.5%)
- **Pass Rate**: Percentage of students with ≥60% average (2 out of 3 = 66.67%)
- **Total Students**: Count of all students
- **Total Grades**: Count of all grades

---

## Requirement 5: Role Manager ✅
**Access logic (Admin/Viewer)**

### Test 5.1: Login as Admin

```bash
curl -X POST "http://localhost:5039/api/auth/login" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
```

**Expected**: `{"username":"admin","role":"Admin","message":"Login successful"}`

### Test 5.2: Login as Viewer

```bash
curl -X POST "http://localhost:5039/api/auth/login" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"viewer\",\"password\":\"viewer123\"}"
```

**Expected**: `{"username":"viewer","role":"Viewer","message":"Login successful"}`

### Test 5.3: Admin Can Create (Should Succeed)

```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Test Admin\",\"studentId\":\"STU005\",\"email\":\"admin.test@example.com\"}"
```

**Expected**: Status 201 Created

### Test 5.4: Viewer Cannot Create (Should Fail)

```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: viewer" ^
  -d "{\"name\":\"Test Viewer\",\"studentId\":\"STU006\",\"email\":\"viewer.test@example.com\"}"
```

**Expected**: Status 401 Unauthorized

### Test 5.5: Viewer Can Read (Should Succeed)

```bash
curl -X GET "http://localhost:5039/api/students" ^
  -H "X-Username: viewer"
```

**Expected**: Status 200 OK with student list

### Test 5.6: Admin Can Update (Should Succeed)

```bash
curl -X PUT "http://localhost:5039/api/students/1" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Updated Name\",\"studentId\":\"STU001\",\"email\":\"updated@example.com\"}"
```

**Expected**: Status 200 OK

### Test 5.7: Viewer Cannot Update (Should Fail)

```bash
curl -X PUT "http://localhost:5039/api/students/1" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: viewer" ^
  -d "{\"name\":\"Hacked Name\",\"studentId\":\"STU001\",\"email\":\"hacked@example.com\"}"
```

**Expected**: Status 401 Unauthorized

---

## Requirement 6: Persistence Developer ✅
**SQL Server database (instead of JSON)**

### Test 6.1: Verify Data Persistence

1. **Create a student:**
```bash
curl -X POST "http://localhost:5039/api/students" ^
  -H "Content-Type: application/json" ^
  -H "X-Username: admin" ^
  -d "{\"name\":\"Persistence Test\",\"studentId\":\"STU007\",\"email\":\"persist@example.com\"}"
```

2. **Stop the application** (Ctrl+C)

3. **Restart the application**

4. **Verify data still exists:**
```bash
curl -X GET "http://localhost:5039/api/students" ^
  -H "X-Username: admin"
```

**Expected**: The student you created should still be there!

### Test 6.2: Verify in SQL Server Management Studio

1. Open SSMS
2. Connect to `localhost\SQLEXPRESS`
3. Expand `StudentGradesDB` → `Tables`
4. Right-click `Students` → `Select Top 1000 Rows`
5. You should see all students stored in the database

---

## Requirement 7: UI Developer ✅
**RESTful API endpoints**

### Test 7.1: All Endpoints Are Accessible

**Authentication:**
- ✅ `POST /api/auth/login`
- ✅ `POST /api/auth/register`

**Students (CRUD):**
- ✅ `GET /api/students` - List all
- ✅ `GET /api/students/{id}` - Get by ID
- ✅ `POST /api/students` - Create
- ✅ `PUT /api/students/{id}` - Update
- ✅ `DELETE /api/students/{id}` - Delete

**Grades:**
- ✅ `POST /api/grades` - Add grade
- ✅ `GET /api/students/{id}/grades` - Get student grades

**Calculations:**
- ✅ `GET /api/students/{id}/average` - Get average
- ✅ `GET /api/students/{id}/total` - Get total

**Statistics:**
- ✅ `GET /api/statistics` - Class statistics

### Test 7.2: JSON Request/Response Format

All endpoints accept and return JSON:
- ✅ Request body: `Content-Type: application/json`
- ✅ Response: JSON format
- ✅ Proper HTTP status codes (200, 201, 204, 401, 404)

---

## Requirement 8: Documentation ✅
**Documentation + Version Control**

### Test 8.1: Verify Documentation Files Exist

Check for:
- ✅ `README.md` - Complete documentation
- ✅ `QUICKSTART.md` - Quick start guide
- ✅ `TEST_ALL_REQUIREMENTS.md` - This file
- ✅ `DATABASE_SETUP.md` - Database setup guide
- ✅ `SUCCESS.md` - Success confirmation

---

## Complete Test Script (PowerShell)

Save this as `test_all.ps1` and run it:

```powershell
$baseUrl = "http://localhost:5039"
$adminHeader = @{"X-Username" = "admin"}

Write-Host "=== Testing All Requirements ===" -ForegroundColor Green

# Requirement 1 & 2: Model and CRUD
Write-Host "`n1. Creating Student..." -ForegroundColor Yellow
$student = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Test Student","studentId":"TEST001","email":"test@example.com"}'
Write-Host "Created Student ID: $($student.id)" -ForegroundColor Green

Write-Host "`n2. Getting All Students..." -ForegroundColor Yellow
$students = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Get -Headers $adminHeader
Write-Host "Total Students: $($students.Count)" -ForegroundColor Green

# Requirement 3: Grade Calculations
Write-Host "`n3. Adding Grades..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$($student.id),\"subject\":\"Math\",\"score\":85.5,\"maxScore\":100.0}" | Out-Null
Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$($student.id),\"subject\":\"Science\",\"score\":92.0,\"maxScore\":100.0}" | Out-Null

Write-Host "Getting Average..." -ForegroundColor Yellow
$avg = Invoke-RestMethod -Uri "$baseUrl/api/students/$($student.id)/average" -Method Get -Headers $adminHeader
Write-Host "Student Average: $($avg.average)%" -ForegroundColor Green

# Requirement 4: Statistics
Write-Host "`n4. Getting Statistics..." -ForegroundColor Yellow
$stats = Invoke-RestMethod -Uri "$baseUrl/api/statistics" -Method Get -Headers $adminHeader
Write-Host "Total Students: $($stats.totalStudents)" -ForegroundColor Green
Write-Host "Pass Rate: $($stats.passRate)%" -ForegroundColor Green

# Requirement 5: Role-Based Access
Write-Host "`n5. Testing Role-Based Access..." -ForegroundColor Yellow
$viewerHeader = @{"X-Username" = "viewer"}
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $viewerHeader -Body '{"name":"Should Fail","studentId":"FAIL","email":"fail@example.com"}' -ErrorAction Stop
    Write-Host "ERROR: Viewer was able to create!" -ForegroundColor Red
} catch {
    Write-Host "✓ Viewer correctly blocked from creating" -ForegroundColor Green
}

Write-Host "`n=== All Tests Complete ===" -ForegroundColor Green
```

---

## Quick Test Checklist

- [ ] Requirement 1: Student Model - Create student
- [ ] Requirement 2: CRUD - Create, Read, Update, Delete
- [ ] Requirement 3: Grade Calculations - Average, Total
- [ ] Requirement 4: Statistics - Highest, Lowest, Pass Rate
- [ ] Requirement 5: Role Manager - Admin/Viewer access
- [ ] Requirement 6: Persistence - Data survives restart
- [ ] Requirement 7: API Endpoints - All endpoints work
- [ ] Requirement 8: Documentation - All docs present

---

## Notes

- Replace `^` with `\` if using bash/Unix
- All tests require the application to be running
- Use `-H "X-Username: admin"` for admin operations
- Use `-H "X-Username: viewer"` for viewer operations
- Check HTTP status codes for success/failure

