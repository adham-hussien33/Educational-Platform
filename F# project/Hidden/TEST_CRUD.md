# CRUD Operations Testing Guide

Complete step-by-step guide to test Add, Edit, Read, and Delete operations.

## Prerequisites

1. **Application must be running** on `http://localhost:5039`
2. **Admin credentials**: `admin` / `admin123`

---

## Step 1: READ - Get All Students

**Test:** Retrieve all students from the database

```bash
curl -X GET "http://localhost:5039/api/students" -H "X-Username: admin"
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "name": "Test Student",
    "studentId": "STU001",
    "email": "test@example.com",
    "createdAt": "2025-12-03T..."
  }
]
```

---

## Step 2: CREATE (Add) - Add New Student

**Test:** Create a new student record

```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"John Doe\",\"studentId\":\"STU002\",\"email\":\"john.doe@example.com\"}"
```

**Expected Response:** Status 201 Created
```json
{
  "id": 2,
  "name": "John Doe",
  "studentId": "STU002",
  "email": "john.doe@example.com",
  "createdAt": "2025-12-03T..."
}
```

**Verify it was added:**
```bash
curl -X GET "http://localhost:5039/api/students" -H "X-Username: admin"
```

You should now see 2 students in the list.

---

## Step 3: READ - Get Student by ID

**Test:** Retrieve a specific student by their ID

```bash
curl -X GET "http://localhost:5039/api/students/2" -H "X-Username: admin"
```

**Expected Response:** Status 200 OK
```json
{
  "id": 2,
  "name": "John Doe",
  "studentId": "STU002",
  "email": "john.doe@example.com",
  "createdAt": "2025-12-03T..."
}
```

**Test with non-existent ID:**
```bash
curl -X GET "http://localhost:5039/api/students/999" -H "X-Username: admin"
```

**Expected Response:** Status 404 Not Found

---

## Step 4: UPDATE (Edit) - Update Student

**Test:** Modify an existing student's information

```bash
curl -X PUT "http://localhost:5039/api/students/2" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"John Smith\",\"studentId\":\"STU002\",\"email\":\"john.smith@example.com\"}"
```

**Expected Response:** Status 200 OK
```json
{
  "id": 2,
  "name": "John Smith",
  "studentId": "STU002",
  "email": "john.smith@example.com",
  "createdAt": "2025-12-03T..."
}
```

**Verify the update:**
```bash
curl -X GET "http://localhost:5039/api/students/2" -H "X-Username: admin"
```

Notice the name changed from "John Doe" to "John Smith" and email changed.

**Test updating non-existent student:**
```bash
curl -X PUT "http://localhost:5039/api/students/999" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Test\",\"studentId\":\"TEST\",\"email\":\"test@example.com\"}"
```

**Expected Response:** Status 404 Not Found

---

## Step 5: DELETE - Delete Student

**Test:** Remove a student from the database

**First, create a student to delete:**
```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Delete Me\",\"studentId\":\"STU999\",\"email\":\"delete@example.com\"}"
```

Note the ID from the response (e.g., `"id": 3`)

**Now delete it:**
```bash
curl -X DELETE "http://localhost:5039/api/students/3" -H "X-Username: admin"
```

**Expected Response:** Status 204 No Content (empty response)

**Verify deletion:**
```bash
curl -X GET "http://localhost:5039/api/students/3" -H "X-Username: admin"
```

**Expected Response:** Status 404 Not Found

**Also verify it's not in the list:**
```bash
curl -X GET "http://localhost:5039/api/students" -H "X-Username: admin"
```

The deleted student should not appear in the list.

**Test deleting non-existent student:**
```bash
curl -X DELETE "http://localhost:5039/api/students/999" -H "X-Username: admin"
```

**Expected Response:** Status 404 Not Found

---

## Step 6: Test Role-Based Access

### Test Viewer Can READ (Should Work)

```bash
curl -X GET "http://localhost:5039/api/students" -H "X-Username: viewer"
```

**Expected:** Status 200 OK with student list

### Test Viewer Cannot CREATE (Should Fail)

```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: viewer" -d "{\"name\":\"Should Fail\",\"studentId\":\"FAIL\",\"email\":\"fail@example.com\"}"
```

**Expected:** Status 401 Unauthorized with message "Only Admin can create students"

