# Project Architecture

## Overview

This is a **3-Layer Architecture** F# Web API application built with ASP.NET Core, following the **Repository/Service Pattern** with **Entity Framework Core** for data access.

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Frontend   │  │  Controllers │  │     DTOs     │      │
│  │  (GUI/HTML)  │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     BUSINESS LAYER                           │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │StudentService│  │ AuthService  │                        │
│  │              │  │              │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │StudentDbContext│ │   SQL Server │                        │
│  │  (EF Core)    │  │   Database   │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Breakdown

### 1. **Presentation Layer** (`Controllers/`, `DTOs/`, `gui/`)

#### **Controllers** (`Controllers/`)
- **Purpose**: Handle HTTP requests/responses, route API endpoints
- **Responsibilities**:
  - Receive HTTP requests
  - Validate input
  - Call service layer
  - Return HTTP responses (JSON)
  - Handle authorization/authentication

**Files:**
- `StudentsController.fs` - Student CRUD operations
- `GradesController.fs` - Grade management
- `StatisticsController.fs` - Class/subject statistics
- `AuthController.fs` - Authentication & login

**Example Flow:**
```
HTTP Request → Controller → Service → DbContext → Database
                                    ↓
HTTP Response ← Controller ← Service ← DbContext ← Database
```

#### **DTOs** (`DTOs/`)
- **Purpose**: Data Transfer Objects for API communication
- **Why**: Separate API contracts from internal models
- **File**: `StudentDto.fs` - Defines request/response shapes

#### **Frontend** (`gui/`)
- **Purpose**: User interface (HTML/CSS/JavaScript)
- **Files**:
  - `index.html` - UI structure
  - `script.js` - API client logic
  - `styles.css` - Styling

---

### 2. **Business Logic Layer** (`Services/`)

#### **StudentService** (`Services/StudentService.fs`)
- **Purpose**: Core business logic for students and grades
- **Responsibilities**:
  - CRUD operations (Create, Read, Update, Delete)
  - Grade calculations (averages, totals)
  - Statistics calculations (highest/lowest, pass rates)
  - Data validation and business rules

**Key Methods:**
- `AddStudent()` - Create new student
- `UpdateStudent()` - Update student info
- `DeleteStudent()` - Delete student (cascades to grades/users)
- `GetStudentAverage()` - Calculate student's average grade
- `GetClassStatistics()` - Overall class statistics
- `GetSubjectStatistics()` - Subject-specific statistics

#### **AuthService** (`Services/AuthService.fs`)
- **Purpose**: Authentication and authorization logic
- **Responsibilities**:
  - User login validation
  - Password verification
  - User creation
  - Role-based access control

**Key Methods:**
- `Login()` - Authenticate user
- `CreateUser()` - Create new user account
- `UpdateUserByStudentId()` - Update user linked to student
- `CanEdit()` - Check if role has edit permissions

---

### 3. **Data Access Layer** (`Data/`, `Models/`)

#### **StudentDbContext** (`Data/StudentDbContext.fs`)
- **Purpose**: Entity Framework Core database context
- **Responsibilities**:
  - Database connection management
  - Entity configuration (keys, relationships, constraints)
  - Query execution
  - Change tracking

**Key Features:**
- `Students` - DbSet<Student>
- `Grades` - DbSet<Grade>
- `Users` - DbSet<User>
- `OnModelCreating()` - Configures entity relationships and constraints

#### **Models** (`Models/`)
- **Purpose**: Domain entities (database table representations)
- **Files**:
  - `Student.fs` - Student and Grade records
  - `User.fs` - User record with Role

**Entity Relationships:**
```
Student (1) ────< (Many) Grade
   │
   │ (1:1 optional)
   ▼
 User
```

---

## Data Flow Example: Creating a Student

```
1. Frontend (script.js)
   └─> POST /api/students
       { name, studentId, email, password }

2. StudentsController.fs
   └─> Validates request
   └─> Checks authorization (Admin only)
   └─> Calls StudentService.AddStudent()

3. StudentService.fs
   └─> Validates StudentId uniqueness
   └─> Creates Student record
   └─> Calls AuthService.CreateUser() to create user account
   └─> Saves to database via DbContext

4. StudentDbContext.fs
   └─> Executes SQL INSERT
   └─> Returns new Student entity

5. Response flows back:
   StudentService → Controller → Frontend (JSON response)
```

