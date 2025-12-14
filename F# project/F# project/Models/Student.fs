namespace F__project.Models

open System
open System.ComponentModel.DataAnnotations

type Role =
    | Admin
    | Student

[<CLIMutable>]
type Student =
    { [<Key>]
      Id: int
      Name: string
      StudentId: string
      Email: string
      CreatedAt: DateTime }

[<CLIMutable>]
type Grade =
    { [<Key>]
      Id: int
      StudentId: int
      Subject: string
      Score: decimal
      MaxScore: decimal
      DateRecorded: DateTime }

type StudentWithGrades =
    { Student: Student
      Grades: Grade list }

