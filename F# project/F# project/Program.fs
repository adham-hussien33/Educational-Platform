namespace F__project
#nowarn "20"
open System
open System.Collections.Generic
open System.IO
open System.Linq
open System.Threading.Tasks
open Microsoft.AspNetCore
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.AspNetCore.HttpsPolicy
open Microsoft.Extensions.Configuration
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open Microsoft.Extensions.Logging
open Microsoft.EntityFrameworkCore
open F__project.Data
open F__project.Services
open F__project.Models

module Program =
    let exitCode = 0

    [<EntryPoint>]
    let main args =

        let builder = WebApplication.CreateBuilder(args)

        // Add SQL Server
        let connectionString =
            builder.Configuration.GetConnectionString("DefaultConnection")
            |> Option.ofObj
            |> Option.defaultValue "Server=localhost;Database=StudentGradesDB;Trusted_Connection=True;TrustServerCertificate=True;"

        builder.Services.AddDbContext<StudentDbContext>(fun options ->
            options.UseSqlServer(connectionString) |> ignore
        ) |> ignore

        // Register services
        builder.Services.AddScoped<StudentService>() |> ignore
        builder.Services.AddScoped<AuthService>() |> ignore

        // Add controllers
        builder.Services.AddControllers() |> ignore

        // Add CORS
        builder.Services.AddCors(fun options ->
            options.AddDefaultPolicy(fun policy ->
                policy.AllowAnyOrigin()
                      .AllowAnyMethod()
                      .AllowAnyHeader()
                |> ignore
            )
        ) |> ignore

        let app = builder.Build()

        // Ensure database is created
        use scope = app.Services.CreateScope()
        let dbContext = scope.ServiceProvider.GetRequiredService<StudentDbContext>()
        dbContext.Database.EnsureCreated() |> ignore

        // Seed initial admin user if no users exist
        let authService = scope.ServiceProvider.GetRequiredService<AuthService>()
        let userCount = 
            query {
                for user in dbContext.Users do
                    select user
            } |> Seq.length
        if userCount = 0 then
            authService.CreateUser("admin", "admin123", Role.Admin, None) |> ignore

        app.UseCors() |> ignore
        
        // HTTPS redirection - only in production or when HTTPS is explicitly configured
        // Commented out for development to avoid warnings
        // app.UseHttpsRedirection() |> ignore
        
        app.UseAuthorization() |> ignore
        app.MapControllers() |> ignore

        app.Run()

        exitCode
