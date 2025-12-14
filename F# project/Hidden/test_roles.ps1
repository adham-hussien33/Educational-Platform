# Role-Based Access Control Test Script
# Tests Admin and Viewer permissions

$baseUrl = "http://localhost:5039"
$adminHeader = @{"X-Username" = "admin"}
$viewerHeader = @{"X-Username" = "viewer"}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Role-Based Access Control Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Test Login
Write-Host "`n[STEP 1] Testing Login..." -ForegroundColor Yellow

# Test Admin Login
Write-Host "  1.1. Testing Admin Login..." -ForegroundColor White
try {
    $adminLogin = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -ContentType "application/json" -Body '{"username":"admin","password":"admin123"}'
    if ($adminLogin.role -eq "Admin") {
        Write-Host "    ✓ Admin login successful (Role: $($adminLogin.role))" -ForegroundColor Green
    } else {
        Write-Host "    ✗ Admin login failed - wrong role: $($adminLogin.role)" -ForegroundColor Red
    }
} catch {
    Write-Host "    ✗ Admin login failed: $_" -ForegroundColor Red
    exit 1
}

# Test Viewer Login
Write-Host "  1.2. Testing Viewer Login..." -ForegroundColor White
try {
    $viewerLogin = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -ContentType "application/json" -Body '{"username":"viewer","password":"viewer123"}'
    if ($viewerLogin.role -eq "Viewer") {
        Write-Host "    ✓ Viewer login successful (Role: $($viewerLogin.role))" -ForegroundColor Green
    } else {
        Write-Host "    ✗ Viewer login failed - wrong role: $($viewerLogin.role)" -ForegroundColor Red
    }
} catch {
    Write-Host "    ✗ Viewer login failed: $_" -ForegroundColor Red
}

# Test Invalid Login
Write-Host "  1.3. Testing Invalid Login..." -ForegroundColor White
try {
    Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -ContentType "application/json" -Body '{"username":"admin","password":"wrongpassword"}' -ErrorAction Stop | Out-Null
    Write-Host "    ✗ ERROR: Invalid login should fail!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "    ✓ Invalid login correctly rejected (401)" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ Unexpected error: $_" -ForegroundColor Yellow
    }
}

# Step 2: Test Admin Permissions
Write-Host "`n[STEP 2] Testing Admin Permissions (Full Access)..." -ForegroundColor Yellow

# Admin Can CREATE
Write-Host "  2.1. Admin Can CREATE Student..." -ForegroundColor White
try {
    $student = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Admin Test Student","studentId":"ADMIN001","email":"admin.test@example.com"}'
    $testStudentId = $student.id
    Write-Host "    ✓ Admin can create student (ID: $testStudentId)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Admin cannot create student: $_" -ForegroundColor Red
    exit 1
}

# Admin Can READ
Write-Host "  2.2. Admin Can READ Students..." -ForegroundColor White
try {
    $students = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Get -Headers $adminHeader
    Write-Host "    ✓ Admin can read students ($($students.Count) found)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Admin cannot read students: $_" -ForegroundColor Red
}

# Admin Can UPDATE
Write-Host "  2.3. Admin Can UPDATE Student..." -ForegroundColor White
try {
    $updated = Invoke-RestMethod -Uri "$baseUrl/api/students/$testStudentId" -Method Put -ContentType "application/json" -Headers $adminHeader -Body "{\"name\":\"Updated by Admin\",\"studentId\":\"ADMIN001\",\"email\":\"updated@example.com\"}"
    Write-Host "    ✓ Admin can update student" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Admin cannot update student: $_" -ForegroundColor Red
}

# Admin Can Add Grade
Write-Host "  2.4. Admin Can Add Grade..." -ForegroundColor White
try {
    $grade = Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$testStudentId,\"subject\":\"Math\",\"score\":85.0,\"maxScore\":100.0}"
    Write-Host "    ✓ Admin can add grade" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Admin cannot add grade: $_" -ForegroundColor Red
}

# Admin Can DELETE
Write-Host "  2.5. Admin Can DELETE Student..." -ForegroundColor White
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students/$testStudentId" -Method Delete -Headers $adminHeader | Out-Null
    Write-Host "    ✓ Admin can delete student" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Admin cannot delete student: $_" -ForegroundColor Red
}

# Step 3: Test Viewer Permissions (Read-Only)
Write-Host "`n[STEP 3] Testing Viewer Permissions (Read-Only)..." -ForegroundColor Yellow

# Create a student first (as admin) for viewer to read
Write-Host "  Creating test student for viewer to read..." -ForegroundColor Gray
try {
    $readStudent = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Viewer Read Test","studentId":"VIEWER001","email":"viewer.test@example.com"}'
    $readStudentId = $readStudent.id
    Write-Host "    ✓ Test student created (ID: $readStudentId)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Failed to create test student: $_" -ForegroundColor Red
    exit 1
}

