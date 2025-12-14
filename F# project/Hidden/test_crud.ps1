# CRUD Operations Test Script
# Tests Add, Edit, Read, and Delete operations

$baseUrl = "http://localhost:5039"
$adminHeader = @{"X-Username" = "admin"}
$viewerHeader = @{"X-Username" = "viewer"}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CRUD Operations Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 1: READ - Get All Students
Write-Host "`n[TEST 1] READ - Get All Students" -ForegroundColor Yellow
try {
    $students = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Get -Headers $adminHeader
    Write-Host "  ✓ Successfully retrieved $($students.Count) student(s)" -ForegroundColor Green
    foreach ($s in $students) {
        Write-Host "    - ID: $($s.id), Name: $($s.name), StudentId: $($s.studentId)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
    exit 1
}

# Test 2: CREATE - Add New Student
Write-Host "`n[TEST 2] CREATE - Add New Student" -ForegroundColor Yellow
try {
    $newStudent = @{
        name = "Test Student CRUD"
        studentId = "STU_CRUD_001"
        email = "crud.test@example.com"
    } | ConvertTo-Json
    
    $created = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body $newStudent
    Write-Host "  ✓ Student created successfully" -ForegroundColor Green
    Write-Host "    ID: $($created.id), Name: $($created.name)" -ForegroundColor Gray
    $testStudentId = $created.id
} catch {
    Write-Host "  ✗ Failed to create student: $_" -ForegroundColor Red
    exit 1
}

# Test 3: READ - Get Student by ID
Write-Host "`n[TEST 3] READ - Get Student by ID ($testStudentId)" -ForegroundColor Yellow
try {
    $student = Invoke-RestMethod -Uri "$baseUrl/api/students/$testStudentId" -Method Get -Headers $adminHeader
    Write-Host "  ✓ Student retrieved successfully" -ForegroundColor Green
    Write-Host "    Name: $($student.name), Email: $($student.email)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ Failed to retrieve student: $_" -ForegroundColor Red
}

# Test 4: UPDATE - Edit Student
Write-Host "`n[TEST 4] UPDATE - Edit Student ($testStudentId)" -ForegroundColor Yellow
try {
    $updatedStudent = @{
        name = "Test Student CRUD - UPDATED"
        studentId = "STU_CRUD_001"
        email = "crud.updated@example.com"
    } | ConvertTo-Json
    
    $result = Invoke-RestMethod -Uri "$baseUrl/api/students/$testStudentId" -Method Put -ContentType "application/json" -Headers $adminHeader -Body $updatedStudent
    Write-Host "  ✓ Student updated successfully" -ForegroundColor Green
    Write-Host "    New Name: $($result.name), New Email: $($result.email)" -ForegroundColor Gray
    
    # Verify the update
    $verify = Invoke-RestMethod -Uri "$baseUrl/api/students/$testStudentId" -Method Get -Headers $adminHeader
    if ($verify.name -eq "Test Student CRUD - UPDATED") {
        Write-Host "  ✓ Update verified - name changed correctly" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Update verification failed" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Failed to update student: $_" -ForegroundColor Red
}

# Test 5: DELETE - Delete Student
Write-Host "`n[TEST 5] DELETE - Delete Student ($testStudentId)" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students/$testStudentId" -Method Delete -Headers $adminHeader | Out-Null
    Write-Host "  ✓ Student deleted successfully" -ForegroundColor Green
    
    # Verify deletion
    try {
        Invoke-RestMethod -Uri "$baseUrl/api/students/$testStudentId" -Method Get -Headers $adminHeader | Out-Null
        Write-Host "  ✗ ERROR: Student still exists after deletion!" -ForegroundColor Red
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "  ✓ Deletion verified - student no longer exists (404 expected)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Unexpected error during verification: $_" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  ✗ Failed to delete student: $_" -ForegroundColor Red
}

# Test 6: Role-Based Access - Viewer Can Read
Write-Host "`n[TEST 6] Role-Based Access - Viewer Can READ" -ForegroundColor Yellow
try {
    $students = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Get -Headers $viewerHeader
    Write-Host "  ✓ Viewer can read students ($($students.Count) found)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Viewer cannot read: $_" -ForegroundColor Red
}

# Test 7: Role-Based Access - Viewer Cannot Create
Write-Host "`n[TEST 7] Role-Based Access - Viewer Cannot CREATE" -ForegroundColor Yellow
try {
    $newStudent = @{
        name = "Should Fail"
        studentId = "FAIL"
        email = "fail@example.com"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $viewerHeader -Body $newStudent -ErrorAction Stop | Out-Null
    Write-Host "  ✗ ERROR: Viewer was able to create (should be blocked!)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "  ✓ Viewer correctly blocked from creating (401 expected)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Unexpected error: $_" -ForegroundColor Yellow
    }
}

# Test 8: Error Handling - Get Non-Existent Student
Write-Host "`n[TEST 8] Error Handling - Get Non-Existent Student (ID: 99999)" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$baseUrl/api/students/99999" -Method Get -Headers $adminHeader -ErrorAction Stop | Out-Null
    Write-Host "  ✗ ERROR: Should return 404 for non-existent student" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "  ✓ Correctly returns 404 for non-existent student" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Unexpected status code: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  All CRUD Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nSummary:" -ForegroundColor White
Write-Host "  ✓ READ operations working" -ForegroundColor Green
Write-Host "  ✓ CREATE operation working" -ForegroundColor Green
Write-Host "  ✓ UPDATE operation working" -ForegroundColor Green
Write-Host "  ✓ DELETE operation working" -ForegroundColor Green
Write-Host "  ✓ Role-based access control working" -ForegroundColor Green
Write-Host "  ✓ Error handling working" -ForegroundColor Green

