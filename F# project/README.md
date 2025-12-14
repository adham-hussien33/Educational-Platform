# Student Grades Management System

A comprehensive F# web API application for managing student records and grades with role-based access control and SQL Server database.

## 🚀 Features

- ✅ **Student CRUD Operations** - Create, Read, Update, Delete students
- ✅ **Grade Management** - Add and manage student grades
- ✅ **Grade Calculations** - Calculate averages, totals, and subject-specific statistics
- ✅ **Class Statistics** - Highest/lowest averages, pass rates, and more
- ✅ **Subject-Specific Statistics** - Filter statistics by subject
- ✅ **Role-Based Access Control** - Admin and Student roles
- ✅ **RESTful API** - Clean API endpoints with JSON responses
- ✅ **Frontend GUI** - HTML/CSS/JavaScript interface
- ✅ **Automated Tests** - xUnit integration tests

## 📋 Prerequisites

- .NET 8.0 SDK or later
- SQL Server (Express, Developer, or Standard Edition)
- Git (for cloning)

## 🛠️ Setup

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd "F# project"
   ```

2. **Configure database connection:**
   - Edit `F# project/appsettings.json`
   - Update the connection string to match your SQL Server instance

3. **Run the application:**
   ```bash
   cd "F# project"
   dotnet run
   ```

4. **Access the application:**
   - API: `http://localhost:5039`
   - Frontend: Open `gui/index.html` in a browser

## 📚 Documentation

- [Architecture Overview](ARCHITECTURE.md) - Project architecture and design
- [Services Documentation](SERVICES.md) - Service layer details
- [Test Documentation](F#%20project.Tests/README.md) - How to run tests

## 🧪 Running Tests

```bash
cd "F# project.Tests"
dotnet test
```

## 🏗️ Project Structure

```
F# project/
├── F# project/          # Main application
│   ├── Controllers/     # API endpoints
│   ├── Services/        # Business logic
│   ├── Data/            # Database context
│   ├── Models/          # Domain entities
│   ├── DTOs/            # Data transfer objects
│   └── gui/             # Frontend interface
├── F# project.Tests/    # Test project
└── README.md            # This file
```

## 🔐 Default Users

- **Admin**: `admin` / `admin123` (Full access)
- **Student**: Created automatically when adding students

## 📝 License

This project is for educational purposes.

## 👤 Author

Student Grades Management System - F# ASP.NET Core Web API