---

## Key Architectural Patterns

### 1. **Dependency Injection**
- Services registered in `Program.fs`
- Controllers receive services via constructor injection
- DbContext injected into services

```fsharp
// Program.fs
builder.Services.AddScoped<StudentService>()
builder.Services.AddScoped<AuthService>()
builder.Services.AddDbContext<StudentDbContext>()
```

### 2. **Repository Pattern** (via EF Core)
- DbContext acts as repository
- Services encapsulate data access logic
- Controllers don't directly access database

### 3. **Service Layer Pattern**
- Business logic separated from controllers
- Controllers are thin (just HTTP handling)
- Services are reusable and testable

### 4. **DTO Pattern**
- Separate API contracts from domain models
- Prevents exposing internal structure
- Allows versioning API independently

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | ASP.NET Core 8.0 |
| **Language** | F# |
| **ORM** | Entity Framework Core 8.0 |
| **Database** | SQL Server / SQL Server Express |
| **Frontend** | Vanilla JavaScript (HTML/CSS/JS) |
| **Testing** | xUnit + WebApplicationFactory |
| **Architecture** | 3-Layer (Presentation/Business/Data) |

---

## Configuration

### **Program.fs** - Application Bootstrap
- Configures dependency injection
- Sets up database connection
- Registers services
- Configures CORS
- Seeds initial admin user
- Maps API routes

### **appsettings.json**
- Connection strings
- Application settings

---

## Security Features

1. **Role-Based Access Control (RBAC)**
   - Admin: Full CRUD access
   - Student/Viewer: Read-only access

2. **Authentication**
   - Username/password login
   - Session-based (via HTTP headers)

3. **CORS Configuration**
   - Allows frontend to call API
   - Configured in `Program.fs`

---

## Database Schema

### **Students Table**
- `Id` (PK, auto-increment)
- `Name` (string)
- `StudentId` (string, unique)
- `Email` (string)
- `CreatedAt` (DateTime)

### **Grades Table**
- `Id` (PK, auto-increment)
- `StudentId` (FK → Students.Id)
- `Subject` (string)
- `Score` (decimal 18,2)
- `MaxScore` (decimal 18,2)
- `DateRecorded` (DateTime)

### **Users Table**
- `Id` (PK, auto-increment)
- `Username` (string, unique)
- `Password` (string, hashed)
- `Role` (string: "Admin" | "Student")
- `StudentId` (FK → Students.Id, nullable)

---

## File Organization

```
F# project/
├── Controllers/          # API endpoints
│   ├── AuthController.fs
│   ├── StudentsController.fs
│   ├── GradesController.fs
│   └── StatisticsController.fs
├── Services/            # Business logic
│   ├── StudentService.fs
│   └── AuthService.fs
├── Data/                # Data access
│   └── StudentDbContext.fs
├── Models/              # Domain entities
│   ├── Student.fs
│   └── User.fs
├── DTOs/                # API contracts
│   └── StudentDto.fs
├── Program.fs           # Application entry point
└── appsettings.json     # Configuration
```

---

## Testing Architecture

### **Test Project** (`F# project.Tests/`)
- **Framework**: xUnit
- **Type**: Integration tests
- **Approach**: Uses `WebApplicationFactory` for in-memory testing
- **Database**: In-memory SQLite for isolation
- **Coverage**: API endpoints, HTTP status codes, response validation

---

## Benefits of This Architecture

✅ **Separation of Concerns** - Each layer has a single responsibility  
✅ **Testability** - Services can be tested independently  
✅ **Maintainability** - Changes in one layer don't affect others  
✅ **Scalability** - Easy to add new features or modify existing ones  
✅ **Reusability** - Services can be used by multiple controllers  
✅ **Type Safety** - F# provides strong typing and pattern matching  

---

## Future Enhancements

- Add repository abstraction layer
- Implement unit tests for services
- Add logging/monitoring
- Implement proper password hashing (bcrypt)
- Add API versioning
- Add Swagger/OpenAPI documentation
- Implement caching layer
- Add database migrations (EF Core Migrations)

