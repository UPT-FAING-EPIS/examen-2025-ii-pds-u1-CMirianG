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
            new Student { FirstName = "MAYNER GONZALO", LastName = "ANAHUA COAQUIRA", Email = "mayner.anahua@email.com", StudentCode = "SI002", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "ALBERT KENYI", LastName = "APAZA CCALLE", Email = "albert.apaza@email.com", StudentCode = "SI003", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "EDWARD HERNAN", LastName = "APAZA MAMANI", Email = "edward.apaza@email.com", StudentCode = "SI004", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JORGE LUIS", LastName = "BRICEÑO DIAZ", Email = "jorge.briceño@email.com", StudentCode = "SI005", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "CAMILA FERNANDA", LastName = "CABRERA CATARI", Email = "camila.cabrera@email.com", StudentCode = "SI006", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JORGE ENRIQUE", LastName = "CASTAÑEDA CENTURION", Email = "jorge.castañeda@email.com", StudentCode = "SI007", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JESUS LEONEL", LastName = "CASTRO GUTIERREZ", Email = "jesus.castro@email.com", StudentCode = "SI008", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JOEL ROBERT", LastName = "CCALLI CHATA", Email = "joel.ccalli@email.com", StudentCode = "SI009", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "CHRISTIAN ALEXANDER", LastName = "CESPEDES MEDINA", Email = "christian.cespedes@email.com", StudentCode = "SI010", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "EDGARD REYNALDO", LastName = "CHAMBE TORRES", Email = "edgard.chambe@email.com", StudentCode = "SI011", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JOSUE ABRAHAM EMANUEL", LastName = "CHAMBILLA ZUÑIGA", Email = "josue.chambilla@email.com", StudentCode = "SI012", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "ERICK SCOTT", LastName = "CHURACUTIPA BLAS", Email = "erick.churacutipa@email.com", StudentCode = "SI013", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "TOMAS YOEL", LastName = "CONDORI VARGAS", Email = "tomas.condori@email.com", StudentCode = "SI014", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "MIRIAN", LastName = "CUADROS GARCIA", Email = "mirian.cuadros@email.com", StudentCode = "SI015", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "RAUL MARCELO", LastName = "CUADROS NAPA", Email = "raul.cuadros@email.com", StudentCode = "SI016", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "RICARDO DANIEL", LastName = "CUTIPA GUTIERREZ", Email = "ricardo.cutipa@email.com", StudentCode = "SI017", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "RICARDO MIGUEL", LastName = "DE LA CRUZ CHOQUE", Email = "ricardo.delacruz@email.com", StudentCode = "SI018", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "RODRIGO MARTIN", LastName = "DE LA CRUZ CHOQUE", Email = "rodrigo.delacruz@email.com", StudentCode = "SI019", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "CARLOS ANDRES", LastName = "ESCOBAR REJAS", Email = "carlos.escobar@email.com", StudentCode = "SI020", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JESUS ANTONIO", LastName = "HUALLPA MARON", Email = "jesus.huallpa@email.com", StudentCode = "SI021", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JOSE ANDRE", LastName = "LA TORRE ESQUIVEL", Email = "jose.latorre@email.com", StudentCode = "SI022", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "RODRIGO SAMAEL ADONAI", LastName = "LIRA ALVAREZ", Email = "rodrigo.lira@email.com", StudentCode = "SI023", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "MARJIORY GRACE", LastName = "LLANTAY MACHACA", Email = "marjiory.llantay@email.com", StudentCode = "SI024", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "BRAYAR CHRISTIAN", LastName = "LOPEZ CATUNTA", Email = "brayar.lopez@email.com", StudentCode = "SI025", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JUAN BRENDON", LastName = "LUNA JUAREZ", Email = "juan.luna@email.com", StudentCode = "SI026", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "GILMER DONALDO", LastName = "MAMANI CONDORI", Email = "gilmer.mamani@email.com", StudentCode = "SI027", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "ALEXIS JEANPIERRE", LastName = "MARTINEZ VARGAS", Email = "alexis.martinez@email.com", StudentCode = "SI028", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "GABRIEL FARI", LastName = "MELENDEZ HUARACHI", Email = "gabriel.melendez@email.com", StudentCode = "SI029", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JEAN MARCO", LastName = "MEZA NOALCCA", Email = "jean.meza@email.com", StudentCode = "SI030", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "LUIGUI AUGUSTO", LastName = "NINA VARGAS", Email = "luigui.nina@email.com", StudentCode = "SI031", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "XIMENA ANDREA", LastName = "ORTIZ FERNANDEZ", Email = "ximena.ortiz@email.com", StudentCode = "SI032", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "AARON PEDRO", LastName = "PACO RAMOS", Email = "aaron.paco@email.com", StudentCode = "SI033", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "RENE MANUEL", LastName = "POMA MANCHEGO", Email = "rene.poma@email.com", StudentCode = "SI034", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "ERICK JAVIER", LastName = "SALINAS CONDORI", Email = "erick.salinas@email.com", StudentCode = "SI035", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "DANIELA DUANET", LastName = "SOTO RODRIGUEZ", Email = "daniela.soto@email.com", StudentCode = "SI036", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "FIORELA MILADY", LastName = "TICAHUANCA CUTIPA", Email = "fiorela.ticahuanca@email.com", StudentCode = "SI037", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "ABRAHAM JESUS", LastName = "VELA VARGAS", Email = "abraham.vela@email.com", StudentCode = "SI038", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JUSTIN ZINEDINE", LastName = "ZEVALLOS PURCA", Email = "justin.zevallos@email.com", StudentCode = "SI039", CreatedAt = DateTime.UtcNow }
        };
        context.Students.AddRange(students);
        context.SaveChanges();
    }

    if (!context.Courses.Any())
    {
        var courses = new[]
        {
            new Course { Name = "SEGURIDAD DE TECNOLOGÍA DE INFORMACIÓN", Code = "SI-082", Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: SI-985", InstructorName = "Dr. Carlos Mendoza", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Course { Name = "CONSTRUCCIÓN DE SOFTWARE II", Code = "SI-083", Description = "HT: 2, HP: 4, TH: 6, CRÉDITOS: 4, PRERREQUISITO: SI-983", InstructorName = "Dr. María González", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Course { Name = "AUDITORÍA DE SISTEMAS", Code = "SI-084", Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: SI-985", InstructorName = "Dr. Ana Rodríguez", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Course { Name = "TALLER DE EMPRENDIMIENTO Y LIDERAZGO", Code = "SI-085", Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: Ninguno", InstructorName = "Dr. Luis Pérez", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Course { Name = "GERENCIA DE TECNOLOGÍAS DE INFORMACIÓN", Code = "SI-086", Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: SI-983", InstructorName = "Dr. Carmen Vega", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Course { Name = "TALLER DE TESIS II / TRABAJO DE INVESTIGACIÓN", Code = "SI-080", Description = "HT: 3, HP: 0, TH: 3, CRÉDITOS: 3, PRERREQUISITO: SI-981", InstructorName = "Dr. Carmen Vega", IsActive = true, CreatedAt = DateTime.UtcNow }
        };
        context.Courses.AddRange(courses);
        context.SaveChanges();
    }

    if (!context.Sessions.Any())
    {
        var today = DateTime.Today;
        var yesterday = today.AddDays(-1);
        var tomorrow = today.AddDays(1);
        
        var sessions = new[]
        {
            // Seguridad TI (SI-082) - Dr. Carlos Mendoza
            new Session { CourseId = 1, Title = "Introducción a Criptografía y Seguridad", Date = today, StartTime = TimeSpan.FromHours(8), EndTime = TimeSpan.FromHours(10), UniqueCode = "123456", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Session { CourseId = 1, Title = "Seguridad en Redes y Protocolos", Date = yesterday, StartTime = TimeSpan.FromHours(8), EndTime = TimeSpan.FromHours(10), UniqueCode = "234567", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Session { CourseId = 1, Title = "Gestión de Incidentes de Seguridad", Date = tomorrow, StartTime = TimeSpan.FromHours(8), EndTime = TimeSpan.FromHours(10), UniqueCode = "345678", IsActive = true, CreatedAt = DateTime.UtcNow },
            
            // Construcción de Software II (SI-083) - Dr. María González
            new Session { CourseId = 2, Title = "Patrones de Diseño Avanzados", Date = today, StartTime = TimeSpan.FromHours(14), EndTime = TimeSpan.FromHours(16), UniqueCode = "789012", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Session { CourseId = 2, Title = "Arquitecturas de Software", Date = yesterday, StartTime = TimeSpan.FromHours(14), EndTime = TimeSpan.FromHours(16), UniqueCode = "890123", IsActive = true, CreatedAt = DateTime.UtcNow },
            
            // Auditoría de Sistemas (SI-084) - Dr. Ana Rodríguez
            new Session { CourseId = 3, Title = "Fundamentos de Auditoría Informática", Date = today, StartTime = TimeSpan.FromHours(10), EndTime = TimeSpan.FromHours(12), UniqueCode = "456789", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Session { CourseId = 3, Title = "Metodologías de Auditoría", Date = tomorrow, StartTime = TimeSpan.FromHours(10), EndTime = TimeSpan.FromHours(12), UniqueCode = "567890", IsActive = true, CreatedAt = DateTime.UtcNow },
            
            // Emprendimiento y Liderazgo (SI-085) - Dr. Luis Pérez
            new Session { CourseId = 4, Title = "Liderazgo Empresarial", Date = today, StartTime = TimeSpan.FromHours(16), EndTime = TimeSpan.FromHours(18), UniqueCode = "111222", IsActive = true, CreatedAt = DateTime.UtcNow },
            
            // Gerencia de TI (SI-086) - Dr. Carmen Vega
            new Session { CourseId = 5, Title = "Gestión Estratégica de TI", Date = today, StartTime = TimeSpan.FromHours(18), EndTime = TimeSpan.FromHours(20), UniqueCode = "333444", IsActive = true, CreatedAt = DateTime.UtcNow },
            
            // Taller de Tesis II (SI-080) - Dr. Carmen Vega
            new Session { CourseId = 6, Title = "Metodología de Investigación", Date = tomorrow, StartTime = TimeSpan.FromHours(14), EndTime = TimeSpan.FromHours(17), UniqueCode = "555666", IsActive = true, CreatedAt = DateTime.UtcNow }
        };
        context.Sessions.AddRange(sessions);
        context.SaveChanges();
    }

    // Add sample attendance data
    if (!context.Attendances.Any())
    {
        var attendances = new[]
        {
            // Seguridad TI - Sesión de hoy (123456)
            new Attendance { StudentId = 1, SessionId = 1, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-2), Notes = "Presente en clase de Seguridad TI" },
            new Attendance { StudentId = 2, SessionId = 1, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-2), Notes = "Asistió puntual" },
            new Attendance { StudentId = 3, SessionId = 1, IsPresent = false, RegisteredAt = DateTime.UtcNow.AddHours(-1), Notes = "Ausente justificado" },
            new Attendance { StudentId = 4, SessionId = 1, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-2), Notes = "Presente" },
            new Attendance { StudentId = 5, SessionId = 1, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-2), Notes = "Llegó tarde" },
            
            // Construcción de Software II - Sesión de hoy (789012)
            new Attendance { StudentId = 6, SessionId = 4, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-1), Notes = "Presente en clase de Software II" },
            new Attendance { StudentId = 7, SessionId = 4, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-1), Notes = "Asistió" },
            new Attendance { StudentId = 8, SessionId = 4, IsPresent = false, RegisteredAt = DateTime.UtcNow.AddHours(-1), Notes = "Ausente" },
            new Attendance { StudentId = 9, SessionId = 4, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-1), Notes = "Presente" },
            new Attendance { StudentId = 10, SessionId = 4, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-1), Notes = "Llegó tarde" },
            
            // Auditoría de Sistemas - Sesión de hoy (456789)
            new Attendance { StudentId = 11, SessionId = 6, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-3), Notes = "Presente en Auditoría" },
            new Attendance { StudentId = 12, SessionId = 6, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-3), Notes = "Asistió" },
            new Attendance { StudentId = 13, SessionId = 6, IsPresent = false, RegisteredAt = DateTime.UtcNow.AddHours(-2), Notes = "Ausente justificado" },
            new Attendance { StudentId = 14, SessionId = 6, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-3), Notes = "Presente" },
            new Attendance { StudentId = 15, SessionId = 6, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-3), Notes = "Asistió" },
            
            // Emprendimiento y Liderazgo - Sesión de hoy (111222)
            new Attendance { StudentId = 16, SessionId = 8, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-30), Notes = "Presente en Liderazgo" },
            new Attendance { StudentId = 17, SessionId = 8, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-30), Notes = "Asistió" },
            new Attendance { StudentId = 18, SessionId = 8, IsPresent = false, RegisteredAt = DateTime.UtcNow.AddMinutes(-20), Notes = "Ausente" },
            new Attendance { StudentId = 19, SessionId = 8, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-30), Notes = "Presente" },
            new Attendance { StudentId = 20, SessionId = 8, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-30), Notes = "Asistió" },
            
            // Gerencia de TI - Sesión de hoy (333444)
            new Attendance { StudentId = 21, SessionId = 9, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-15), Notes = "Presente en Gerencia TI" },
            new Attendance { StudentId = 22, SessionId = 9, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-15), Notes = "Asistió" },
            new Attendance { StudentId = 23, SessionId = 9, IsPresent = false, RegisteredAt = DateTime.UtcNow.AddMinutes(-10), Notes = "Ausente" },
            new Attendance { StudentId = 24, SessionId = 9, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-15), Notes = "Presente" },
            new Attendance { StudentId = 25, SessionId = 9, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-15), Notes = "Asistió" },
            
            // Algunos estudiantes en múltiples sesiones
            new Attendance { StudentId = 1, SessionId = 4, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-1), Notes = "También asistió a Software II" },
            new Attendance { StudentId = 6, SessionId = 1, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddHours(-2), Notes = "También asistió a Seguridad TI" },
            new Attendance { StudentId = 11, SessionId = 8, IsPresent = true, RegisteredAt = DateTime.UtcNow.AddMinutes(-30), Notes = "También asistió a Liderazgo" }
        };
        context.Attendances.AddRange(attendances);
        context.SaveChanges();
    }
}

app.Run();