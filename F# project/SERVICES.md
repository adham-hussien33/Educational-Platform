# Service Layer Documentation

## Overview

The **Service Layer** is the **Business Logic Layer** of the application. It sits between the **Controllers** (Presentation Layer) and the **DbContext** (Data Layer), encapsulating all business rules, calculations, and data operations.

---

## Architecture Position

```
┌─────────────────┐
│   Controllers    │  ← HTTP requests/responses
└────────┬─────────┘
         │ calls
         ▼
┌─────────────────┐
│    Services     │  ← Business logic (YOU ARE HERE)
└────────┬─────────┘
         │ uses
         ▼
┌─────────────────┐
│   DbContext     │  ← Database access
└─────────────────┘
```

---

## Service Registration

Services are registered in `Program.fs` using **Dependency Injection**:

```fsharp
// Program.fs
builder.Services.AddScoped<StudentService>() |> ignore
builder.Services.AddScoped<AuthService>() |> ignore
```

**Why `AddScoped`?**
- Creates **one instance per HTTP request**
- Ensures each request has its own service instance
- Automatically disposed after request completes

---

## Service 1: StudentService

**File**: `Services/StudentService.fs`  
**Purpose**: Handles all student and grade-related business logic

### Constructor

```fsharp
type StudentService(dbContext: StudentDbContext) =
```

- Receives `StudentDbContext` via dependency injection
- DbContext is injected automatically by ASP.NET Core

---

### CRUD Operations

#### 1. **AddStudent** - Create New Student

```fsharp
member this.AddStudent(name: string, studentId: string, email: string)
```

**What it does:**
1. Checks if `StudentId` already exists (uniqueness validation)
2. Creates new `Student` record
3. Saves to database
4. Returns the created student

**Business Rules:**
- ✅ Validates `StudentId` uniqueness
- ✅ Throws exception if `StudentId` already exists
- ✅ Auto-generates `Id` (database auto-increment)
- ✅ Sets `CreatedAt` to current timestamp

**Example:**
```fsharp
let student = studentService.AddStudent("John Doe", "STU001", "john@example.com")
```

---

#### 2. **GetStudentById** - Get Student by Primary Key

```fsharp
member this.GetStudentById(id: int) : Student option
```

**What it does:**
- Queries database for student with matching `Id`
- Returns `Some student` if found, `None` if not found

