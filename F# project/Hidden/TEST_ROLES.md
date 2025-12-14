# Role-Based Access Control Testing Guide

Complete guide to test Admin and Viewer roles and their permissions.

## Prerequisites

1. **Application must be running** on `http://localhost:5039`
2. **Default users** (created automatically):
   - **Admin**: `admin` / `admin123`
   - **Viewer**: `viewer` / `viewer123`

---

## Step 1: Test Login

### Login as Admin

```bash
curl -X POST "http://localhost:5039/api/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
```

**Expected Response:**
```json
{
  "username": "admin",
  "role": "Admin",
  "message": "Login successful"
}
```

### Login as Viewer

```bash
curl -X POST "http://localhost:5039/api/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"viewer\",\"password\":\"viewer123\"}"
```

**Expected Response:**
```json
{
  "username": "viewer",
  "role": "Viewer",
  "message": "Login successful"
}
```

### Test Invalid Login

```bash
curl -X POST "http://localhost:5039/api/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"wrongpassword\"}"
```

**Expected Response:** Status 401 Unauthorized

---

## Step 2: Test Admin Permissions (Full Access)

Admin should be able to perform **ALL** operations: Create, Read, Update, Delete.

### Admin Can CREATE

```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Admin Test Student\",\"studentId\":\"ADMIN001\",\"email\":\"admin.test@example.com\"}"
```

**Expected:** Status 201 Created with student data

### Admin Can READ

```bash
curl -X GET "http://localhost:5039/api/students" -H "X-Username: admin"
```

**Expected:** Status 200 OK with student list

### Admin Can UPDATE

```bash
# First, note the student ID from previous create (assume it's 1)
curl -X PUT "http://localhost:5039/api/students/1" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Updated by Admin\",\"studentId\":\"ADMIN001\",\"email\":\"updated@example.com\"}"
```

**Expected:** Status 200 OK with updated student data

### Admin Can DELETE

```bash
curl -X DELETE "http://localhost:5039/api/students/1" -H "X-Username: admin"
```

**Expected:** Status 204 No Content

### Admin Can Add Grades

```bash
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":2,\"subject\":\"Math\",\"score\":85.0,\"maxScore\":100.0}"
```

**Expected:** Status 201 Created with grade data

---

## Step 3: Test Viewer Permissions (Read-Only)

Viewer should be able to **READ** but **NOT** create, update, or delete.

### Viewer Can READ (All Students)

```bash
curl -X GET "http://localhost:5039/api/students" -H "X-Username: viewer"
```

**Expected:** Status 200 OK with student list ✅

### Viewer Can READ (Single Student)

```bash
curl -X GET "http://localhost:5039/api/students/2" -H "X-Username: viewer"
```

**Expected:** Status 200 OK with student data ✅

### Viewer Can READ (Student Grades)

```bash
curl -X GET "http://localhost:5039/api/students/2/grades" -H "X-Username: viewer"
```

**Expected:** Status 200 OK with grades data ✅

### Viewer Can READ (Student Average)

```bash
curl -X GET "http://localhost:5039/api/students/2/average" -H "X-Username: viewer"
```

**Expected:** Status 200 OK with average data ✅

### Viewer Can READ (Student Total)

```bash
curl -X GET "http://localhost:5039/api/students/2/total" -H "X-Username: viewer"
```

**Expected:** Status 200 OK with total data ✅

### Viewer Can READ (Statistics)

```bash
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: viewer"
```

**Expected:** Status 200 OK with statistics ✅

---

## Step 4: Test Viewer Restrictions (Should Fail)

Viewer should **NOT** be able to create, update, or delete.

### Viewer Cannot CREATE Students

```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: viewer" -d "{\"name\":\"Should Fail\",\"studentId\":\"FAIL001\",\"email\":\"fail@example.com\"}"
```

**Expected:** Status 401 Unauthorized with message "Only Admin can create students" ❌

### Viewer Cannot UPDATE Students

```bash
curl -X PUT "http://localhost:5039/api/students/2" -H "Content-Type: application/json" -H "X-Username: viewer" -d "{\"name\":\"Hacked Name\",\"studentId\":\"STU002\",\"email\":\"hacked@example.com\"}"
```

**Expected:** Status 401 Unauthorized with message "Only Admin can update students" ❌

### Viewer Cannot DELETE Students

```bash
curl -X DELETE "http://localhost:5039/api/students/2" -H "X-Username: viewer"
```

**Expected:** Status 401 Unauthorized with message "Only Admin can delete students" ❌

### Viewer Cannot Add Grades

```bash
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: viewer" -d "{\"studentId\":2,\"subject\":\"Math\",\"score\":100.0,\"maxScore\":100.0}"
```

**Expected:** Status 401 Unauthorized with message "Only Admin can create grades" ❌

---

## Step 5: Test Without Authentication Header

Operations should work without the header for READ operations, but fail for write operations.

