# Testing the API

## ⚠️ Important: Keep the Application Running

The application must be **running** in one terminal window while you test the API in another.

## 🚀 Step 1: Start the Application

In **Terminal 1**, run:
```bash
cd "F# project"
dotnet run --project "F# project\F# project.fsproj"
```

**Keep this terminal open!** The application needs to stay running.

## 🧪 Step 2: Test in Another Terminal

Open a **new terminal window** (Terminal 2) and run these commands:

### 1. Test Login
```bash
curl -X POST "http://localhost:5039/api/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
```

Expected response:
```json
{"username":"admin","role":"Admin","message":"Login successful"}
```

### 2. Create a Student
```bash
curl -X POST "http://localhost:5039/api/students" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"name\":\"John Doe\",\"studentId\":\"STU001\",\"email\":\"john@example.com\"}"
```

### 3. Get All Students
```bash
curl -X GET "http://localhost:5039/api/students" -H "X-Username: admin"
```

### 4. Add a Grade
```bash
curl -X POST "http://localhost:5039/api/grades" -H "Content-Type: application/json" -H "X-Username: admin" -d "{\"studentId\":1,\"subject\":\"Mathematics\",\"score\":85.5,\"maxScore\":100.0}"
```

### 5. Get Student Grades with Average
```bash
curl -X GET "http://localhost:5039/api/students/1/grades" -H "X-Username: admin"
```

### 6. Get Statistics
```bash
curl -X GET "http://localhost:5039/api/statistics" -H "X-Username: admin"
```

## 🌐 Alternative: Use a Browser or Postman

You can also test using:
- **Browser**: Navigate to `http://localhost:5039/api/students` (GET requests)
- **Postman**: Import the endpoints and test them
- **Swagger UI**: If enabled (not currently configured)

## 📝 Using PowerShell (Windows)

If `curl` doesn't work, use PowerShell's `Invoke-RestMethod`:

```powershell
# Login
Invoke-RestMethod -Uri "http://localhost:5039/api/auth/login" -Method Post -ContentType "application/json" -Body '{"username":"admin","password":"admin123"}'

# Create Student
$headers = @{"X-Username" = "admin"}
$body = '{"name":"John Doe","studentId":"STU001","email":"john@example.com"}'
Invoke-RestMethod -Uri "http://localhost:5039/api/students" -Method Post -ContentType "application/json" -Headers $headers -Body $body
```

## ⚠️ Common Issues

**"Could not connect to server"**
- Make sure the application is running in Terminal 1
- Check the port: `http://localhost:5039`
- Verify no firewall is blocking the connection

**"401 Unauthorized"**
- Make sure you include the `X-Username: admin` header for admin operations
- Verify you're using the correct username

**Application shuts down immediately**
- Check for errors in the terminal
- Verify SQL Server is running
- Check the connection string in `appsettings.json`

