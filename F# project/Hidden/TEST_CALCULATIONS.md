# Grade Calculations Testing Guide

Complete guide to test average and total calculations for students.

## Prerequisites

1. **Application must be running** on `http://localhost:5039`
2. **Admin credentials**: `admin` / `admin123`
3. **At least one student** in the database

---

## Step 1: Create a Student (if needed)

```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Alice Johnson\",\"studentId\":\"STU100\",\"email\":\"alice@example.com\"}"
```

**Note the student ID from the response** (e.g., `"id": 1`)

---

## Step 2: Add Multiple Grades

Add several grades to test calculations:

### Add Grade 1: Mathematics
```bash
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Mathematics\",\"score\":85.5,\"maxScore\":100.0}"
```

**Expected Response:**
```json
{
  "id": 1,
  "studentId": 1,
  "subject": "Mathematics",
  "score": 85.5,
  "maxScore": 100.0,
  "percentage": 85.5,
  "dateRecorded": "2025-12-03T..."
}
```

### Add Grade 2: Science
```bash
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Science\",\"score\":92.0,\"maxScore\":100.0}"
```

### Add Grade 3: English
```bash
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"English\",\"score\":78.0,\"maxScore\":100.0}"
```

### Add Grade 4: History (with different max score)
```bash
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"History\",\"score\":45.0,\"maxScore\":50.0}"
```

**Calculation Check:**
- Total Score: 85.5 + 92.0 + 78.0 + 45.0 = **300.5**
- Total Max Score: 100.0 + 100.0 + 100.0 + 50.0 = **350.0**
- Average: (300.5 / 350.0) × 100 = **85.86%**

---

## Step 3: Calculate Student Average

**Test:** Get the average percentage for a student

```bash
curl -X GET "http://localhost:5039/api/students/1/average" -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "studentId": 1,
  "average": 85.86
}
```

**Verification:**
- Average = (Total Score / Total Max Score) × 100
- Should match: (300.5 / 350.0) × 100 = 85.86%

**Test with student who has no grades:**
```bash
# Create a new student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"No Grades Student\",\"studentId\":\"STU200\",\"email\":\"nogrades@example.com\"}"

# Try to get average (should return 404)
curl -X GET "http://localhost:5039/api/students/2/average" -H "X-Username: admin"
```

**Expected Response:** Status 404 Not Found with message "Student has no grades"

---

## Step 4: Calculate Student Total

**Test:** Get the total score and total max score

```bash
curl -X GET "http://localhost:5039/api/students/1/total" -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "totalScore": 300.5,
  "totalMaxScore": 350.0
}
```

**Verification:**
- Total Score = Sum of all grade scores
- Total Max Score = Sum of all max scores
- Should match: 300.5 / 350.0

---

## Step 5: Get Student with All Grades and Calculations

**Test:** Get complete student information with all grades, average, and total

```bash
curl -X GET "http://localhost:5039/api/students/1/grades" -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "student": {
    "id": 1,
    "name": "Alice Johnson",
    "studentId": "STU100",
    "email": "alice@example.com",
    "createdAt": "2025-12-03T..."
  },
  "grades": [
    {
      "id": 1,
      "studentId": 1,
      "subject": "Mathematics",
      "score": 85.5,
      "maxScore": 100.0,
      "percentage": 85.5,
      "dateRecorded": "2025-12-03T..."
    },
    {
      "id": 2,
      "studentId": 1,
      "subject": "Science",
      "score": 92.0,
      "maxScore": 100.0,
      "percentage": 92.0,
      "dateRecorded": "2025-12-03T..."
    },
    {
      "id": 3,
      "studentId": 1,
      "subject": "English",
      "score": 78.0,
      "maxScore": 100.0,
      "percentage": 78.0,
      "dateRecorded": "2025-12-03T..."
    },
    {
      "id": 4,
      "studentId": 1,
      "subject": "History",
      "score": 45.0,
      "maxScore": 50.0,
      "percentage": 90.0,
      "dateRecorded": "2025-12-03T..."
    }
  ],
  "average": 85.86,
  "total": {
    "totalScore": 300.5,
    "totalMaxScore": 350.0
  }
}
```

---

## Step 6: Test Edge Cases

### Test 6.1: Student with Zero Scores

```bash
# Add a grade with zero score
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Art\",\"score\":0.0,\"maxScore\":100.0}"

# Check average (should still calculate correctly)
curl -X GET "http://localhost:5039/api/students/1/average" -H "X-Username: admin"
```

### Test 6.2: Student with Perfect Scores

```bash
# Create new student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Perfect Student\",\"studentId\":\"STU300\",\"email\":\"perfect@example.com\"}"

# Add perfect scores
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":3,\"subject\":\"Math\",\"score\":100.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":3,\"subject\":\"Science\",\"score\":100.0,\"maxScore\":100.0}"

# Check average (should be 100%)
curl -X GET "http://localhost:5039/api/students/3/average" -H "X-Username: admin"
```

