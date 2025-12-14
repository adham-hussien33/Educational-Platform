# Student Grades Management System

A comprehensive F# web API application for managing student records and grades with role-based access control and SQL Server database.

## Features

### ✅ Requirement 1: Student Model Designer
- F# records for Student, Grade, and User entities
- Proper data structures with Entity Framework Core

### ✅ Requirement 2: CRUD Developer
- **Add** student records
- **Edit** student information
- **Delete** student records (with cascade delete for grades)
- Full CRUD operations for grades

### ✅ Requirement 3: Grade Calculation Developer
- Calculate student averages (percentage)
- Calculate student totals (score and max score)
- Calculate subject-specific averages
- All calculations handle edge cases (empty grades, zero max scores)

### ✅ Requirement 4: Statistician
- Class-wide statistics:
  - Highest average student
  - Lowest average student
  - Pass rate (students with ≥60% average)
  - Total students count
  - Total grades count

### ✅ Requirement 5: Role Manager
- Role-based access control (Admin/Viewer)
- Admin: Full access (create, update, delete)
- Viewer: Read-only access
- Authentication via username/password

### ✅ Requirement 6: Persistence Developer
- SQL Server database integration
- Entity Framework Core for data access
- Automatic database creation on startup
- Connection string configuration

### ✅ Requirement 7: UI Developer
- RESTful API endpoints
- JSON request/response format
- Swagger/OpenAPI support (via ASP.NET Core)
- CORS enabled for frontend integration

## Prerequisites

Before running this project, ensure you have:

1. **.NET 8.0 SDK** or later
   - Download from: https://dotnet.microsoft.com/download
   - Verify installation: `dotnet --version`

2. **SQL Server**
   - SQL Server Express, Developer, or Standard Edition
   - Or SQL Server LocalDB (included with Visual Studio)
   - Verify installation: SQL Server Management Studio (SSMS) or `sqlcmd`

3. **Code Editor** (optional)
   - Visual Studio 2022 with F# support
   - Visual Studio Code with Ionide extension
   - Rider

## Setup Instructions

### Step 1: Configure SQL Server Connection

1. Open `F# project/F# project/appsettings.json`

2. Update the connection string if needed:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

**Connection String Options:**
- **LocalDB**: `Server=(localdb)\\mssqllocaldb;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;`
- **SQL Server Express**: `Server=localhost\\SQLEXPRESS;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;`
- **Named Instance**: `Server=localhost\\YourInstanceName;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;`
- **With Username/Password**: `Server=localhost;Database=StudentGradesDB;User Id=youruser;Password=yourpassword;TrustServerCertificate=True;`

### Step 2: Navigate to Project Directory

**Important:** Navigate to the directory containing the `.fsproj` file:

```bash
cd "F# project/F# project"
```

**Alternative:** You can run commands from the solution directory using the `--project` flag:
```bash
# From "F# project" directory
dotnet restore --project "F# project\F# project.fsproj"
```

### Step 3: Restore NuGet Packages

```bash
dotnet restore
```

### Step 4: Build the Project

```bash
dotnet build
```

### Step 5: Run the Application

```bash
dotnet run
```

**Or from the solution directory:**
```bash
dotnet run --project "F# project/F# project.fsproj"
```

The application will:
- Start on `https://localhost:7189` (HTTPS) or `http://localhost:5039` (HTTP)
- Automatically create the database if it doesn't exist
- Seed initial users:
  - **Admin**: username=`admin`, password=`admin123`
  - **Viewer**: username=`viewer`, password=`viewer123`

## Running the Project

### Option 1: Command Line

**Navigate to project directory first:**
```bash
cd "F# project/F# project"
dotnet run
```

**Or run from solution directory:**
```bash
# From "F# project" directory
dotnet run --project "F# project\F# project.fsproj"
```

### Option 2: Visual Studio

1. Open `F# project.sln` in Visual Studio
2. Press `F5` or click "Start Debugging"
3. The browser will open automatically

### Option 3: Visual Studio Code

1. Open the project folder in VS Code
2. Press `F5` or use the terminal: `dotnet run`

## API Endpoints

### Authentication

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

#### Register (for initial setup)
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "newuser",
  "password": "password123",
  "role": "Admin"  // or "Viewer"
}
```

### Students (CRUD Operations)

#### Get All Students
```
GET /api/students
Headers: X-Username: admin (optional for viewing)
```

#### Get Student by ID
```
GET /api/students/{id}
Headers: X-Username: admin (optional)
```

#### Create Student (Admin only)
```
POST /api/students
Headers: X-Username: admin
Content-Type: application/json

{
  "name": "John Doe",
  "studentId": "STU001",
  "email": "john.doe@example.com"
}
```

#### Update Student (Admin only)
```
PUT /api/students/{id}
Headers: X-Username: admin
Content-Type: application/json

