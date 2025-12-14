# F# Project - GUI Testing Guide

This GUI allows you to test all functionality of your F# Student Grades Management API.

## Quick Start

### Step 1: Start the F# API Server

Open a terminal/command prompt and navigate to your F# project directory:

```bash
cd "F# project/F# project"
```

Then run the API:

```bash
dotnet run
```

The API will start on `http://localhost:5039` (or check the console output for the actual URL).

**Note:** Make sure SQL Server is running and the database connection is configured correctly.

### Step 2: Open the GUI

1. Open `gui/index.html` in your web browser
   - You can double-click the file, or
   - Right-click → Open with → Your preferred browser

2. The GUI will automatically check the connection status (indicator in the header)

### Step 3: Login

Default credentials:
- **Admin**: `admin` / `admin123` (Full access - can create/edit/delete)

**Note:** When you create a new student, a user account is automatically created:
- **Username**: The student's name (lowercase, no spaces) - e.g., "John Doe" becomes "johndoe"
- **Password**: Set by admin when creating the student
- **Role**: Student (can only view their own grades)

If the API is running on a different port, update the "API URL" field before logging in.

## Testing Features

### 1. **Login & Authentication**
- Test login with admin account
- Students can log in with their name (lowercase, no spaces) as username and the password set by admin
- See role-based access control in action
- Logout functionality

### 2. **Students Management**
- **Add Student**: Create new students (Admin only)
- **View All Students**: See list of all students
- **View Student Grades**: Click "View Grades" button on any student
- **Delete Student**: Delete students (Admin only)

### 3. **Grades Management**
- **Add Grade**: Add grades for students (Admin only)
- Required fields:
  - Student ID (the database ID number, not the StudentId string)
  - Subject name
  - Score
  - Max Score

### 4. **Student Grades View**
- **For Admin**: Enter a student ID to view all their grades
- **For Students**: Automatically displays their own grades upon login
- See calculated average and total scores
- View individual grade details

### 5. **Statistics**
- View class-wide statistics:
  - Total students
  - Total grades
  - Highest average student
  - Lowest average student
  - Pass rate (if applicable)

## Testing Workflow

### Complete Test Scenario:

1. **Login as Admin**
   - Username: `admin`
   - Password: `admin123`

2. **Add a Student**
   - Name: "John Doe" (this will be the username: "johndoe")
   - Student ID: "STU001"
   - Email: "john@example.com"
   - Password: Enter a password for the student account (e.g., "password123")
   - Click "Add Student"

3. **View Students**
   - Click "Refresh" to see the new student
   - Note the Database ID (you'll need this for adding grades)

4. **Add Grades**
   - Use the Database ID from step 3
   - Add multiple grades:
     - Math: 85/100
     - Science: 90/100
     - English: 78/100

5. **View Student Grades**
   - Click "View Grades" button on the student card, or
   - Enter the Database ID and click "View Grades"
   - Verify average and totals are calculated correctly

6. **Check Statistics**
   - Click "Refresh Statistics"
   - Verify the statistics reflect your data

7. **Test Student Access**
   - Logout
   - Login as a student (use the student's name as username - lowercase, no spaces, and the password set by admin)
   - Example: If student name is "John Doe" and password is "password123", login as `johndoe` / `password123`
   - Your grades will automatically load
   - Try to add a student (should fail - Student role)
   - You can only view your own grades, not other students

## Troubleshooting

### Connection Issues

**Problem:** Status shows "Disconnected"
- **Solution:** 
  1. Verify the API is running (`dotnet run` in the F# project directory)
  2. Check the API URL matches the port shown in the console
  3. Ensure CORS is enabled (it should be by default in your F# project)

**Problem:** "Failed to fetch" errors
- **Solution:**
  1. Check browser console (F12) for detailed errors
  2. Verify API URL is correct
  3. Ensure API is running on the specified port

### Authentication Issues

**Problem:** "Unauthorized" errors when adding/editing
- **Solution:**
  1. Make sure you're logged in as Admin (not Student)
  2. Check that the X-Username header is being sent (should be automatic)
  3. Verify your login was successful

**Problem:** Student can't see their grades
- **Solution:**
  1. Make sure the student account was created when the student was added
  2. Verify the student is logged in with their name (lowercase, no spaces) as username and the password set by admin
  3. Check that grades have been added for that student

### Data Issues

**Problem:** Can't add grades
- **Solution:**
  1. Make sure you're using the Database ID (number), not the StudentId string
  2. Check that the student exists first
  3. Verify you're logged in as Admin

**Problem:** Statistics not showing
- **Solution:**
  1. Make sure you have students with grades
  2. Click "Refresh Statistics" button
  3. Check browser console for errors

## API Endpoints Tested

The GUI tests the following endpoints:

- `POST /api/auth/login` - User authentication
- `GET /api/students` - Get all students
- `POST /api/students` - Create student (Admin only)
- `DELETE /api/students/{id}` - Delete student (Admin only)
- `GET /api/students/{id}/grades` - Get student with grades
- `POST /api/grades` - Add grade (Admin only)
- `GET /api/statistics` - Get class statistics

## Browser Compatibility

This GUI works best in modern browsers:
- Chrome/Edge (recommended)
- Firefox
- Safari

## Notes

- The GUI uses fetch API for HTTP requests
- CORS must be enabled on the API (already configured in your F# project)
- All API calls include proper error handling
- The connection status indicator updates automatically
- Role-based UI elements show/hide based on user permissions

## File Structure

```
gui/
├── index.html      # Main HTML structure
├── styles.css      # All styling
├── script.js       # API integration and functionality
└── README.md       # This file
```

Enjoy testing your F# project! 🚀

