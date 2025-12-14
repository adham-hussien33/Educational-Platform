namespace F__project.DTOs

open System

type CreateStudentDto =
    { Name: string
      StudentId: string
      Email: string
      Password: string }

type UpdateStudentDto =
    { Name: string
      StudentId: string
      Email: string
      Password: string option }

type CreateGradeDto =
    { StudentId: string  // Changed to string (Student ID like "STU001")
      Subject: string
      Score: decimal
      MaxScore: decimal }

type LoginDto =
    { Username: string
      Password: string }

type StudentResponseDto =
    { Id: int
      Name: string
      StudentId: string
      Email: string
      CreatedAt: DateTime }

type GradeResponseDto =
    { Id: int
      StudentId: int
      Subject: string
      Score: decimal
      MaxScore: decimal
      Percentage: decimal
      DateRecorded: DateTime }

type StudentWithGradesResponseDto =
    { Student: StudentResponseDto
      Grades: GradeResponseDto list
      Average: decimal option
      Total: {| TotalScore: decimal; TotalMaxScore: decimal |} }

type StatisticsResponseDto =
    { HighestAverage: {| Student: StudentResponseDto; Average: decimal |} option
      LowestAverage: {| Student: StudentResponseDto; Average: decimal |} option
      PassRate: decimal option
      TotalStudents: int
      TotalGrades: int }