**Returns:** `Student option` (F# option type for null safety)

---

#### 3. **GetStudentByStudentId** - Get Student by Student ID String

```fsharp
member this.GetStudentByStudentId(studentId: string) : Student option
```

**What it does:**
- Finds student by their `StudentId` string (e.g., "STU001")
- Used when frontend sends `StudentId` instead of database `Id`

---

#### 4. **GetAllStudents** - Get All Students

```fsharp
member this.GetAllStudents() : Student list
```

**What it does:**
- Retrieves all students from database
- Returns as F# list

---

#### 5. **UpdateStudent** - Update Student Information

```fsharp
member this.UpdateStudent(id: int, name: string, studentId: string, email: string) : Student option
```

**What it does:**
1. Finds student by `id`
2. Validates new `StudentId` uniqueness (if changed)
3. Updates student properties
4. Saves changes
5. Returns `Some updatedStudent` or `None` if not found

**Key Features:**
- ✅ Uses `AsNoTracking()` to prevent Entity Framework tracking conflicts
- ✅ Validates `StudentId` uniqueness before updating
- ✅ Returns `None` if student doesn't exist

**Example:**
```fsharp
match studentService.UpdateStudent(1, "Jane Doe", "STU001", "jane@example.com") with
| Some student -> printfn "Updated: %s" student.Name
| None -> printfn "Student not found"
```

---

#### 6. **DeleteStudent** - Delete Student with Cascade

```fsharp
member this.DeleteStudent(id: int) : bool
```

**What it does:**
1. Finds student by `id`
2. **Deletes all associated grades** (cascade delete)
3. **Deletes associated user account** (if exists)
4. Deletes the student
5. Returns `true` if deleted, `false` if not found

**Important:** This method handles **cascade deletion** manually:
- Deletes all `Grade` records where `Grade.StudentId = id`
- Deletes `User` record where `User.StudentId = Some id`
- Then deletes the `Student` record

**Why manual cascade?**
- Entity Framework doesn't automatically cascade for optional relationships
- Ensures data integrity

**Example:**
```fsharp
if studentService.DeleteStudent(1) then
    printfn "Student deleted successfully"
else
    printfn "Student not found"
```

---

### Grade Operations

#### 7. **AddGrade** - Create New Grade

```fsharp
member this.AddGrade(studentId: int, subject: string, score: decimal, maxScore: decimal) : Grade
```

**What it does:**
- Creates new `Grade` record
- Links to student via `studentId`
- Sets `DateRecorded` to current timestamp
- Saves to database

---

#### 8. **GetGradesByStudentId** - Get All Grades for a Student

```fsharp
member this.GetGradesByStudentId(studentId: int) : Grade list
```

**What it does:**
- Retrieves all grades for a specific student
- Returns as F# list

---

#### 9. **GetStudentWithGrades** - Get Student with All Grades

```fsharp
member this.GetStudentWithGrades(studentId: int) : StudentWithGrades option
```

**What it does:**
- Combines student info with their grades
- Returns `StudentWithGrades` record (contains `Student` and `Grades` list)

---

### Grade Calculations

#### 10. **CalculateStudentAverage** - Calculate Student's Overall Average

```fsharp
member this.CalculateStudentAverage(studentId: int) : decimal option
```

**What it does:**
1. Gets all grades for the student
2. Calculates: `(Total Score / Total Max Score) * 100`
3. Returns `Some percentage` or `None` if no grades or division by zero

**Formula:**
```
Average = (Sum of all Scores / Sum of all MaxScores) * 100
```

**Example:**
- Grade 1: 80/100
- Grade 2: 90/100
- Average = (80 + 90) / (100 + 100) * 100 = 85%

**Returns:** `decimal option` (None if no grades or maxScore is 0)

---

#### 11. **CalculateStudentTotal** - Get Total Scores

```fsharp
member this.CalculateStudentTotal(studentId: int) : {| TotalScore: decimal; TotalMaxScore: decimal |}
```

**What it does:**
- Sums all `Score` values
- Sums all `MaxScore` values
- Returns anonymous record with totals

**Example:**
```fsharp
let totals = studentService.CalculateStudentTotal(1)
// totals.TotalScore = 170m
// totals.TotalMaxScore = 200m
```

---

#### 12. **CalculateSubjectAverage** - Calculate Average for a Subject

```fsharp
member this.CalculateSubjectAverage(subject: string) : decimal option
```

**What it does:**
- Calculates average across all students for a specific subject
- Uses same formula as `CalculateStudentAverage`

---

### Statistics Operations

#### 13. **GetClassStatistics** - Overall Class Statistics

```fsharp
member this.GetClassStatistics() : StatisticsRecord
```

**What it does:**
1. Gets all students and all grades
2. Calculates each student's average
3. Finds **highest average** student
4. Finds **lowest average** student
5. Calculates **pass rate** (students with ≥60% average)
6. Counts total students and total grades

**Returns:**
```fsharp
{|
    HighestAverage = Some {| Student = Student; Average = decimal |} | None
    LowestAverage = Some {| Student = Student; Average = decimal |} | None
    PassRate = Some decimal | None  // Percentage of passing students
    TotalStudents = int
    TotalGrades = int
|}
```

**Error Handling:**
- Wrapped in `try-catch` blocks
- Returns empty statistics if errors occur (graceful degradation)
- Logs errors to debug output

**Example:**
```fsharp
let stats = studentService.GetClassStatistics()
match stats.HighestAverage with
| Some h -> printfn "Highest: %s with %.2f%%" h.Student.Name h.Average
| None -> printfn "No students with grades"
```

---

#### 14. **GetSubjectStatistics** - Subject-Specific Statistics

```fsharp
member this.GetSubjectStatistics(subject: string) : StatisticsRecord
```

**What it does:**
1. Filters grades by subject (case-insensitive)
2. Calculates percentage for **each individual grade**
3. Finds **highest individual grade** (not average)
4. Finds **lowest individual grade** (not average)
5. Calculates pass rate based on individual grades
6. Counts unique students and total grades for that subject

**Key Differences from `GetClassStatistics`:**
- ✅ Filters by subject (case-insensitive matching)
- ✅ Finds highest/lowest **individual grade**, not student average
- ✅ Handles null/empty subject gracefully

**Example:**
```fsharp
let mathStats = studentService.GetSubjectStatistics("Math")
// Returns highest and lowest individual Math grades across all students
```

**Subject Matching:**
- Case-insensitive: "Math" = "math" = "MATH"
- Trims whitespace
- Handles null/empty subjects

---

## Service 2: AuthService

**File**: `Services/AuthService.fs`  
**Purpose**: Handles authentication, authorization, and user management

### Constructor

```fsharp
type AuthService(dbContext: StudentDbContext) =
```

---

### Authentication Methods

#### 1. **Authenticate** - Login Validation

```fsharp
member this.Authenticate(username: string, password: string) : User option
```

**What it does:**
1. Converts username to lowercase for comparison
2. Queries database for matching username and password
3. Returns `Some user` if credentials match, `None` if invalid

**Security Note:** Currently uses plain text password comparison. In production, use password hashing (bcrypt, Argon2, etc.)

**Example:**
```fsharp
match authService.Authenticate("admin", "admin123") with
| Some user -> printfn "Logged in as: %s" user.Username
| None -> printfn "Invalid credentials"
```

---

#### 2. **GetUserRole** - Get User's Role

```fsharp
member this.GetUserRole(username: string) : Role option
```

**What it does:**
- Finds user by username
- Converts role string to `Role` discriminated union
- Returns `Some Admin` or `Some Student` or `None`

**Role Types:**
```fsharp
type Role =
    | Admin    // Full access
    | Student  // Read-only access
```

---

### User Management

#### 3. **CreateUser** - Create New User Account

```fsharp
member this.CreateUser(username: string, password: string, role: Role, studentId: int option) : User
```

**What it does:**
1. Converts `Role` to string ("Admin" or "Student")
2. Creates new `User` record
3. Links to student if `studentId` is provided
4. Saves to database

**Example:**
```fsharp
let user = authService.CreateUser("john", "password123", Role.Student, Some 1)
```

---

#### 4. **GetUserByUsername** - Find User by Username

```fsharp
member this.GetUserByUsername(username: string) : User option
```

**What it does:**
- Case-insensitive username lookup
- Returns `Some user` or `None`

---

#### 5. **GetStudentIdByUsername** - Get Student ID from Username

```fsharp
member this.GetStudentIdByUsername(username: string) : int option
```

**What it does:**
- Finds user by username
- Returns their linked `StudentId` (if exists)

---

### Authorization Methods

#### 6. **IsAdmin** - Check if Role is Admin

```fsharp
member this.IsAdmin(role: Role option) : bool
```

**What it does:**
- Returns `true` if role is `Some Admin`, `false` otherwise

---

#### 7. **CanEdit** - Check if Role Can Edit

```fsharp
member this.CanEdit(role: Role option) : bool
```

**What it does:**
- Returns `true` if role is `Some Admin` (only admins can edit)
- Returns `false` for `Student` role or `None`

**Usage in Controllers:**
```fsharp
let role = this.GetCurrentRole()
if not (authService.CanEdit(role)) then
    this.Unauthorized("Only Admin can update students")
```

---

### User Update Methods

#### 8. **UpdateUserPassword** - Change User Password

```fsharp
member this.UpdateUserPassword(username: string, newPassword: string) : User option
```

**What it does:**
- Finds user by username
- Updates password
- Returns `Some updatedUser` or `None` if user not found

---

#### 9. **UpdateUserByStudentId** - Update User Linked to Student

```fsharp
member this.UpdateUserByStudentId(studentId: int, newUsername: string, newPassword: string) : User option
```

**What it does:**
1. Finds user by `StudentId` (where `User.StudentId = Some studentId`)
2. Uses `AsNoTracking()` to prevent tracking conflicts
3. Updates username and password
4. Saves changes

**Why `AsNoTracking()`?**
- Prevents Entity Framework from tracking the entity
- Avoids "entity already tracked" errors when updating

**Used when:** Student is updated, and we need to update their linked user account

---

## How Controllers Use Services

### Example: StudentsController

```fsharp
type StudentsController(studentService: StudentService, authService: AuthService, dbContext: StudentDbContext) =
    inherit ControllerBase()

    [<HttpPost>]
    member this.Create([<FromBody>] dto: CreateStudentDto) : IActionResult =
        // 1. Check authorization
        let role = this.GetCurrentRole()
        if not (authService.CanEdit(role)) then
            this.Unauthorized() :> IActionResult
        else
            // 2. Call service
            try
                let student = studentService.AddStudent(dto.Name, dto.StudentId, dto.Email)
                // 3. Create user account
                let username = // ... sanitize name ...
                authService.CreateUser(username, dto.Password, Role.Student, Some student.Id) |> ignore
                // 4. Return response
                this.Created($"/api/students/{student.Id}", student) :> IActionResult
            with
            | ex -> this.BadRequest(ex.Message) :> IActionResult
```

**Flow:**
1. Controller receives HTTP request
2. Controller calls `authService.CanEdit()` to check permissions
3. Controller calls `studentService.AddStudent()` to create student
4. Controller calls `authService.CreateUser()` to create user account
5. Controller returns HTTP response

---

## Service Design Principles

### 1. **Single Responsibility**
- Each service has one clear purpose
- `StudentService` = Student/Grade operations
- `AuthService` = Authentication/Authorization

### 2. **Dependency Injection**
- Services receive dependencies via constructor
- No direct instantiation of `DbContext`
- Testable and mockable

### 3. **Option Types for Null Safety**
- Methods return `option` types instead of null
- Forces callers to handle "not found" cases
- Prevents null reference exceptions

### 4. **Error Handling**
- Uses F# exceptions (`failwith`) for validation errors
- Wraps risky operations in `try-catch`
- Returns empty results instead of crashing

### 5. **Business Logic Encapsulation**
- Controllers are thin (just HTTP handling)
- All business rules in services
- Reusable across different controllers

---

## Service Lifecycle

```
HTTP Request Starts
    ↓
ASP.NET Core creates new scope
    ↓
Creates new StudentService instance
Creates new AuthService instance
Creates new StudentDbContext instance
    ↓
Controller uses services
    ↓
HTTP Request Ends
    ↓
ASP.NET Core disposes services
    ↓
DbContext connection closed
```

**Why Scoped?**
- One instance per request
- Ensures data consistency
- Automatic cleanup

---

## Testing Services

Services can be tested independently:

```fsharp
// Example test
[<Fact>]
let ``AddStudent creates student with unique StudentId`` () =
    use dbContext = new StudentDbContext(options)
    let service = new StudentService(dbContext)
    
    let student = service.AddStudent("Test", "STU001", "test@example.com")
    
    Assert.NotNull(student)
    Assert.Equal("STU001", student.StudentId)
```

---

## Summary

**StudentService:**
- ✅ CRUD operations for students
- ✅ Grade management
- ✅ Grade calculations (averages, totals)
- ✅ Statistics (class-wide and subject-specific)
- ✅ Cascade deletion

**AuthService:**
- ✅ User authentication
- ✅ Role-based authorization
- ✅ User management
- ✅ Password updates

**Key Benefits:**
- ✅ Separation of concerns
- ✅ Reusable business logic
- ✅ Testable code
- ✅ Type-safe (F# option types)
- ✅ Error handling built-in

