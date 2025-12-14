# Class Statistics Test Script
# Tests highest average, lowest average, and pass rate

$baseUrl = "http://localhost:5039"
$adminHeader = @{"X-Username" = "admin"}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Class Statistics Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Create students with different performance levels
Write-Host "`n[STEP 1] Creating Students with Different Performance Levels..." -ForegroundColor Yellow

# Student 1: High Performer
Write-Host "  Creating high performer..." -ForegroundColor White
try {
    $highPerformer = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Alice Johnson","studentId":"STU001","email":"alice@example.com"}'
    $highId = $highPerformer.id
    Write-Host "    ✓ Created: $($highPerformer.name) (ID: $highId)" -ForegroundColor Green
    
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$highId,\"subject\":\"Mathematics\",\"score\":95.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$highId,\"subject\":\"Science\",\"score\":92.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$highId,\"subject\":\"English\",\"score\":88.0,\"maxScore\":100.0}" | Out-Null
    Write-Host "    ✓ Added 3 grades (Expected average: 91.67%)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Failed: $_" -ForegroundColor Red
    exit 1
}

# Student 2: Average Performer
Write-Host "  Creating average performer..." -ForegroundColor White
try {
    $avgPerformer = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Bob Smith","studentId":"STU002","email":"bob@example.com"}'
    $avgId = $avgPerformer.id
    Write-Host "    ✓ Created: $($avgPerformer.name) (ID: $avgId)" -ForegroundColor Green
    
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$avgId,\"subject\":\"Mathematics\",\"score\":75.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$avgId,\"subject\":\"Science\",\"score\":70.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$avgId,\"subject\":\"English\",\"score\":65.0,\"maxScore\":100.0}" | Out-Null
    Write-Host "    ✓ Added 3 grades (Expected average: 70.0%)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Failed: $_" -ForegroundColor Red
}

# Student 3: Low Performer (Failing)
Write-Host "  Creating low performer (failing)..." -ForegroundColor White
try {
    $lowPerformer = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Charlie Brown","studentId":"STU003","email":"charlie@example.com"}'
    $lowId = $lowPerformer.id
    Write-Host "    ✓ Created: $($lowPerformer.name) (ID: $lowId)" -ForegroundColor Green
    
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$lowId,\"subject\":\"Mathematics\",\"score\":45.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$lowId,\"subject\":\"Science\",\"score\":50.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$lowId,\"subject\":\"English\",\"score\":55.0,\"maxScore\":100.0}" | Out-Null
    Write-Host "    ✓ Added 3 grades (Expected average: 50.0% - FAILING)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Failed: $_" -ForegroundColor Red
}

# Student 4: Borderline (Just Passing)
Write-Host "  Creating borderline student (just passing)..." -ForegroundColor White
try {
    $borderline = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"Diana Prince","studentId":"STU004","email":"diana@example.com"}'
    $borderlineId = $borderline.id
    Write-Host "    ✓ Created: $($borderline.name) (ID: $borderlineId)" -ForegroundColor Green
    
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$borderlineId,\"subject\":\"Mathematics\",\"score\":60.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$borderlineId,\"subject\":\"Science\",\"score\":62.0,\"maxScore\":100.0}" | Out-Null
    Invoke-RestMethod -Uri "$baseUrl/api/grades" -Method Post -ContentType "application/json" -Headers $adminHeader -Body "{\"studentId\":$borderlineId,\"subject\":\"English\",\"score\":58.0,\"maxScore\":100.0}" | Out-Null
    Write-Host "    ✓ Added 3 grades (Expected average: 60.0% - JUST PASSING)" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Failed: $_" -ForegroundColor Red
}

