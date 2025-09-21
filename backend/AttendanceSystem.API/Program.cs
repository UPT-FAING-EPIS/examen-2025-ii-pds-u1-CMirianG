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

// Add DbContext - Support multiple databases
builder.Services.AddDbContext<AttendanceContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    
    if (!string.IsNullOrEmpty(connectionString))
    {
        if (connectionString.Contains("postgresql://") || connectionString.Contains("postgres://"))
        {
            // Use PostgreSQL for production (Supabase)
            options.UseNpgsql(connectionString);
        }
        else if (connectionString.Contains("tcp:") || connectionString.Contains("database.windows.net"))
        {
            // Use SQL Server for Azure SQL
            options.UseSqlServer(connectionString);
        }
        else
        {
            // Use SQLite for local development
            options.UseSqlite(connectionString);
        }
    }
    else
    {
        // Default to SQLite
        options.UseSqlite("Data Source=attendance.db");
    }
});

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

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    try
    {
        var context = scope.ServiceProvider.GetRequiredService<AttendanceContext>();
        context.Database.EnsureCreated();
    }
    catch (Exception ex)
    {
        // Log error but don't stop the app
        Console.WriteLine($"Database initialization error: {ex.Message}");
    }
}

app.Run();
