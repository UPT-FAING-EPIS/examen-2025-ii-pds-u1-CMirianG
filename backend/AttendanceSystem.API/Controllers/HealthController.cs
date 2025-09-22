using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;

namespace AttendanceSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthController : ControllerBase
    {
        private readonly AttendanceContext _context;

        public HealthController(AttendanceContext context)
        {
            _context = context;
        }

        // GET: api/health
        [HttpGet]
        public async Task<ActionResult<object>> GetHealth()
        {
            try
            {
                // Check database connection
                await _context.Database.CanConnectAsync();
                
                // Get basic statistics
                var studentCount = await _context.Students.CountAsync();
                var courseCount = await _context.Courses.CountAsync(c => c.IsActive);
                var sessionCount = await _context.Sessions.CountAsync(s => s.IsActive);
                var attendanceCount = await _context.Attendances.CountAsync();

                return Ok(new
                {
                    Status = "Healthy",
                    Timestamp = DateTime.UtcNow,
                    Database = "Connected",
                    Statistics = new
                    {
                        Students = studentCount,
                        Courses = courseCount,
                        Sessions = sessionCount,
                        Attendances = attendanceCount
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Status = "Unhealthy",
                    Timestamp = DateTime.UtcNow,
                    Error = ex.Message
                });
            }
        }

        // GET: api/health/detailed
        [HttpGet("detailed")]
        public async Task<ActionResult<object>> GetDetailedHealth()
        {
            try
            {
                var healthInfo = new
                {
                    Status = "Healthy",
                    Timestamp = DateTime.UtcNow,
                    Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development",
                    Version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version?.ToString() ?? "Unknown",
                    Database = await GetDatabaseHealthAsync(),
                    System = new
                    {
                        MachineName = Environment.MachineName,
                        ProcessorCount = Environment.ProcessorCount,
                        WorkingSet = Environment.WorkingSet,
                        OSVersion = Environment.OSVersion.ToString()
                    }
                };

                return Ok(healthInfo);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Status = "Unhealthy",
                    Timestamp = DateTime.UtcNow,
                    Error = ex.Message
                });
            }
        }

        private async Task<object> GetDatabaseHealthAsync()
        {
            try
            {
                await _context.Database.CanConnectAsync();
                
                var connectionString = _context.Database.GetConnectionString();
                var provider = _context.Database.ProviderName;
                
                return new
                {
                    Status = "Connected",
                    Provider = provider,
                    HasConnectionString = !string.IsNullOrEmpty(connectionString)
                };
            }
            catch (Exception ex)
            {
                return new
                {
                    Status = "Disconnected",
                    Error = ex.Message
                };
            }
        }
    }
}
