namespace F__project.Models

open System.ComponentModel.DataAnnotations

[<CLIMutable>]
type User =
    { [<Key>]
      Id: int
      Username: string
      Password: string
      Role: string
      StudentId: int option }