{
  "name": "John Smith",
  "studentId": "STU001",
  "email": "john.smith@example.com"
}
```

#### Delete Student (Admin only)
```
DELETE /api/students/{id}
Headers: X-Username: admin
```

### Grades

#### Get Student Grades
```
GET /api/students/{id}/grades
Headers: X-Username: admin (optional)
```

#### Get Student Average
```
GET /api/students/{id}/average
Headers: X-Username: admin (optional)
```

#### Get Student Total
```
GET /api/students/{id}/total
Headers: X-Username: admin (optional)
```

#### Add Grade (Admin only)
```
POST /api/grades
Headers: X-Username: admin
Content-Type: application/json

{
  "studentId": 1,
  "subject": "Mathematics",
  "score": 85.5,
  "maxScore": 100.0
}
```

### Statistics

#### Get Class Statistics
```
GET /api/statistics
Headers: X-Username: admin (optional)
```

Response includes:
- Highest average student
- Lowest average student
- Pass rate percentage
- Total students count
- Total grades count

## Testing with cURL

### Example: Create a Student
```bash
curl -X POST "https://localhost:7189/api/students" \
  -H "Content-Type: application/json" \
  -H "X-Username: admin" \
  -d "{\"name\":\"John Doe\",\"studentId\":\"STU001\",\"email\":\"john@example.com\"}" \
  -k
```

### Example: Add a Grade
```bash
curl -X POST "https://localhost:7189/api/grades" \
  -H "Content-Type: application/json" \
  -H "X-Username: admin" \
  -d "{\"studentId\":1,\"subject\":\"Mathematics\",\"score\":85.5,\"maxScore\":100.0}" \
  -k
```

### Example: Get Statistics
```bash
curl -X GET "https://localhost:7189/api/statistics" \
  -H "X-Username: admin" \
  -k
```

## Testing with Postman

1. Import the API endpoints into Postman
2. Set the base URL: `https://localhost:7189` or `http://localhost:5039`
3. Add header `X-Username: admin` for admin operations
4. For HTTPS with self-signed certificate, disable SSL verification in Postman settings

## Project Structure

```
F# project/
├── F# project/
│   ├── Controllers/
│   │   ├── AuthController.fs      # Authentication endpoints
│   │   ├── StudentsController.fs  # Student CRUD operations
│   │   ├── GradesController.fs     # Grade management
│   │   └── StatisticsController.fs # Class statistics
│   ├── Data/
│   │   └── StudentDbContext.fs    # Entity Framework context
│   ├── DTOs/
│   │   └── StudentDto.fs           # Data transfer objects
│   ├── Models/
│   │   ├── Student.fs              # Student and Grade models
│   │   └── User.fs                   # User and Role models
│   ├── Services/
│   │   ├── StudentService.fs      # Business logic (CRUD + Calculations)
│   │   └── AuthService.fs          # Authentication logic
│   ├── Program.fs                   # Application entry point
│   ├── appsettings.json            # Configuration
│   └── F# project.fsproj           # Project file
└── README.md                        # This file
```

## Default Users

The application automatically creates these users on first run:

| Username | Password | Role   | Permissions                    |
|----------|----------|--------|-------------------------------|
| admin    | admin123 | Admin  | Full access (CRUD operations) |
| viewer   | viewer123| Viewer | Read-only access              |

## Troubleshooting

### Database Connection Issues

**Error: "Cannot open database"**
- Ensure SQL Server is running
- Check connection string in `appsettings.json`
- Verify database server name/instance is correct
- For LocalDB, ensure it's installed and running

**Error: "Login failed for user"**
- Check Windows Authentication is enabled
- Or update connection string with SQL Server credentials

### Port Already in Use

If port 5039 or 7189 is in use:
1. Update `Properties/launchSettings.json`
2. Change the `applicationUrl` values
3. Or stop the process using the port

### SSL Certificate Issues

For HTTPS with self-signed certificates:
- Use `-k` flag with cURL
- Disable SSL verification in Postman
- Or use HTTP endpoint on port 5039

## Development Notes

- The database is automatically created on first run using `EnsureCreated()`
- For production, use migrations: `dotnet ef migrations add InitialCreate`
- All calculations handle edge cases (empty lists, zero divisions)
- Role-based access is enforced at the controller level
- CORS is enabled for all origins (configure for production)

## Next Steps

1. **Add Migrations**: Use Entity Framework migrations for better database versioning
2. **Add Validation**: Implement input validation and error handling
3. **Add Logging**: Implement comprehensive logging
4. **Add Tests**: Create unit and integration tests
5. **Add Swagger UI**: Enable Swagger for interactive API documentation
6. **Secure Authentication**: Implement JWT tokens or OAuth
7. **Add Frontend**: Create a web UI using React, Vue, or Blazor

## License

This project is created for educational purposes.