### Test Viewer Cannot UPDATE (Should Fail)

```bash
curl -X PUT "http://localhost:5039/api/students/1" -H "Content-Type: application/json" -H "X-Username: viewer" -d "{\"name\":\"Hacked\",\"studentId\":\"STU001\",\"email\":\"hacked@example.com\"}"
```

**Expected:** Status 401 Unauthorized with message "Only Admin can update students"

### Test Viewer Cannot DELETE (Should Fail)

```bash
curl -X DELETE "http://localhost:5039/api/students/1" -H "X-Username: viewer"
```

**Expected:** Status 401 Unauthorized with message "Only Admin can delete students"

---

## Complete Test Sequence

Run these commands in order to test the complete CRUD cycle:

```bash
# 1. READ - Get all students
curl -X GET "http://localhost:5039/api/students" -H "X-Username: admin"

# 2. CREATE - Add new student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Alice Johnson\",\"studentId\":\"STU100\",\"email\":\"alice@example.com\"}"

# 3. READ - Get the student we just created (use the ID from step 2)
curl -X GET "http://localhost:5039/api/students/4" -H "X-Username: admin"

# 4. UPDATE - Edit the student
curl -X PUT "http://localhost:5039/api/students/4" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Alice Johnson Updated\",\"studentId\":\"STU100\",\"email\":\"alice.updated@example.com\"}"

# 5. READ - Verify the update
curl -X GET "http://localhost:5039/api/students/4" -H "X-Username: admin"

# 6. DELETE - Remove the student
curl -X DELETE "http://localhost:5039/api/students/4" -H "X-Username: admin"

# 7. READ - Verify deletion
curl -X GET "http://localhost:5039/api/students/4" -H "X-Username: admin"
```

---

## PowerShell Alternative

If `curl` doesn't work, use PowerShell:

```powershell
$baseUrl = "http://localhost:5039"
$adminHeader = @{"X-Username" = "admin"}

# READ - Get all students
Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Get -Headers $adminHeader

# CREATE - Add student
$body = '{"name":"Alice Johnson","studentId":"STU100","email":"alice@example.com"}'
$student = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body $body
Write-Host "Created student with ID: $($student.id)"

# READ - Get by ID
Invoke-RestMethod -Uri "$baseUrl/api/students/$($student.id)" -Method Get -Headers $adminHeader

# UPDATE - Edit student
$updateBody = '{"name":"Alice Johnson Updated","studentId":"STU100","email":"alice.updated@example.com"}'
Invoke-RestMethod -Uri "$baseUrl/api/students/$($student.id)" -Method Put -ContentType "application/json" -Headers $adminHeader -Body $updateBody

# DELETE - Remove student
Invoke-RestMethod -Uri "$baseUrl/api/students/$($student.id)" -Method Delete -Headers $adminHeader

# Verify deletion
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students/$($student.id)" -Method Get -Headers $adminHeader
    Write-Host "ERROR: Student still exists!" -ForegroundColor Red
} catch {
    Write-Host "✓ Student successfully deleted (404 expected)" -ForegroundColor Green
}
```

---

## Expected Results Summary

| Operation | Endpoint | Method | Admin | Viewer | Status Codes |
|-----------|----------|--------|-------|--------|--------------|
| **Read All** | `/api/students` | GET | ✅ | ✅ | 200 OK |
| **Read One** | `/api/students/{id}` | GET | ✅ | ✅ | 200 OK, 404 Not Found |
| **Create** | `/api/students` | POST | ✅ | ❌ | 201 Created, 401 Unauthorized |
| **Update** | `/api/students/{id}` | PUT | ✅ | ❌ | 200 OK, 401 Unauthorized, 404 Not Found |
| **Delete** | `/api/students/{id}` | DELETE | ✅ | ❌ | 204 No Content, 401 Unauthorized, 404 Not Found |

---

## Troubleshooting

**"401 Unauthorized"**
- Make sure you're using `X-Username: admin` header
- Verify admin user exists (should be seeded automatically)

**"404 Not Found"**
- Check the student ID exists
- Use `GET /api/students` to see all available IDs

**"Connection refused"**
- Make sure the application is running
- Check the port: `http://localhost:5039`

**"No route matches"**
- Make sure you're using the correct HTTP method (GET, POST, PUT, DELETE)
- Verify the endpoint URL is correct