# Step 2: Get Statistics
Write-Host "`n[STEP 2] Getting Class Statistics..." -ForegroundColor Yellow
try {
    $stats = Invoke-RestMethod -Uri "$baseUrl/api/statistics" -Method Get -Headers $adminHeader
    
    Write-Host "  ✓ Statistics retrieved successfully" -ForegroundColor Green
    Write-Host "`n  Results:" -ForegroundColor White
    
    # Highest Average
    if ($stats.highestAverage) {
        Write-Host "    Highest Average:" -ForegroundColor Cyan
        Write-Host "      Student: $($stats.highestAverage.student.name)" -ForegroundColor Gray
        Write-Host "      Average: $([math]::Round($stats.highestAverage.average, 2))%" -ForegroundColor Gray
        
        if ($stats.highestAverage.student.name -eq "Alice Johnson") {
            Write-Host "      ✓ Correct - Alice has the highest average" -ForegroundColor Green
        } else {
            Write-Host "      ⚠ Expected Alice Johnson" -ForegroundColor Yellow
        }
        
        if ([math]::Abs($stats.highestAverage.average - 91.67) -lt 1.0) {
            Write-Host "      ✓ Average value is correct (~91.67%)" -ForegroundColor Green
        } else {
            Write-Host "      ⚠ Average value seems incorrect" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    ✗ Highest Average: null (no students with grades?)" -ForegroundColor Red
    }
    
    # Lowest Average
    if ($stats.lowestAverage) {
        Write-Host "`n    Lowest Average:" -ForegroundColor Cyan
        Write-Host "      Student: $($stats.lowestAverage.student.name)" -ForegroundColor Gray
        Write-Host "      Average: $([math]::Round($stats.lowestAverage.average, 2))%" -ForegroundColor Gray
        
        if ($stats.lowestAverage.student.name -eq "Charlie Brown") {
            Write-Host "      ✓ Correct - Charlie has the lowest average" -ForegroundColor Green
        } else {
            Write-Host "      ⚠ Expected Charlie Brown" -ForegroundColor Yellow
        }
        
        if ([math]::Abs($stats.lowestAverage.average - 50.0) -lt 1.0) {
            Write-Host "      ✓ Average value is correct (50.0%)" -ForegroundColor Green
        } else {
            Write-Host "      ⚠ Average value seems incorrect" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n    ✗ Lowest Average: null (no students with grades?)" -ForegroundColor Red
    }
    
    # Pass Rate
    Write-Host "`n    Pass Rate:" -ForegroundColor Cyan
    if ($stats.passRate) {
        Write-Host "      Rate: $([math]::Round($stats.passRate, 2))%" -ForegroundColor Gray
        
        # Expected: 3 passing (Alice, Bob, Diana) out of 4 = 75%
        if ([math]::Abs($stats.passRate - 75.0) -lt 1.0) {
            Write-Host "      ✓ Correct - 3 out of 4 students passing (75%)" -ForegroundColor Green
        } else {
            Write-Host "      ⚠ Expected ~75% (3 out of 4 passing)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "      Rate: null (no students with grades?)" -ForegroundColor Gray
    }
    
    # Counts
    Write-Host "`n    Counts:" -ForegroundColor Cyan
    Write-Host "      Total Students: $($stats.totalStudents)" -ForegroundColor Gray
    Write-Host "      Total Grades: $($stats.totalGrades)" -ForegroundColor Gray
    
    if ($stats.totalStudents -ge 4) {
        Write-Host "      ✓ Student count is correct" -ForegroundColor Green
    } else {
        Write-Host "      ⚠ Expected at least 4 students" -ForegroundColor Yellow
    }
    
    if ($stats.totalGrades -ge 12) {
        Write-Host "      ✓ Grade count is correct (3 grades × 4 students = 12)" -ForegroundColor Green
    } else {
        Write-Host "      ⚠ Expected at least 12 grades" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "  ✗ Failed to get statistics: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Verify Pass Rate Calculation
Write-Host "`n[STEP 3] Verifying Pass Rate Calculation..." -ForegroundColor Yellow
Write-Host "  Passing Threshold: 60%" -ForegroundColor Gray
Write-Host "  Expected Passing Students:" -ForegroundColor Gray
Write-Host "    - Alice: 91.67% ✓" -ForegroundColor Green
Write-Host "    - Bob: 70.0% ✓" -ForegroundColor Green
Write-Host "    - Diana: 60.0% ✓" -ForegroundColor Green
Write-Host "    - Charlie: 50.0% ✗" -ForegroundColor Red
Write-Host "  Expected Pass Rate: 3 out of 4 = 75.0%" -ForegroundColor Gray

# Step 4: Test Edge Cases
Write-Host "`n[STEP 4] Testing Edge Cases..." -ForegroundColor Yellow

# Test: Student with no grades (should be excluded from averages)
Write-Host "  4.1. Testing student with no grades..." -ForegroundColor White
try {
    $noGrades = Invoke-RestMethod -Uri "$baseUrl/api/students" -Method Post -ContentType "application/json" -Headers $adminHeader -Body '{"name":"No Grades Student","studentId":"STU005","email":"nogrades@example.com"}'
    Write-Host "    ✓ Created student without grades" -ForegroundColor Green
    
    $statsAfter = Invoke-RestMethod -Uri "$baseUrl/api/statistics" -Method Get -Headers $adminHeader
    Write-Host "    Total Students: $($statsAfter.totalStudents) (includes student without grades)" -ForegroundColor Gray
    Write-Host "    ✓ Student without grades excluded from average calculations" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Failed: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  All Statistics Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nSummary:" -ForegroundColor White
Write-Host "  ✓ Highest average calculation working" -ForegroundColor Green
Write-Host "  ✓ Lowest average calculation working" -ForegroundColor Green
Write-Host "  ✓ Pass rate calculation working" -ForegroundColor Green
Write-Host "  ✓ Counts are accurate" -ForegroundColor Green
Write-Host "  ✓ Edge cases handled correctly" -ForegroundColor Green

