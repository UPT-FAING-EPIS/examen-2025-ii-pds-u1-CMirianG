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

// Add DbContext - Use SQL Server for production, In-Memory for development
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

if (builder.Environment.IsDevelopment())
{
    // Use In-Memory Database for local development
    builder.Services.AddDbContext<AttendanceContext>(options =>
        options.UseInMemoryDatabase("AttendanceSystemDb"));
}
else
{
    // Use SQL Server for production
    builder.Services.AddDbContext<AttendanceContext>(options =>
        options.UseSqlServer(connectionString));
}

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
            if (builder.Environment.IsDevelopment())
            {
                // Local development origins
                policy.WithOrigins("http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:3004", "http://localhost:5173", "http://localhost:4000")
                      .AllowAnyHeader()
                      .AllowAnyMethod();
            }
            else
            {
                // Production origins
                policy.WithOrigins("https://attendance-system-frontend.azurestaticapps.net", "https://assistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net")
                      .AllowAnyHeader()
                      .AllowAnyMethod();
            }
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
        // Add real students from cycle 10
        var students = new[]
        {
            new Student { FirstName = "JESUS EDUARDO", LastName = "AGREDA RAMIREZ", Email = "jesus.agreda@email.com", StudentCode = "SI001", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "MAYNER GONZALO", LastName = "ANAHUA COAQUIRA", Email = "mayner.anahua@email.com", StudentCode = "SI002", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "ALBERT KENYI", LastName = "APAZA CCALLE", Email = "albert.apaza@email.com", StudentCode = "SI003", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "EDWARD HERNAN", LastName = "APAZA MAMANI", Email = "edward.apaza@email.com", StudentCode = "SI004", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JORGE LUIS", LastName = "BRICEÑO DIAZ", Email = "jorge.briceño@email.com", StudentCode = "SI005", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "CAMILA FERNANDA", LastName = "CABRERA CATARI", Email = "camila.cabrera@email.com", StudentCode = "SI006", CreatedAt = DateTime.UtcNow },
            new Student { FirstName = "JORGE ENRIQUE", LastName = "CASTANEDA CENTURION", Email = "jorge.castaneda@email.com", StudentCode = "SI007", CreatedAt = DateTime.UtcNow },
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
        // Add courses from real curriculum
        var courses = new[]
        {
            new Course { 
                Name = "SEGURIDAD DE TECNOLOGÍA DE INFORMACIÓN", 
                Code = "SI-082", 
                Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: SI-985", 
                InstructorName = "Dr. Carlos Mendoza", 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Course { 
                Name = "CONSTRUCCIÓN DE SOFTWARE II", 
                Code = "SI-083", 
                Description = "HT: 2, HP: 4, TH: 6, CRÉDITOS: 4, PRERREQUISITO: SI-983", 
                InstructorName = "Ing. María González", 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Course { 
                Name = "AUDITORÍA DE SISTEMAS", 
                Code = "SI-084", 
                Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: SI-985", 
                InstructorName = "Dra. Ana López", 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Course { 
                Name = "TALLER DE EMPRENDIMIENTO Y LIDERAZGO", 
                Code = "SI-085", 
                Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: Ninguno", 
                InstructorName = "Lic. Roberto Silva", 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Course { 
                Name = "GERENCIA DE TECNOLOGÍAS DE INFORMACIÓN", 
                Code = "SI-086", 
                Description = "HT: 2, HP: 2, TH: 4, CRÉDITOS: 3, PRERREQUISITO: SI-983", 
                InstructorName = "Mg. Pedro Ramírez", 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Course { 
                Name = "TALLER DE TESIS II / TRABAJO DE INVESTIGACIÓN", 
                Code = "SI-080", 
                Description = "HT: 3, HP: 0, TH: 3, CRÉDITOS: 3, PRERREQUISITO: SI-981", 
                InstructorName = "Dr. Carmen Vega", 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            }
        };
        context.Courses.AddRange(courses);
        context.SaveChanges();
    }
    
    if (!context.Sessions.Any())
    {
        // Add sample sessions for today and previous days
        var today = DateTime.Today;
        var yesterday = today.AddDays(-1);
        var twoDaysAgo = today.AddDays(-2);
        
        var sessions = new[]
        {
            // Today's sessions
            new Session
            {
                CourseId = 1,
                Title = "Introducción a Criptografía y Seguridad",
                Date = today,
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(10),
                UniqueCode = "123456",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 2,
                Title = "Patrones de Diseño en Software",
                Date = today,
                StartTime = TimeSpan.FromHours(10),
                EndTime = TimeSpan.FromHours(12),
                UniqueCode = "789012",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 3,
                Title = "Metodologías de Auditoría de Sistemas",
                Date = today,
                StartTime = TimeSpan.FromHours(14),
                EndTime = TimeSpan.FromHours(16),
                UniqueCode = "456789",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 5,
                Title = "Gestión de Proyectos TI",
                Date = today,
                StartTime = TimeSpan.FromHours(16),
                EndTime = TimeSpan.FromHours(18),
                UniqueCode = "555555",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            
            // Yesterday's sessions
            new Session
            {
                CourseId = 1,
                Title = "Vulnerabilidades y Amenazas Informáticas",
                Date = yesterday,
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(10),
                UniqueCode = "111111",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 2,
                Title = "Arquitectura de Software",
                Date = yesterday,
                StartTime = TimeSpan.FromHours(10),
                EndTime = TimeSpan.FromHours(12),
                UniqueCode = "222222",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 4,
                Title = "Liderazgo en Equipos de Trabajo",
                Date = yesterday,
                StartTime = TimeSpan.FromHours(14),
                EndTime = TimeSpan.FromHours(16),
                UniqueCode = "444444",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            
            // Two days ago sessions
            new Session
            {
                CourseId = 3,
                Title = "Control Interno en Sistemas",
                Date = twoDaysAgo,
                StartTime = TimeSpan.FromHours(8),
                EndTime = TimeSpan.FromHours(10),
                UniqueCode = "333333",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 5,
                Title = "Estrategias de TI en la Organización",
                Date = twoDaysAgo,
                StartTime = TimeSpan.FromHours(10),
                EndTime = TimeSpan.FromHours(12),
                UniqueCode = "666666",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Session
            {
                CourseId = 6,
                Title = "Metodología de Investigación",
                Date = twoDaysAgo,
                StartTime = TimeSpan.FromHours(14),
                EndTime = TimeSpan.FromHours(17),
                UniqueCode = "777777",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            }
        };
        context.Sessions.AddRange(sessions);
        context.SaveChanges();
    }
    
    // Add some sample attendance records
    if (!context.Attendances.Any())
    {
        var attendances = new[]
        {
            // Today's attendances - Seguridad TI (Session 1)
            new Attendance
            {
                StudentId = 1, // JESUS EDUARDO AGREDA RAMIREZ
                SessionId = 1,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-3),
                Notes = "Presente en clase de Seguridad TI"
            },
            new Attendance
            {
                StudentId = 2, // MAYNER GONZALO ANAHUA COAQUIRA
                SessionId = 1,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-3),
                Notes = "Asistió puntual a Criptografía"
            },
            new Attendance
            {
                StudentId = 3, // ALBERT KENYI APAZA CCALLE
                SessionId = 1,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-3),
                Notes = "Participó activamente en clase"
            },
            
            // Today's attendances - Construcción de Software II (Session 2)
            new Attendance
            {
                StudentId = 4, // EDWARD HERNAN APAZA MAMANI
                SessionId = 2,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-2),
                Notes = "Excelente participación en Patrones de Diseño"
            },
            new Attendance
            {
                StudentId = 5, // JORGE LUIS BRICEÑO DIAZ
                SessionId = 2,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-2),
                Notes = "Presente en Arquitectura de Software"
            },
            new Attendance
            {
                StudentId = 6, // CAMILA FERNANDA CABRERA CATARI
                SessionId = 2,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-2),
                Notes = "Participó en ejercicios prácticos"
            },
            
            // Today's attendances - Auditoría de Sistemas (Session 3)
            new Attendance
            {
                StudentId = 7, // JORGE ENRIQUE CASTANEDA CENTURION
                SessionId = 3,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-1),
                Notes = "Excelente participación en Auditoría"
            },
            new Attendance
            {
                StudentId = 8, // JESUS LEONEL CASTRO GUTIERREZ
                SessionId = 3,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddHours(-1),
                Notes = "Presente en Metodologías de Auditoría"
            },
            
            // Today's attendances - Gerencia de TI (Session 4)
            new Attendance
            {
                StudentId = 9, // JOEL ROBERT CCALLI CHATA
                SessionId = 4,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddMinutes(-30),
                Notes = "Presente en Gestión de Proyectos TI"
            },
            new Attendance
            {
                StudentId = 10, // CHRISTIAN ALEXANDER CESPEDES MEDINA
                SessionId = 4,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddMinutes(-30),
                Notes = "Participó en discusión de casos"
            },
            
            // Yesterday's attendances - Seguridad TI (Session 5)
            new Attendance
            {
                StudentId = 11, // EDGARD REYNALDO CHAMBE TORRES
                SessionId = 5,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-1).AddHours(-3),
                Notes = "Clase de Vulnerabilidades Informáticas"
            },
            new Attendance
            {
                StudentId = 12, // JOSUE ABRAHAM EMANUEL CHAMBILLA ZUÑIGA
                SessionId = 5,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-1).AddHours(-3),
                Notes = "Presente en Seguridad TI"
            },
            
            // Yesterday's attendances - Construcción de Software II (Session 6)
            new Attendance
            {
                StudentId = 13, // ERICK SCOTT CHURACUTIPA BLAS
                SessionId = 6,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-1).AddHours(-2),
                Notes = "Arquitectura de Software"
            },
            new Attendance
            {
                StudentId = 14, // TOMAS YOEL CONDORI VARGAS
                SessionId = 6,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-1).AddHours(-2),
                Notes = "Participó en ejercicios de diseño"
            },
            
            // Yesterday's attendances - Emprendimiento y Liderazgo (Session 7)
            new Attendance
            {
                StudentId = 15, // MIRIAN CUADROS GARCIA
                SessionId = 7,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-1).AddHours(-1),
                Notes = "Taller de Liderazgo"
            },
            new Attendance
            {
                StudentId = 16, // RAUL MARCELO CUADROS NAPA
                SessionId = 7,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-1).AddHours(-1),
                Notes = "Participó en dinámicas grupales"
            },
            
            // Two days ago attendances - Auditoría (Session 8)
            new Attendance
            {
                StudentId = 17, // RICARDO DANIEL CUTIPA GUTIERREZ
                SessionId = 8,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-2).AddHours(-3),
                Notes = "Control Interno en Sistemas"
            },
            new Attendance
            {
                StudentId = 18, // RICARDO MIGUEL DE LA CRUZ CHOQUE
                SessionId = 8,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-2).AddHours(-3),
                Notes = "Presente en Auditoría"
            },
            
            // Two days ago attendances - Gerencia de TI (Session 9)
            new Attendance
            {
                StudentId = 19, // RODRIGO MARTIN DE LA CRUZ CHOQUE
                SessionId = 9,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-2).AddHours(-2),
                Notes = "Estrategias de TI"
            },
            new Attendance
            {
                StudentId = 20, // CARLOS ANDRES ESCOBAR REJAS
                SessionId = 9,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-2).AddHours(-2),
                Notes = "Participó en análisis de casos"
            },
            
            // Two days ago attendances - Tesis (Session 10)
            new Attendance
            {
                StudentId = 21, // JESUS ANTONIO HUALLPA MARON
                SessionId = 10,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-2).AddHours(-1),
                Notes = "Metodología de Investigación"
            },
            new Attendance
            {
                StudentId = 22, // JOSE ANDRE LA TORRE ESQUIVEL
                SessionId = 10,
                IsPresent = true,
                RegisteredAt = DateTime.UtcNow.AddDays(-2).AddHours(-1),
                Notes = "Presente en Taller de Tesis"
            }
        };
        context.Attendances.AddRange(attendances);
        context.SaveChanges();
    }
}

app.Run();