### Read Without Header (Should Work)

```bash
curl -X GET "http://localhost:5039/api/students"
```

**Expected:** Status 200 OK ✅

### Create Without Header (Should Fail)

```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -d "{\"name\":\"No Auth\",\"studentId\":\"NOAUTH\",\"email\":\"noauth@example.com\"}"
```

**Expected:** Status 401 Unauthorized ❌

---

## Step 6: Complete Test Sequence

Run these commands in order to test all scenarios:

```bash
# 1. Login as Admin
curl -X POST "http://localhost:5039/api/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}"

# 2. Admin creates a student
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"Test Student\",\"studentId\":\"TEST001\",\"email\":\"test@example.com\"}"

# 3. Login as Viewer
curl -X POST "http://localhost:5039/api/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"viewer\",\"password\":\"viewer123\"}"

# 4. Viewer reads students (should work)
curl -X GET "http://localhost:5039/api/students" -H "X-Username: viewer"

# 5. Viewer tries to create (should fail)
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: viewer" -d "{\"name\":\"Should Fail\",\"studentId\":\"FAIL\",\"email\":\"fail@example.com\"}"

# 6. Viewer tries to update (should fail)
curl -X PUT "http://localhost:5039/api/students/1" -H "Content-Type: application/json" -H "X-Username: viewer" -d "{\"name\":\"Hacked\",\"studentId\":\"TEST001\",\"email\":\"hacked@example.com\"}"

# 7. Viewer tries to delete (should fail)
curl -X DELETE "http://localhost:5039/api/students/1" -H "X-Username: viewer"

# 8. Admin can still delete (should work)
curl -X DELETE "http://localhost:5039/api/students/1" -H "X-Username: admin"
```

---

## Permission Matrix

| Operation | Endpoint | Method | Admin | Viewer | No Header |
|-----------|----------|--------|-------|--------|-----------|
| **Login** | `/api/auth/login` | POST | ✅ | ✅ | ✅ |
| **List Students** | `/api/students` | GET | ✅ | ✅ | ✅ |
| **Get Student** | `/api/students/{id}` | GET | ✅ | ✅ | ✅ |
| **Create Student** | `/api/students` | POST | ✅ | ❌ | ❌ |
| **Update Student** | `/api/students/{id}` | PUT | ✅ | ❌ | ❌ |
| **Delete Student** | `/api/students/{id}` | DELETE | ✅ | ❌ | ❌ |
| **Get Grades** | `/api/students/{id}/grades` | GET | ✅ | ✅ | ✅ |
| **Get Average** | `/api/students/{id}/average` | GET | ✅ | ✅ | ✅ |
| **Get Total** | `/api/students/{id}/total` | GET | ✅ | ✅ | ✅ |
| **Add Grade** | `/api/grades` | POST | ✅ | ❌ | ❌ |
| **Get Statistics** | `/api/statistics` | GET | ✅ | ✅ | ✅ |

**Legend:**
- ✅ = Allowed
- ❌ = Blocked (401 Unauthorized)

---

## Expected Error Messages

When Viewer tries to perform restricted operations, you should see:

### Create Student
```json
{
  "type": "https://tools.ietf.org/html/rfc7235#section-3.1",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Only Admin can create students"
}
```

### Update Student
```json
{
  "type": "https://tools.ietf.org/html/rfc7235#section-3.1",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Only Admin can update students"
}
```

### Delete Student
```json
{
  "type": "https://tools.ietf.org/html/rfc7235#section-3.1",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Only Admin can delete students"
}
```

### Add Grade
```json
{
  "type": "https://tools.ietf.org/html/rfc7235#section-3.1",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Only Admin can create grades"
}
```

---

## Troubleshooting

**"401 Unauthorized" when it should work**
- Check the `X-Username` header is set correctly
- Verify the username exists in the database
- Make sure you're using the correct username (admin or viewer)

**Viewer can perform admin operations**
- This is a bug! Check the role checking logic
- Verify the `CanEdit` method in `AuthService`

**Admin cannot perform operations**
- Check the `X-Username: admin` header is set
- Verify admin user exists in database
- Check the role is correctly set to "Admin" in database

**Login fails**
- Verify default users were created (admin/admin123, viewer/viewer123)
- Check database connection
- Verify password is correct

---

## Test Checklist

- [ ] Admin can login
- [ ] Viewer can login
- [ ] Admin can create students
- [ ] Admin can read students
- [ ] Admin can update students
- [ ] Admin can delete students
- [ ] Admin can add grades
- [ ] Viewer can read students
- [ ] Viewer can read student details
- [ ] Viewer can read grades
- [ ] Viewer can read statistics
- [ ] Viewer cannot create students
- [ ] Viewer cannot update students
- [ ] Viewer cannot delete students
- [ ] Viewer cannot add grades
- [ ] Error messages are clear and helpful

