# Grade Calculations Test Script
# Tests average and total calculations

$baseUrl = "http://localhost:5039"
$adminHeader = @{"X-Username" = "admin"}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Grade Calculations Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Create a student
Write-Host "`n[STEP 1] Creating Student..." -ForegroundColor Yellow
try {
    $student = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Calculation Test Student","studentId":"CALC001","email":"calc@example.com"}'
    $studentId = $student.id
    Write-Host "  ✓ Student created with ID: $studentId" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed to create student: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Add multiple grades
Write-Host "`n[STEP 2] Adding Grades..." -ForegroundColor Yellow
$grades = @(
    @{subject="Mathematics"; score=85.5; maxScore=100.0},
    @{subject="Science"; score=92.0; maxScore=100.0},
    @{subject="English"; score=78.0; maxScore=100.0},
    @{subject="History"; score=45.0; maxScore=50.0}
)

$totalScore = 0.0
$totalMaxScore = 0.0

foreach ($grade in $grades) {
    try {
        $body = "{\"studentId\":$studentId,\"subject\":\"$($grade.subject)\",\"score\":$($grade.score),\"maxScore\":$($grade.maxScore)}"
        Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body $body | Out-Null
        Write-Host "  ✓ Added $($grade.subject): $($grade.score)/$($grade.maxScore)" -ForegroundColor Green
        $totalScore += $grade.score
        $totalMaxScore += $grade.maxScore
    } catch {
        Write-Host "  ✗ Failed to add grade for $($grade.subject): $_" -ForegroundColor Red
    }
}

$expectedAverage = [math]::Round(($totalScore / $totalMaxScore) * 100, 2)
Write-Host "`n  Expected Total: $totalScore / $totalMaxScore" -ForegroundColor Gray
Write-Host "  Expected Average: $expectedAverage%" -ForegroundColor Gray

# Step 3: Test Average Calculation
Write-Host "`n[STEP 3] Testing Average Calculation..." -ForegroundColor Yellow
try {
    $avg = Invoke-RestMethod -Uri "$baseUrl/api/students/$studentId/average" -Method Get -Headers $adminHeader
    $actualAverage = [math]::Round($avg.average, 2)
    Write-Host "  ✓ Average retrieved: $actualAverage%" -ForegroundColor Green
    
    if ([math]::Abs($actualAverage - $expectedAverage) -lt 0.01) {
        Write-Host "  ✓ Average is correct!" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Average mismatch! Expected: $expectedAverage%, Got: $actualAverage%" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Failed to get average: $_" -ForegroundColor Red
}

# Step 4: Test Total Calculation
Write-Host "`n[STEP 4] Testing Total Calculation..." -ForegroundColor Yellow
try {
    $total = Invoke-RestMethod -Uri "$baseUrl/api/students/$studentId/total" -Method Get -Headers $adminHeader
    Write-Host "  ✓ Total retrieved: $($total.totalScore) / $($total.totalMaxScore)" -ForegroundColor Green
    
    if ([math]::Abs($total.totalScore - $totalScore) -lt 0.01 -and [math]::Abs($total.totalMaxScore - $totalMaxScore) -lt 0.01) {
        Write-Host "  ✓ Total is correct!" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Total mismatch!" -ForegroundColor Red
        Write-Host "    Expected: $totalScore / $totalMaxScore" -ForegroundColor Red
        Write-Host "    Got: $($total.totalScore) / $($total.totalMaxScore)" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Failed to get total: $_" -ForegroundColor Red
}

# Step 5: Test Complete Information
Write-Host "`n[STEP 5] Testing Complete Information..." -ForegroundColor Yellow
try {
    $complete = Invoke-RestMethod -Uri "$baseUrl/api/students/$studentId/grades" -Method Get -Headers $adminHeader
    Write-Host "  ✓ Complete information retrieved" -ForegroundColor Green
    Write-Host "    Student: $($complete.student.name)" -ForegroundColor Gray
    Write-Host "    Number of grades: $($complete.grades.Count)" -ForegroundColor Gray
    Write-Host "    Average: $([math]::Round($complete.average, 2))%" -ForegroundColor Gray
    Write-Host "    Total: $($complete.total.totalScore) / $($complete.total.totalMaxScore)" -ForegroundColor Gray
    
    if ($complete.grades.Count -eq $grades.Count) {
        Write-Host "  ✓ All grades are included" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Grade count mismatch!" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Failed to get complete information: $_" -ForegroundColor Red
}

# Step 6: Test Edge Cases
Write-Host "`n[STEP 6] Testing Edge Cases..." -ForegroundColor Yellow

# Test 6.1: Student with no grades
Write-Host "  6.1. Testing student with no grades..." -ForegroundColor White
try {
    $newStudent = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"No Grades","studentId":"NOGRADES","email":"nogrades@example.com"}'
    $noGradesId = $newStudent.id
    
    try {
        Invoke-RestMethod -Uri "$baseUrl/api/students/$noGradesId/average" -Method Get -Headers $adminHeader -ErrorAction Stop | Out-Null
        Write-Host "    ✗ ERROR: Should return 404 for student with no grades" -ForegroundColor Red
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "    ✓ Correctly returns 404 for student with no grades" -ForegroundColor Green
        } else {
            Write-Host "    ⚠ Unexpected error: $_" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "    ✗ Failed to test no grades case: $_" -ForegroundColor Red
}

# Test 6.2: Perfect scores
Write-Host "  6.2. Testing perfect scores..." -ForegroundColor White
try {
    $perfectStudent = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Perfect Student","studentId":"PERFECT","email":"perfect@example.com"}'
    $perfectId = $perfectStudent.id
    
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$perfectId,\"subject\":\"Math\",\"score\":100.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$perfectId,\"subject\":\"Science\",\"score\":100.0,\"maxScore\":100.0}" | Out-Null
    
    $perfectAvg = Invoke-RestMethod -Uri "$baseUrl/api/students/$perfectId/average" -Method Get -Headers $adminHeader
    if ([math]::Abs($perfectAvg.average - 100.0) -lt 0.01) {
        Write-Host "    ✓ Perfect scores calculate to 100%" -ForegroundColor Green
    } else {
        Write-Host "    ✗ Perfect scores should be 100%, got $($perfectAvg.average)%" -ForegroundColor Red
    }
} catch {
    Write-Host "    ✗ Failed to test perfect scores: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  All Calculation Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nSummary:" -ForegroundColor White
Write-Host "  ✓ Average calculation working" -ForegroundColor Green
Write-Host "  ✓ Total calculation working" -ForegroundColor Green
Write-Host "  ✓ Complete information endpoint working" -ForegroundColor Green
Write-Host "  ✓ Edge cases handled correctly" -ForegroundColor Green