**Expected:** `{"studentId": 3, "average": 100.0}`

### Test 6.3: Student with Different Max Scores

```bash
# Add grades with varying max scores
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Quiz\",\"score\":18.0,\"maxScore\":20.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Exam\",\"score\":85.0,\"maxScore\":100.0}"

# Verify calculations handle different denominators correctly
curl -X GET "http://localhost:5039/api/students/1/total" -H "X-Username: admin"
```

---

## Step 7: Verify Calculations Manually

### Example Calculation

**Given:**
- Mathematics: 85.5 / 100.0
- Science: 92.0 / 100.0
- English: 78.0 / 100.0
- History: 45.0 / 50.0

**Calculations:**
1. **Total Score**: 85.5 + 92.0 + 78.0 + 45.0 = **300.5**
2. **Total Max Score**: 100.0 + 100.0 + 100.0 + 50.0 = **350.0**
3. **Average Percentage**: (300.5 / 350.0) × 100 = **85.857%** ≈ **85.86%**

**Verify with API:**
```bash
curl -X GET "http://localhost:5039/api/students/1/average" -H "X-Username: admin"
curl -X GET "http://localhost:5039/api/students/1/total" -H "X-Username: admin"
```

---

## Complete Test Sequence

Run these commands in order:

```bash
# 1. Create student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Test Student\",\"studentId\":\"CALC001\",\"email\":\"calc@example.com\"}"

# 2. Add grades (note the student ID from step 1, assume it's 4)
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":4,\"subject\":\"Math\",\"score\":90.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":4,\"subject\":\"Science\",\"score\":85.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":4,\"subject\":\"English\",\"score\":95.0,\"maxScore\":100.0}"

# 3. Get average
curl -X GET "http://localhost:5039/api/students/4/average" -H "X-Username: admin"

# 4. Get total
curl -X GET "http://localhost:5039/api/students/4/total" -H "X-Username: admin"

# 5. Get complete information
curl -X GET "http://localhost:5039/api/students/4/grades" -H "X-Username: admin"
```

**Expected Results:**
- Average: (90 + 85 + 95) / 300 × 100 = **90.0%**
- Total: { "totalScore": 270.0, "totalMaxScore": 300.0 }

---

## PowerShell Alternative

```powershell
$baseUrl = "http://localhost:5039"
$adminHeader = @{"X-Username" = "admin"}

# Create student
$student = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Test Calc","studentId":"CALC001","email":"calc@example.com"}'
$studentId = $student.id
Write-Host "Created student with ID: $studentId"

# Add grades
Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$studentId,\"subject\":\"Math\",\"score\":90.0,\"maxScore\":100.0}" | Out-Null
Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$studentId,\"subject\":\"Science\",\"score\":85.0,\"maxScore\":100.0}" | Out-Null
Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$studentId,\"subject\":\"English\",\"score\":95.0,\"maxScore\":100.0}" | Out-Null

# Get average
$avg = Invoke-RestMethod -Uri "$baseUrl/api/students/$studentId/average" -Method Get -Headers $adminHeader
Write-Host "Average: $($avg.average)%"

# Get total
$total = Invoke-RestMethod -Uri "$baseUrl/api/students/$studentId/total" -Method Get -Headers $adminHeader
Write-Host "Total: $($total.totalScore) / $($total.totalMaxScore)"

# Get complete info
$complete = Invoke-RestMethod -Uri "$baseUrl/api/students/$studentId/grades" -Method Get -Headers $adminHeader
Write-Host "Student: $($complete.student.name)"
Write-Host "Number of grades: $($complete.grades.Count)"
Write-Host "Average: $($complete.average)%"
```

---

## Expected Results Summary

| Test | Endpoint | Expected Result |
|------|----------|----------------|
| **Average** | `GET /api/students/{id}/average` | Percentage: (Total Score / Total Max Score) × 100 |
| **Total** | `GET /api/students/{id}/total` | Object with `totalScore` and `totalMaxScore` |
| **Complete** | `GET /api/students/{id}/grades` | Student + Grades + Average + Total |
| **No Grades** | `GET /api/students/{id}/average` | 404 Not Found |

---

## Troubleshooting

**"404 Not Found" when getting average**
- Student has no grades
- Student ID doesn't exist
- Check with: `GET /api/students/{id}/grades`

**Average seems incorrect**
- Verify all grades are added correctly
- Check for different max scores (they're handled correctly)
- Manual calculation: Sum all scores, sum all max scores, divide and multiply by 100

**Total doesn't match**
- Ensure all grades are for the same student
- Check the student ID in each grade

