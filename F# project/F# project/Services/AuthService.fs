namespace F__project.Services

open System.Linq
open Microsoft.EntityFrameworkCore
open F__project.Data
open F__project.Models

type AuthService(dbContext: StudentDbContext) =

    // Helper functions to convert between Role and string
    let roleToString (role: Role) =
        match role with
        | Admin -> "Admin"
        | Student -> "Student"

    let stringToRole (roleStr: string) =
        match roleStr with
        | "Admin" -> Some Admin
        | "Student" -> Some Student
        | _ -> None

    member this.Authenticate(username: string, password: string) =
        let usernameLower = username.ToLower()
        query {
            for user in dbContext.Users do
                where (user.Username.ToLower() = usernameLower && user.Password = password)
                select user
                take 1
        }
        |> Seq.tryHead

    member this.GetUserRole(username: string) =
        let usernameLower = username.ToLower()
        query {
            for user in dbContext.Users do
                where (user.Username.ToLower() = usernameLower)
                select user.Role
                take 1
        }
        |> Seq.tryHead
        |> Option.bind stringToRole

    member this.CreateUser(username: string, password: string, role: Role, studentId: int option) =
        let user =
            { Id = 0
              Username = username
              Password = password
              Role = roleToString role
              StudentId = studentId }

        dbContext.Users.Add(user) |> ignore
        dbContext.SaveChanges() |> ignore
        user
    
    member this.GetUserByUsername(username: string) =
        let usernameLower = username.ToLower()
        query {
            for user in dbContext.Users do
                where (user.Username.ToLower() = usernameLower)
                select user
                take 1
        }
        |> Seq.tryHead
    
    member this.GetStudentIdByUsername(username: string) =
        match this.GetUserByUsername(username) with
        | Some user -> user.StudentId
        | None -> None

    member this.IsAdmin(role: Role option) =
        match role with
        | Some Admin -> true
        | _ -> false

    member this.CanEdit(role: Role option) =
        match role with
        | Some Admin -> true
        | _ -> false
    
    member this.UpdateUserPassword(username: string, newPassword: string) =
        match this.GetUserByUsername(username) with
        | Some user ->
            let updatedUser = { user with Password = newPassword }
            dbContext.Users.Update(updatedUser) |> ignore
            dbContext.SaveChanges() |> ignore
            Some updatedUser
        | None -> None
    
    member this.UpdateUserByStudentId(studentId: int, newUsername: string, newPassword: string) =
        // Use AsNoTracking to avoid tracking conflicts when updating
        let userOpt =
            query {
                for user in dbContext.Users.AsNoTracking() do
                    where (user.StudentId = Some studentId)
                    select user
                    take 1
            }
            |> Seq.tryHead

        match userOpt with
        | Some user ->
            let updatedUser = { user with Username = newUsername; Password = newPassword }
            dbContext.Users.Update(updatedUser) |> ignore
            dbContext.SaveChanges() |> ignore
            Some updatedUser
        | None -> None