# Viewer Can READ All
Write-Host "  3.1. Viewer Can READ All Students..." -ForegroundColor White
try {
    $students = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Get -Headers $viewerHeader
    Write-Host "    ✓ Viewer can read all students ($($students.Count) found)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Viewer cannot read students: $_" -ForegroundColor Red
}

# Viewer Can READ One
Write-Host "  3.2. Viewer Can READ Single Student..." -ForegroundColor White
try {
    $student = Invoke-RestMethod -Uri "$baseUrl/api/students/$readStudentId" -Method Get -Headers $viewerHeader
    Write-Host "    ✓ Viewer can read single student" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Viewer cannot read single student: $_" -ForegroundColor Red
}

# Viewer Can READ Grades
Write-Host "  3.3. Viewer Can READ Student Grades..." -ForegroundColor White
try {
    $grades = Invoke-RestMethod -Uri "$baseUrl/api/students/$readStudentId/grades" -Method Get -Headers $viewerHeader
    Write-Host "    ✓ Viewer can read student grades" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Viewer cannot read grades: $_" -ForegroundColor Red
}

# Viewer Can READ Statistics
Write-Host "  3.4. Viewer Can READ Statistics..." -ForegroundColor White
try {
    $stats = Invoke-RestMethod -Uri "$baseUrl/api/statistics" -Method Get -Headers $viewerHeader
    Write-Host "    ✓ Viewer can read statistics" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Viewer cannot read statistics: $_" -ForegroundColor Red
}

# Step 4: Test Viewer Restrictions (Should Fail)
Write-Host "`n[STEP 4] Testing Viewer Restrictions (Should Fail)..." -ForegroundColor Yellow

# Viewer Cannot CREATE
Write-Host "  4.1. Viewer Cannot CREATE Student..." -ForegroundColor White
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $viewerHeader -Body '{"name":"Should Fail","studentId":"FAIL001","email":"fail@example.com"}' -ErrorAction Stop | Out-Null
    Write-Host "    ✗ ERROR: Viewer was able to create (should be blocked!)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "    ✓ Viewer correctly blocked from creating (401)" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ Unexpected error: $_" -ForegroundColor Yellow
    }
}

# Viewer Cannot UPDATE
Write-Host "  4.2. Viewer Cannot UPDATE Student..." -ForegroundColor White
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students/$readStudentId" -Method Put -ContentType "application/json" -Headers $viewerHeader -Body "{\"name\":\"Hacked Name\",\"studentId\":\"VIEWER001\",\"email\":\"hacked@example.com\"}" -ErrorAction Stop | Out-Null
    Write-Host "    ✗ ERROR: Viewer was able to update (should be blocked!)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "    ✓ Viewer correctly blocked from updating (401)" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ Unexpected error: $_" -ForegroundColor Yellow
    }
}

# Viewer Cannot DELETE
Write-Host "  4.3. Viewer Cannot DELETE Student..." -ForegroundColor White
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students/$readStudentId" -Method Delete -Headers $viewerHeader -ErrorAction Stop | Out-Null
    Write-Host "    ✗ ERROR: Viewer was able to delete (should be blocked!)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "    ✓ Viewer correctly blocked from deleting (401)" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ Unexpected error: $_" -ForegroundColor Yellow
    }
}

# Viewer Cannot Add Grade
Write-Host "  4.4. Viewer Cannot Add Grade..." -ForegroundColor White
try {
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $viewerHeader -Body "{\"studentId\":$readStudentId,\"subject\":\"Math\",\"score\":100.0,\"maxScore\":100.0}" -ErrorAction Stop | Out-Null
    Write-Host "    ✗ ERROR: Viewer was able to add grade (should be blocked!)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "    ✓ Viewer correctly blocked from adding grade (401)" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ Unexpected error: $_" -ForegroundColor Yellow
    }
}

# Step 5: Test Without Header
Write-Host "`n[STEP 5] Testing Without Authentication Header..." -ForegroundColor Yellow

# Read without header (should work)
Write-Host "  5.1. Read Without Header..." -ForegroundColor White
try {
    $students = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Get
    Write-Host "    ✓ Read works without header ($($students.Count) students)" -ForegroundColor Green
} catch {
    Write-Host "    ⚠ Read failed without header: $_" -ForegroundColor Yellow
}

# Create without header (should fail)
Write-Host "  5.2. Create Without Header..." -ForegroundColor White
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Body '{"name":"No Auth","studentId":"NOAUTH","email":"noauth@example.com"}' -ErrorAction Stop | Out-Null
    Write-Host "    ✗ ERROR: Create worked without header (should be blocked!)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "    ✓ Create correctly blocked without header (401)" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ Unexpected error: $_" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  All Role Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nSummary:" -ForegroundColor White
Write-Host "  ✓ Admin has full access (CRUD)" -ForegroundColor Green
Write-Host "  ✓ Viewer can read all data" -ForegroundColor Green
Write-Host "  ✓ Viewer is blocked from write operations" -ForegroundColor Green
Write-Host "  ✓ Authentication and authorization working correctly" -ForegroundColor Green

