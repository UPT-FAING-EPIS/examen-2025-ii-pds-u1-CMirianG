using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Interfaces;
using AttendanceSystem.API.Repositories;
using AttendanceSystem.API.Services;
using AttendanceSystem.API.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Attendance System API", Version = "v1" });
});

// Add DbContext - Use In-Memory Database (no external dependencies)
builder.Services.AddDbContext<AttendanceContext>(options =>
    options.UseInMemoryDatabase("AttendanceDB"));

// Add Repository Pattern
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

// Add Services
builder.Services.AddScoped<IAttendanceService, AttendanceService>();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp",
        policy =>
        {
            policy.WithOrigins("http://localhost:5173", "http://localhost:4000")
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
// Enable Swagger in all environments for demo purposes
app.UseSwagger();
app.UseSwaggerUI();

// Add basic health check endpoint
app.MapGet("/health", () => "OK");

app.UseHttpsRedirection();

app.UseCors("AllowReactApp");

app.UseAuthorization();

app.MapControllers();

// Initialize in-memory database with sample data
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AttendanceContext>();
    
    // Ensure database is created
    context.Database.EnsureCreated();
    
    // Add sample data if database is empty
    if (!context.Students.Any())
    {
        // Add students
        var students = new[]
        {
            new Student { FirstName = "Juan", LastName = "Pérez", Email = "juan.perez@email.com", StudentCode = "EST001", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "María", LastName = "González", Email = "maria.gonzalez@email.com", StudentCode = "EST002", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "Carlos", LastName = "Rodríguez", Email = "carlos.rodriguez@email.com", StudentCode = "EST003", CreatedAt = DateTime.UtcNow }
        };
        context.Students.AddRange(students);
        context.SaveChanges();
    }
    
    if (!context.Courses.Any())
    {
        // Add courses
        var courses = new[]
        {
            new Course { Name = "Programación Web", Code = "PW001", Description = "Curso de desarrollo web con tecnologías modernas", InstructorName = "Dr. Ana López", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Course { Name = "Base de Datos", Code = "BD001", Description = "Fundamentos de bases de datos relacionales", InstructorName = "Ing. Roberto Silva", IsActive = true, CreatedAt = DateTime.UtcNow }
        };
        context.Courses.AddRange(courses);
        context.SaveChanges();
    }
    
    if (!context.Sessions.Any())
    {
        // Add sample sessions for today
        var today = DateTime.Today;
        var sessions = new[]
        {
            new Session
            {
                CourseId = 1,
                Title = "Introducción a la Programación Web",
                Date = today,
                StartTime = TimeSpan.FromHours(10),
                EndTime = TimeSpan.FromHours(12),
                UniqueCode = "123456",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 2,
                Title = "Fundamentos de Base de Datos",
                Date = today,
                StartTime = TimeSpan.FromHours(14),
                EndTime = TimeSpan.FromHours(16),
                UniqueCode = "789012",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            }
        };
        context.Sessions.AddRange(sessions);
        context.SaveChanges();
    }
}

app.Run();
