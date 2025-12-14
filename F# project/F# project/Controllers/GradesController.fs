namespace F__project.Controllers

open Microsoft.AspNetCore.Mvc
open F__project.Services
open F__project.DTOs
open F__project.Models

[<ApiController>]
[<Route("api/[controller]")>]
type GradesController(studentService: StudentService, authService: AuthService) =
    inherit ControllerBase()

    member private this.GetCurrentRole() =
        if this.Request.Headers.ContainsKey("X-Username") then
            let username = this.Request.Headers["X-Username"].ToString()
            authService.GetUserRole(username)
        else
            None

    // POST: api/grades
    [<HttpPost>]
    member this.Create([<FromBody>] dto: CreateGradeDto) : IActionResult =
        let role = this.GetCurrentRole()
        if not (authService.CanEdit(role)) then
            this.Unauthorized("Only Admin can create grades") :> IActionResult
        else
            // Look up student by StudentId string
            match studentService.GetStudentByStudentId(dto.StudentId) with
            | Some student ->
                let grade = studentService.AddGrade(student.Id, dto.Subject, dto.Score, dto.MaxScore)
                let response =
                    { Id = grade.Id
                      StudentId = grade.StudentId
                      Subject = grade.Subject
                      Score = grade.Score
                      MaxScore = grade.MaxScore
                      Percentage = (grade.Score / grade.MaxScore) * 100m
                      DateRecorded = grade.DateRecorded }
                this.Created($"/api/students/{grade.StudentId}/grades", response) :> IActionResult
            | None -> this.BadRequest($"Student with ID '{dto.StudentId}' not found") :> IActionResult

