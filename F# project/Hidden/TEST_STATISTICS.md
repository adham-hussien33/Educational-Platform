# Class Statistics Testing Guide

Complete guide to test class-wide statistics: highest average, lowest average, and pass rate.

## Prerequisites

1. **Application must be running** on `http://localhost:5039`
2. **Admin credentials**: `admin` / `admin123`
3. **Multiple students with grades** (for meaningful statistics)

---

## Step 1: Create Multiple Students with Different Grades

To test statistics properly, we need students with varying performance levels.

### Create Student 1: High Performer
```bash
# Create student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Alice Johnson\",\"studentId\":\"STU001\",\"email\":\"alice@example.com\"}"

# Add high grades (note the student ID from response, assume it's 1)
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Mathematics\",\"score\":95.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Science\",\"score\":92.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"English\",\"score\":88.0,\"maxScore\":100.0}"
```

**Expected Average:** (95 + 92 + 88) / 300 × 100 = **91.67%** ✅ (Passing)

### Create Student 2: Average Performer
```bash
# Create student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Bob Smith\",\"studentId\":\"STU002\",\"email\":\"bob@example.com\"}"

# Add average grades (assume student ID is 2)
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":2,\"subject\":\"Mathematics\",\"score\":75.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":2,\"subject\":\"Science\",\"score\":70.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":2,\"subject\":\"English\",\"score\":65.0,\"maxScore\":100.0}"
```

**Expected Average:** (75 + 70 + 65) / 300 × 100 = **70.0%** ✅ (Passing)

### Create Student 3: Low Performer (Failing)
```bash
# Create student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Charlie Brown\",\"studentId\":\"STU003\",\"email\":\"charlie@example.com\"}"

# Add low grades (assume student ID is 3)
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":3,\"subject\":\"Mathematics\",\"score\":45.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":3,\"subject\":\"Science\",\"score\":50.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":3,\"subject\":\"English\",\"score\":55.0,\"maxScore\":100.0}"
```

**Expected Average:** (45 + 50 + 55) / 300 × 100 = **50.0%** ❌ (Failing - below 60%)

### Create Student 4: Borderline (Just Passing)
```bash
# Create student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Diana Prince\",\"studentId\":\"STU004\",\"email\":\"diana@example.com\"}"

# Add borderline grades (assume student ID is 4)
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":4,\"subject\":\"Mathematics\",\"score\":60.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":4,\"subject\":\"Science\",\"score\":62.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":4,\"subject\":\"English\",\"score\":58.0,\"maxScore\":100.0}"
```

**Expected Average:** (60 + 62 + 58) / 300 × 100 = **60.0%** ✅ (Passing - exactly at threshold)

---

## Step 2: Get Class Statistics

**Test:** Retrieve class-wide statistics

```bash
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "highestAverage": {
    "student": {
      "id": 1,
      "name": "Alice Johnson",
      "studentId": "STU001",
      "email": "alice@example.com",
      "createdAt": "2025-12-03T..."
    },
    "average": 91.67
  },
  "lowestAverage": {
    "student": {
      "id": 3,
      "name": "Charlie Brown",
      "studentId": "STU003",
      "email": "charlie@example.com",
      "createdAt": "2025-12-03T..."
    },
    "average": 50.0
  },
  "passRate": 75.0,
  "totalStudents": 4,
  "totalGrades": 12
}
```

---

## Step 3: Verify Statistics

### Verify Highest Average
- **Expected:** Alice Johnson with 91.67%
- **Check:** `highestAverage.student.name` should be "Alice Johnson"
- **Check:** `highestAverage.average` should be approximately 91.67

### Verify Lowest Average
- **Expected:** Charlie Brown with 50.0%
- **Check:** `lowestAverage.student.name` should be "Charlie Brown"
- **Check:** `lowestAverage.average` should be 50.0

### Verify Pass Rate
- **Passing Threshold:** 60% or higher
- **Passing Students:** 
  - Alice: 91.67% ✅
  - Bob: 70.0% ✅
  - Diana: 60.0% ✅
  - Charlie: 50.0% ❌
- **Pass Rate Calculation:** 3 passing out of 4 students = **75.0%**
- **Check:** `passRate` should be 75.0

### Verify Counts
- **Total Students:** 4
- **Total Grades:** 12 (3 grades × 4 students)
- **Check:** `totalStudents` should be 4
- **Check:** `totalGrades` should be 12

