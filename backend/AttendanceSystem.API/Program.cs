using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Interfaces;
using AttendanceSystem.API.Repositories;
using AttendanceSystem.API.Services;
using AttendanceSystem.API.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.WriteIndented = true;
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Attendance System API", Version = "v1" });
});

// Use In-Memory Database for simplicity
builder.Services.AddDbContext<AttendanceContext>(options =>
    options.UseInMemoryDatabase("AttendanceSystemDb"));

// Add Repository Pattern
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

// Add Services
builder.Services.AddScoped<IAttendanceService, AttendanceService>();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();

// Add endpoints
app.MapGet("/", () => "🎉 Attendance System API is running! Visit /swagger for API documentation.");
app.MapGet("/health", () => "✅ OK");
app.MapGet("/api/health", () => new { 
    status = "Healthy", 
    timestamp = DateTime.UtcNow,
    message = "API is working correctly"
});

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

// Initialize database with sample data
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AttendanceContext>();
    
    // Ensure database is created
    context.Database.EnsureCreated();
    
    // Add sample data if database is empty
    if (!context.Students.Any())
    {
        var students = new[]
        {
            new Student { FirstName = "JESUS EDUARDO", LastName = "AGREDA RAMIREZ", Email = "jesus.agreda@email.com", StudentCode = "SI001", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "CAMILA FERNANDA", LastName = "CABRERA CATARI", Email = "camila.cabrera@email.com", StudentCode = "SI006", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "XIMENA ANDREA", LastName = "ORTIZ FERNANDEZ", Email = "ximena.ortiz@email.com", StudentCode = "SI032", CreatedAt = DateTime.UtcNow }
        };
        context.Students.AddRange(students);
        context.SaveChanges();
    }

    if (!context.Courses.Any())
    {
        var courses = new[]
        {
            new Course { Name = "SEGURIDAD DE TECNOLOGÍA DE INFORMACIÓN", Code = "SI-082", Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3", InstructorName = "Dr. Carlos Mendoza", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Course { Name = "CONSTRUCCIÓN DE SOFTWARE II", Code = "SI-083", Description = "HT: 2, HP: 4, TH: 6, CRÉDITOS: 4", InstructorName = "Dr. María González", IsActive = true, CreatedAt = DateTime.UtcNow }
        };
        context.Courses.AddRange(courses);
        context.SaveChanges();
    }

    if (!context.Sessions.Any())
    {
        var today = DateTime.Today;
        var sessions = new[]
        {
            new Session { CourseId = 1, Title = "Introducción a Seguridad", Date = today, StartTime = TimeSpan.FromHours(8), EndTime = TimeSpan.FromHours(10), UniqueCode = "123456", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Session { CourseId = 2, Title = "Desarrollo de Software", Date = today, StartTime = TimeSpan.FromHours(14), EndTime = TimeSpan.FromHours(16), UniqueCode = "789012", IsActive = true, CreatedAt = DateTime.UtcNow }
        };
        context.Sessions.AddRange(sessions);
        context.SaveChanges();
    }
}

app.Run();