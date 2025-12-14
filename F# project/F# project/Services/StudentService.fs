namespace F__project.Services

open System
open System.Linq
open Microsoft.EntityFrameworkCore
open F__project.Data
open F__project.Models

type StudentService(dbContext: StudentDbContext) =

    // CRUD Operations - Requirement 2
    member this.AddStudent(name: string, studentId: string, email: string) =
        // Check if StudentId already exists
        let existingStudent = 
            query {
                for student in dbContext.Students do
                    where (student.StudentId = studentId)
                    select student
                    take 1
            }
            |> Seq.tryHead
        
        match existingStudent with
        | Some _ -> failwith $"Student ID '{studentId}' already exists"
        | None ->
            let student =
                { Id = 0
                  Name = name
                  StudentId = studentId
                  Email = email
                  CreatedAt = DateTime.Now }

            dbContext.Students.Add(student) |> ignore
            dbContext.SaveChanges() |> ignore
            student
    
    member this.GetStudentByStudentId(studentId: string) =
        query {
            for student in dbContext.Students do
                where (student.StudentId = studentId)
                select student
                take 1
        }
        |> Seq.tryHead

    member this.GetStudentById(id: int) =
        query {
            for student in dbContext.Students do
                where (student.Id = id)
                select student
                take 1
        }
        |> Seq.tryHead

    member this.GetAllStudents() =
        query {
            for student in dbContext.Students do
                select student
        }
        |> Seq.toList

    member this.UpdateStudent(id: int, name: string, studentId: string, email: string) =
        // Use AsNoTracking to avoid tracking conflicts
        let studentOpt = 
            query {
                for student in dbContext.Students.AsNoTracking() do
                    where (student.Id = id)
                    select student
                    take 1
            }
            |> Seq.tryHead
        
        match studentOpt with
        | Some student ->
            // Check if StudentId is being changed and if new StudentId already exists
            if student.StudentId <> studentId then
                let existingStudent = 
                    query {
                        for s in dbContext.Students do
                            where (s.StudentId = studentId && s.Id <> id)
                            select s
                            take 1
                    }
                    |> Seq.tryHead
                match existingStudent with
                | Some _ -> failwith $"Student ID '{studentId}' already exists"
                | None -> ()
            
            let updatedStudent =
                { student with
                    Name = name
                    StudentId = studentId
                    Email = email }

            dbContext.Students.Update(updatedStudent) |> ignore
            dbContext.SaveChanges() |> ignore
            Some updatedStudent
        | None -> None

    member this.DeleteStudent(id: int) =
        let studentOpt = this.GetStudentById(id)
        match studentOpt with
        | Some student ->
            // Delete associated grades first
            let grades =
                query {
                    for grade in dbContext.Grades do
                        where (grade.StudentId = id)
                        select grade
                }
                |> Seq.toList

            for grade in grades do
                dbContext.Grades.Remove(grade) |> ignore

            // Delete associated user account
            let userOpt =
                query {
                    for user in dbContext.Users do
                        where (user.StudentId = Some id)
                        select user
                        take 1
                }
                |> Seq.tryHead

            match userOpt with
            | Some user -> dbContext.Users.Remove(user) |> ignore
            | None -> () // User account might not exist, that's okay

            dbContext.Students.Remove(student) |> ignore
            dbContext.SaveChanges() |> ignore
            true
        | None -> false

    // Grade Operations
    member this.AddGrade(studentId: int, subject: string, score: decimal, maxScore: decimal) =
        let grade =
            { Id = 0
              StudentId = studentId
              Subject = subject
              Score = score
              MaxScore = maxScore
              DateRecorded = DateTime.Now }

        dbContext.Grades.Add(grade) |> ignore
        dbContext.SaveChanges() |> ignore
        grade

    member this.GetGradesByStudentId(studentId: int) =
        query {
            for grade in dbContext.Grades do
                where (grade.StudentId = studentId)
                select grade
        }
        |> Seq.toList

    member this.GetStudentWithGrades(studentId: int) =
        let studentOpt = this.GetStudentById(studentId)
        match studentOpt with
        | Some student ->
            let grades = this.GetGradesByStudentId(studentId)
            Some { Student = student; Grades = grades }
        | None -> None

    // Grade Calculations - Requirement 3
    member this.CalculateStudentAverage(studentId: int) =
        let grades = this.GetGradesByStudentId(studentId)
        if grades.IsEmpty then
            None
        else
            let totalScore = grades |> List.sumBy (fun g -> g.Score)
            let totalMaxScore = grades |> List.sumBy (fun g -> g.MaxScore)
            if totalMaxScore = 0m then
                None
            else
                Some(totalScore / totalMaxScore * 100m)

    member this.CalculateStudentTotal(studentId: int) =
        let grades = this.GetGradesByStudentId(studentId)
        let totalScore = grades |> List.sumBy (fun g -> g.Score)
        let totalMaxScore = grades |> List.sumBy (fun g -> g.MaxScore)
        {| TotalScore = totalScore; TotalMaxScore = totalMaxScore |}

    member this.CalculateSubjectAverage(subject: string) =
        let grades =
            query {
                for grade in dbContext.Grades do
                    where (grade.Subject = subject)
                    select grade
            }
            |> Seq.toList

        if grades.IsEmpty then
            None
        else
            let totalScore = grades |> List.sumBy (fun g -> g.Score)
            let totalMaxScore = grades |> List.sumBy (fun g -> g.MaxScore)
            if totalMaxScore = 0m then
                None
            else
                Some(totalScore / totalMaxScore * 100m)

    // Class Statistics
    member this.GetClassStatistics() =
        try
            let allStudents = 
                try
                    this.GetAllStudents()
                with
                | ex -> 
                    System.Diagnostics.Debug.WriteLine($"Error getting all students: {ex.Message}")
                    []

            let allGrades =
                try
                    query {
                        for grade in dbContext.Grades do
                            select grade
                    }
                    |> Seq.toList
                with
                | ex ->
                    System.Diagnostics.Debug.WriteLine($"Error getting all grades: {ex.Message}")
                    []

            if allGrades.IsEmpty then
                {| HighestAverage = None
                   LowestAverage = None
                   PassRate = None
                   TotalStudents = allStudents.Length
                   TotalGrades = 0 |}
            else
                let studentAverages =
                    allStudents
                    |> List.map (fun s ->
                        try
                            let avg = this.CalculateStudentAverage(s.Id)
                            (s, avg)
                        with
                        | ex ->
                            System.Diagnostics.Debug.WriteLine($"Error calculating average for student {s.Id}: {ex.Message}")
                            (s, None))

                let validAverages =
                    studentAverages
                    |> List.choose (fun (s, avg) ->
                        avg |> Option.map (fun a -> (s, a)))

                let highest =
                    if validAverages.IsEmpty then
                        None
                    else
                        try
                            let (s, avg) = validAverages |> List.maxBy (fun (_, a) -> a)
                            Some {| Student = s; Average = avg |}
                        with
                        | ex ->
                            System.Diagnostics.Debug.WriteLine($"Error finding highest average: {ex.Message}")
                            None

                let lowest =
                    if validAverages.IsEmpty then
                        None
                    else
                        try
                            let (s, avg) = validAverages |> List.minBy (fun (_, a) -> a)
                            Some {| Student = s; Average = avg |}
                        with
                        | ex ->
                            System.Diagnostics.Debug.WriteLine($"Error finding lowest average: {ex.Message}")
                            None

                let passingThreshold = 60m
                let passingCount =
                    validAverages
                    |> List.filter (fun (_, avg) -> avg >= passingThreshold)
                    |> List.length

                let passRate =
                    if validAverages.Length > 0 then
                        try
                            Some((decimal passingCount / decimal validAverages.Length) * 100m)
                        with
                        | ex ->
                            System.Diagnostics.Debug.WriteLine($"Error calculating pass rate: {ex.Message}")
                            None
                    else
                        None

                {| HighestAverage = highest
                   LowestAverage = lowest
                   PassRate = passRate
                   TotalStudents = allStudents.Length
                   TotalGrades = allGrades.Length |}
        with
        | ex ->
            System.Diagnostics.Debug.WriteLine($"Error in GetClassStatistics: {ex.Message}")
            // Return empty stats instead of re-throwing to allow graceful error handling
            {| HighestAverage = None
               LowestAverage = None
               PassRate = None
               TotalStudents = 0
               TotalGrades = 0 |}

    // Subject-specific Statistics
    member this.GetSubjectStatistics(subject: string) =
        // Handle null or empty subject
        if System.String.IsNullOrWhiteSpace(subject) then
            {| HighestAverage = None
               LowestAverage = None
               PassRate = None
               TotalStudents = 0
               TotalGrades = 0 |}
        else
            // Get all grades for the specific subject (case-insensitive comparison)
            let subjectLower = subject.Trim().ToLower()
            let allGrades =
                query {
                    for grade in dbContext.Grades do
                        select grade
                }
                |> Seq.toList
            
            let subjectGrades =
                allGrades
                |> List.filter (fun g -> 
                    not (System.String.IsNullOrWhiteSpace(g.Subject)) && 
                    g.Subject.Trim().ToLower() = subjectLower)

            if subjectGrades.IsEmpty then
                {| HighestAverage = None
                   LowestAverage = None
                   PassRate = None
                   TotalStudents = 0
                   TotalGrades = 0 |}
            else
                // Calculate percentage for each individual grade and find highest/lowest
                let gradesWithPercentage =
                    subjectGrades
                    |> List.choose (fun grade ->
                        if grade.MaxScore = 0m then
                            None
                        else
                            let percentage = (grade.Score / grade.MaxScore) * 100m
                            let studentOpt = this.GetStudentById(grade.StudentId)
                            match studentOpt with
                            | Some student -> Some (student, grade, percentage)
                            | None -> None)

                // Find highest individual grade
                let highest =
                    if gradesWithPercentage.IsEmpty then
                        None
                    else
                        let (student, grade, percentage) = 
                            gradesWithPercentage |> List.maxBy (fun (_, _, p) -> p)
                        Some {| Student = student; Average = percentage |}

                // Find lowest individual grade
                let lowest =
                    if gradesWithPercentage.IsEmpty then
                        None
                    else
                        let (student, grade, percentage) = 
                            gradesWithPercentage |> List.minBy (fun (_, _, p) -> p)
                        Some {| Student = student; Average = percentage |}

                // Calculate pass rate based on individual grades (not averages)
                let passingThreshold = 60m
                let passingGrades =
                    gradesWithPercentage
                    |> List.filter (fun (_, _, percentage) -> percentage >= passingThreshold)
                    |> List.length

                let passRate =
                    if gradesWithPercentage.Length > 0 then
                        Some((decimal passingGrades / decimal gradesWithPercentage.Length) * 100m)
                    else
                        None

                // Get unique student count
                let uniqueStudents = 
                    gradesWithPercentage 
                    |> List.map (fun (s, _, _) -> s.Id)
                    |> List.distinct
                    |> List.length

                {| HighestAverage = highest
                   LowestAverage = lowest
                   PassRate = passRate
                   TotalStudents = uniqueStudents
                   TotalGrades = subjectGrades.Length |}

