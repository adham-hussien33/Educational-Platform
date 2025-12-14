namespace F__project.Data

open System
open System.Linq.Expressions
open Microsoft.EntityFrameworkCore
open Microsoft.EntityFrameworkCore.Storage.ValueConversion
open F__project.Models

type StudentDbContext(options: DbContextOptions<StudentDbContext>) =
    inherit DbContext(options)

    member this.Students = this.Set<Student>()

    member this.Grades = this.Set<Grade>()

    member this.Users = this.Set<User>()

    override this.OnModelCreating(modelBuilder: ModelBuilder) =
        base.OnModelCreating(modelBuilder)

        modelBuilder.Entity<Student>()
            .HasKey("Id")
            |> ignore

        modelBuilder.Entity<Student>()
            .Property("Id")
            .ValueGeneratedOnAdd()
            |> ignore

        // Make StudentId unique
        modelBuilder.Entity<Student>()
            .HasIndex("StudentId")
            .IsUnique()
            |> ignore

        modelBuilder.Entity<Grade>()
            .HasKey("Id")
            |> ignore

        modelBuilder.Entity<Grade>()
            .Property("Id")
            .ValueGeneratedOnAdd()
            |> ignore

        modelBuilder.Entity<Grade>()
            .HasOne<Student>()
            .WithMany()
            .HasForeignKey("StudentId")
            |> ignore

        // Configure decimal precision for Score and MaxScore
        modelBuilder.Entity<Grade>()
            .Property("Score")
            .HasPrecision(18, 2)
            |> ignore

        modelBuilder.Entity<Grade>()
            .Property("MaxScore")
            .HasPrecision(18, 2)
            |> ignore

        modelBuilder.Entity<User>()
            .HasKey("Id")
            |> ignore

        modelBuilder.Entity<User>()
            .Property("Id")
            .ValueGeneratedOnAdd()
            |> ignore

        // Configure StudentId (int option) as nullable int using value converter
        let studentIdConverter = 
            ValueConverter<int option, Nullable<int>>(
                (fun opt -> match opt with Some v -> Nullable v | None -> Nullable()),
                (fun nullable -> if nullable.HasValue then Some nullable.Value else None)
            )
        
        modelBuilder.Entity<User>()
            .Property("StudentId")
            .HasConversion(studentIdConverter)
            .IsRequired(false)
            |> ignore

