using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Interfaces;
using AttendanceSystem.API.Repositories;
using AttendanceSystem.API.Services;

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
            policy.WithOrigins("http://localhost:3000", "http://localhost:5173")
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
    
    // Ensure database is created (for in-memory, this just initializes)
    context.Database.EnsureCreated();
    
    // Add additional sample data if needed
    if (!context.Sessions.Any())
    {
        // Add sample sessions for today
        var today = DateTime.Today;
        var sessions = new[]
        {
            new Session
            {
                Id = 1,
                CourseId = 1,
                Title = "Introducción a la Programación Web",
                Date = today,
                StartTime = TimeSpan.FromHours(10),
                EndTime = TimeSpan.FromHours(12),
                UniqueCode = "123456",
                IsActive = true
            },
            new Session
            {
                Id = 2,
                CourseId = 2,
                Title = "Fundamentos de Base de Datos",
                Date = today,
                StartTime = TimeSpan.FromHours(14),
                EndTime = TimeSpan.FromHours(16),
                UniqueCode = "789012",
                IsActive = true
            }
        };
        
        context.Sessions.AddRange(sessions);
        context.SaveChanges();
    }
}

app.Run();