---

## Step 4: Test Edge Cases

### Test 4.1: No Students with Grades

```bash
# Get statistics when no students have grades
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

**Expected Response:**
```json
{
  "highestAverage": null,
  "lowestAverage": null,
  "passRate": null,
  "totalStudents": 0,
  "totalGrades": 0
}
```

### Test 4.2: All Students Passing

```bash
# Create a student with all passing grades
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Perfect Class\",\"studentId\":\"STU005\",\"email\":\"perfect@example.com\"}"

curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":5,\"subject\":\"Math\",\"score\":100.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":5,\"subject\":\"Science\",\"score\":100.0,\"maxScore\":100.0}"

# Get statistics
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

**Expected:** `passRate` should be 100.0% (all students passing)

### Test 4.3: All Students Failing

```bash
# Create a student with all failing grades
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Failing Student\",\"studentId\":\"STU006\",\"email\":\"fail@example.com\"}"

curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":6,\"subject\":\"Math\",\"score\":40.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":6,\"subject\":\"Science\",\"score\":45.0,\"maxScore\":100.0}"

# Get statistics
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

**Expected:** `passRate` should be less than 100% (some students failing)

### Test 4.4: Students with No Grades

```bash
# Create a student without grades
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"No Grades Student\",\"studentId\":\"STU007\",\"email\":\"nogrades@example.com\"}"

# Get statistics
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

**Expected:** Students without grades are **excluded** from:
- Highest average calculation
- Lowest average calculation
- Pass rate calculation
- But **included** in `totalStudents` count

---

## Step 5: Verify Pass Rate Calculation

### Pass Rate Formula
```
Pass Rate = (Number of Students with Average ≥ 60%) / (Total Students with Grades) × 100
```

### Example Calculation

**Given:**
- Alice: 91.67% ✅ (Passing)
- Bob: 70.0% ✅ (Passing)
- Charlie: 50.0% ❌ (Failing)
- Diana: 60.0% ✅ (Passing)

**Calculation:**
- Passing students: 3 (Alice, Bob, Diana)
- Total students with grades: 4
- Pass Rate: (3 / 4) × 100 = **75.0%**

**Verify:**
```bash
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

Check that `passRate` equals 75.0

---

## Complete Test Sequence

Run these commands in order:

```bash
# 1. Create and add grades for Student 1 (High performer)
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Alice\",\"studentId\":\"STU001\",\"email\":\"alice@example.com\"}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Math\",\"score\":95.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Science\",\"score\":92.0,\"maxScore\":100.0}"

# 2. Create and add grades for Student 2 (Average performer)
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Bob\",\"studentId\":\"STU002\",\"email\":\"bob@example.com\"}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":2,\"subject\":\"Math\",\"score\":75.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":2,\"subject\":\"Science\",\"score\":70.0,\"maxScore\":100.0}"

# 3. Create and add grades for Student 3 (Low performer)
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Charlie\",\"studentId\":\"STU003\",\"email\":\"charlie@example.com\"}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":3,\"subject\":\"Math\",\"score\":45.0,\"maxScore\":100.0}"
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":3,\"subject\":\"Science\",\"score\":50.0,\"maxScore\":100.0}"

# 4. Get statistics
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

---

## Expected Results Summary

| Metric | Expected Value | Verification |
|--------|---------------|--------------|
| **Highest Average** | Alice with ~91.67% | Check `highestAverage.student.name` and `highestAverage.average` |
| **Lowest Average** | Charlie with 50.0% | Check `lowestAverage.student.name` and `lowestAverage.average` |
| **Pass Rate** | 75.0% (3 out of 4 passing) | Check `passRate` value |
| **Total Students** | 4 | Check `totalStudents` count |
| **Total Grades** | 6 (2 grades × 3 students) | Check `totalGrades` count |

---

## Troubleshooting

**"highestAverage" or "lowestAverage" is null**
- No students have grades yet
- Add grades to at least one student

**Pass rate seems incorrect**
- Verify the passing threshold is 60%
- Check individual student averages
- Ensure all students with grades are included

**Statistics don't update**
- Make sure you've added grades after creating students
- Refresh the statistics endpoint

**Counts don't match**
- `totalStudents` includes all students (even without grades)
- `totalGrades` counts all grade records
- Students without grades are excluded from average calculations

