namespace F__project.Controllers

open Microsoft.AspNetCore.Mvc
open Microsoft.AspNetCore.Authorization
open Microsoft.EntityFrameworkCore
open F__project.Services
open F__project.DTOs
open F__project.Models
open F__project.Data
open System

[<ApiController>]
[<Route("api/[controller]")>]
type StudentsController(studentService: StudentService, authService: AuthService, dbContext: StudentDbContext) =
    inherit ControllerBase()

    // Helper to get current user role from header
    member private this.GetCurrentRole() =
        if this.Request.Headers.ContainsKey("X-Username") then
            let username = this.Request.Headers["X-Username"].ToString().Trim()
            if not (String.IsNullOrEmpty(username)) then
                authService.GetUserRole(username)
            else
                None
        else
            None

    // GET: api/students
    [<HttpGet>]
    member this.GetAll() : IActionResult =
        let students = studentService.GetAllStudents()
        let response =
            students
            |> List.map (fun s ->
                { Id = s.Id
                  Name = s.Name
                  StudentId = s.StudentId
                  Email = s.Email
                  CreatedAt = s.CreatedAt })
        this.Ok(response) :> IActionResult

    // GET: api/students/5
    [<HttpGet("{id}")>]
    member this.GetById(id: int) : IActionResult =
        match studentService.GetStudentById(id) with
        | Some student ->
            this.Ok(
                { Id = student.Id
                  Name = student.Name
                  StudentId = student.StudentId
                  Email = student.Email
                  CreatedAt = student.CreatedAt }
            ) :> IActionResult
        | None -> this.NotFound() :> IActionResult

    // POST: api/students
    [<HttpPost>]
    member this.Create([<FromBody>] dto: CreateStudentDto) : IActionResult =
        let role = this.GetCurrentRole()
        if not (authService.CanEdit(role)) then
            this.Unauthorized("Only Admin can create students") :> IActionResult
        else
            try
                let student = studentService.AddStudent(dto.Name, dto.StudentId, dto.Email)
                // Create a user account for the student
                // Username is the student's name (sanitized for username format)
                // Password is provided by admin
                let username = 
                    dto.Name.ToLower()
                        .Replace(" ", "") // Remove spaces
                        .Replace("-", "") // Remove hyphens
                        .Replace("_", "") // Remove underscores
                        .Replace(".", "") // Remove periods
                        .Replace(",", "") // Remove commas
                        .Replace("'", "") // Remove apostrophes
                        |> fun s -> System.Text.RegularExpressions.Regex.Replace(s, "[^a-z0-9]", "") // Remove any other non-alphanumeric characters
                let password = dto.Password
                authService.CreateUser(username, password, Role.Student, Some student.Id) |> ignore
                
                this.CreatedAtAction(
                    "GetById",
                    {| id = student.Id |},
                    { Id = student.Id
                      Name = student.Name
                      StudentId = student.StudentId
                      Email = student.Email
                      CreatedAt = student.CreatedAt }
                ) :> IActionResult
            with
            | ex when ex.Message.Contains("already exists") ->
                this.BadRequest(ex.Message) :> IActionResult
            | ex -> this.BadRequest($"Error creating student: {ex.Message}") :> IActionResult

    // PUT: api/students/5
    [<HttpPut("{id}")>]
    member this.Update(id: int, [<FromBody>] dto: UpdateStudentDto) : IActionResult =
        let role = this.GetCurrentRole()
        if not (authService.CanEdit(role)) then
            this.Unauthorized("Only Admin can update students") :> IActionResult
        else
            try
                // Update student record
                // Note: Grades table uses Student.Id (primary key) as foreign key,
                // so Grades will automatically remain linked since we're not changing the Id
                match studentService.UpdateStudent(id, dto.Name, dto.StudentId, dto.Email) with
                | Some student ->
                    // Update related User account username and password
                    let newUsername = 
                        dto.Name.ToLower()
                            .Replace(" ", "")
                            .Replace("-", "")
                            .Replace("_", "")
                            .Replace(".", "")
                            .Replace(",", "")
                            .Replace("'", "")
                            |> fun s -> System.Text.RegularExpressions.Regex.Replace(s, "[^a-z0-9]", "")
                    
                    // Update user account - only update password if provided
                    match dto.Password with
                    | Some password when password.Length > 0 ->
                        match authService.UpdateUserByStudentId(id, newUsername, password) with
                        | Some _ -> ()
                        | None -> () // User account might not exist, that's okay
                    | _ ->
                        // Only update username, keep existing password
                        // Try to find user by student ID and update username (no tracking to avoid conflicts)
                        let userOpt = 
                            query {
                                for user in dbContext.Users.AsNoTracking() do
                                    where (user.StudentId = Some id)
                                    select user
                                    take 1
                            }
                            |> Seq.tryHead
                        match userOpt with
                        | Some user ->
                            let updatedUser = { user with Username = newUsername }
                            dbContext.Users.Update(updatedUser) |> ignore
                            dbContext.SaveChanges() |> ignore
                        | None -> ()
                    
                    // Grades remain linked automatically since they reference Student.Id (primary key)
                    // which doesn't change during update
                    
                    this.Ok(
                        { Id = student.Id
                          Name = student.Name
                          StudentId = student.StudentId
                          Email = student.Email
                          CreatedAt = student.CreatedAt }
                    ) :> IActionResult
                | None -> this.NotFound() :> IActionResult
            with
            | ex when ex.Message.Contains("already exists") ->
                this.BadRequest(ex.Message) :> IActionResult
            | ex -> this.BadRequest($"Error updating student: {ex.Message}") :> IActionResult

    // DELETE: api/students/5
    [<HttpDelete("{id}")>]
    member this.Delete(id: int) : IActionResult =
        let role = this.GetCurrentRole()
        if not (authService.CanEdit(role)) then
            this.Unauthorized("Only Admin can delete students") :> IActionResult
        else
            if studentService.DeleteStudent(id) then
                this.NoContent() :> IActionResult
            else
                this.NotFound() :> IActionResult

    // GET: api/students/5/grades
    [<HttpGet("{id}/grades")>]
    member this.GetGrades(id: int) : IActionResult =
        match studentService.GetStudentWithGrades(id) with
        | Some studentWithGrades ->
            let gradeDtos =
                studentWithGrades.Grades
                |> List.map (fun g ->
                    { Id = g.Id
                      StudentId = g.StudentId
                      Subject = g.Subject
                      Score = g.Score
                      MaxScore = g.MaxScore
                      Percentage = (g.Score / g.MaxScore) * 100m
                      DateRecorded = g.DateRecorded })

            let studentDto: StudentResponseDto =
                { Id = studentWithGrades.Student.Id
                  Name = studentWithGrades.Student.Name
                  StudentId = studentWithGrades.Student.StudentId
                  Email = studentWithGrades.Student.Email
                  CreatedAt = studentWithGrades.Student.CreatedAt }

            let average = studentService.CalculateStudentAverage(id)
            let total = studentService.CalculateStudentTotal(id)

            let response: StudentWithGradesResponseDto =
                { Student = studentDto
                  Grades = gradeDtos
                  Average = average
                  Total = total }

            this.Ok(response) :> IActionResult
        | None -> this.NotFound() :> IActionResult

    // GET: api/students/5/average
    [<HttpGet("{id}/average")>]
    member this.GetAverage(id: int) : IActionResult =
        match studentService.CalculateStudentAverage(id) with
        | Some avg -> this.Ok({| StudentId = id; Average = avg |}) :> IActionResult
        | None -> this.NotFound("Student has no grades") :> IActionResult

    // GET: api/students/5/total
    [<HttpGet("{id}/total")>]
    member this.GetTotal(id: int) : IActionResult =
        let total = studentService.CalculateStudentTotal(id)
        this.Ok(total) :> IActionResult

    // GET: api/students/my-grades (for students to view their own grades)
    [<HttpGet("my-grades")>]
    member this.GetMyGrades() : IActionResult =
        if not (this.Request.Headers.ContainsKey("X-Username")) then
            this.Unauthorized("Username header required") :> IActionResult
        else
            let username = this.Request.Headers["X-Username"].ToString().Trim()
            if String.IsNullOrEmpty(username) then
                this.Unauthorized("Username header is empty") :> IActionResult
            else
                match authService.GetStudentIdByUsername(username) with
                | Some studentId ->
                    match studentService.GetStudentWithGrades(studentId) with
                    | Some studentWithGrades ->
                        let gradeDtos =
                            studentWithGrades.Grades
                            |> List.map (fun g ->
                                { Id = g.Id
                                  StudentId = g.StudentId
                                  Subject = g.Subject
                                  Score = g.Score
                                  MaxScore = g.MaxScore
                                  Percentage = (g.Score / g.MaxScore) * 100m
                                  DateRecorded = g.DateRecorded })

                        let studentDto: StudentResponseDto =
                            { Id = studentWithGrades.Student.Id
                              Name = studentWithGrades.Student.Name
                              StudentId = studentWithGrades.Student.StudentId
                              Email = studentWithGrades.Student.Email
                              CreatedAt = studentWithGrades.Student.CreatedAt }

                        let average = studentService.CalculateStudentAverage(studentId)
                        let total = studentService.CalculateStudentTotal(studentId)

                        let response: StudentWithGradesResponseDto =
                            { Student = studentDto
                              Grades = gradeDtos
                              Average = average
                              Total = total }

                        this.Ok(response) :> IActionResult
                    | None -> this.NotFound() :> IActionResult
                | None -> this.Unauthorized("User is not associated with a student") :> IActionResult

    // GET: api/students/by-username/{username}/grades (for admin to search by username)
    [<HttpGet("by-username/{username}/grades")>]
    member this.GetGradesByUsername(username: string) : IActionResult =
        let role = this.GetCurrentRole()
        if not (authService.CanEdit(role)) then
            this.Unauthorized("Only Admin can view student grades by username") :> IActionResult
        else
            let usernameLower = username.ToLower().Trim()
            match authService.GetStudentIdByUsername(usernameLower) with
            | Some studentId ->
                match studentService.GetStudentWithGrades(studentId) with
                | Some studentWithGrades ->
                    let gradeDtos =
                        studentWithGrades.Grades
                        |> List.map (fun g ->
                            { Id = g.Id
                              StudentId = g.StudentId
                              Subject = g.Subject
                              Score = g.Score
                              MaxScore = g.MaxScore
                              Percentage = (g.Score / g.MaxScore) * 100m
                              DateRecorded = g.DateRecorded })

                    let studentDto: StudentResponseDto =
                        { Id = studentWithGrades.Student.Id
                          Name = studentWithGrades.Student.Name
                          StudentId = studentWithGrades.Student.StudentId
                          Email = studentWithGrades.Student.Email
                          CreatedAt = studentWithGrades.Student.CreatedAt }

                    let average = studentService.CalculateStudentAverage(studentId)
                    let total = studentService.CalculateStudentTotal(studentId)

                    let response: StudentWithGradesResponseDto =
                        { Student = studentDto
                          Grades = gradeDtos
                          Average = average
                          Total = total }

                    this.Ok(response) :> IActionResult
                | None -> this.NotFound() :> IActionResult
            | None -> this.NotFound("Student with username not found") :> IActionResult

