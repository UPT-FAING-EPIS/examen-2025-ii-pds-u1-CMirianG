using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Models;

namespace AttendanceSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StudentsController : ControllerBase
    {
        private readonly AttendanceContext _context;

        public StudentsController(AttendanceContext context)
        {
            _context = context;
        }

        // GET: api/students
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Student>>> GetStudents()
        {
            return await _context.Students.ToListAsync();
        }

        // GET: api/students/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Student>> GetStudent(int id)
        {
            var student = await _context.Students.FindAsync(id);

            if (student == null)
            {
                return NotFound();
            }

            return student;
        }

        // GET: api/students/{id}/courses-with-sessions
        [HttpGet("{id}/courses-with-sessions")]
        public async Task<ActionResult<object>> GetStudentCoursesWithSessions(int id)
        {
            var student = await _context.Students.FindAsync(id);
            if (student == null)
            {
                return NotFound(new { message = "Estudiante no encontrado" });
            }

            var today = DateTime.Today;
            var coursesWithSessions = await _context.Courses
                .Where(c => c.IsActive)
                .Select(c => new
                {
                    c.Id,
                    c.Name,
                    c.Code,
                    c.Description,
                    c.InstructorName,
                    Sessions = _context.Sessions
                        .Where(s => s.CourseId == c.Id && s.IsActive && s.Date >= today)
                        .OrderBy(s => s.Date)
                        .ThenBy(s => s.StartTime)
                        .Select(s => new
                        {
                            s.Id,
                            s.Title,
                            s.UniqueCode,
                            s.Date,
                            s.StartTime,
                            s.EndTime,
                            IsToday = s.Date.Date == today,
                            IsActive = s.IsActive,
                            AttendanceStatus = _context.Attendances
                                .Where(a => a.StudentId == id && a.SessionId == s.Id)
                                .Select(a => new
                                {
                                    a.IsPresent,
                                    a.RegisteredAt,
                                    a.Notes
                                })
                                .FirstOrDefault()
                        })
                        .ToList()
                })
                .Where(c => c.Sessions.Any())
                .ToListAsync();

            return Ok(new
            {
                student = new
                {
                    student.Id,
                    student.FirstName,
                    student.LastName,
                    student.StudentCode,
                    student.Email
                },
                courses = coursesWithSessions
            });
        }

        // GET: api/students/by-code/{code}
        [HttpGet("by-code/{code}")]
        public async Task<ActionResult<Student>> GetStudentByCode(string code)
        {
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.StudentCode == code);
            
            if (student == null)
            {
                return NotFound(new { message = $"Estudiante con código {code} no encontrado" });
            }

            return Ok(student);
        }

        // POST: api/students
        [HttpPost]
        public async Task<ActionResult<Student>> PostStudent(Student student)
        {
            try
            {
                // Set default values
                student.CreatedAt = DateTime.UtcNow;
                
                _context.Students.Add(student);
                await _context.SaveChangesAsync();

                return CreatedAtAction("GetStudent", new { id = student.Id }, student);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error creating student: {ex.Message}");
            }
        }

        // PUT: api/students/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> PutStudent(int id, Student student)
        {
            if (id != student.Id)
            {
                return BadRequest("ID mismatch");
            }

            try
            {
                var existingStudent = await _context.Students.FindAsync(id);
                if (existingStudent == null)
                {
                    return NotFound();
                }

                // Update properties
                existingStudent.FirstName = student.FirstName;
                existingStudent.LastName = student.LastName;
                existingStudent.Email = student.Email;
                existingStudent.StudentCode = student.StudentCode;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest($"Error updating student: {ex.Message}");
            }
        }

        // DELETE: api/students/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteStudent(int id)
        {
            try
            {
                var student = await _context.Students.FindAsync(id);
                if (student == null)
                {
                    return NotFound();
                }

                _context.Students.Remove(student);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest($"Error deleting student: {ex.Message}");
            }
        }

        // GET: api/students/{id}/attendance
        [HttpGet("{id}/attendance")]
        public async Task<ActionResult<IEnumerable<object>>> GetStudentAttendance(int id)
        {
            var attendances = await _context.Attendances
                .Include(a => a.Session)
                    .ThenInclude(s => s.Course)
                .Where(a => a.StudentId == id)
                .Select(a => new
                {
                    a.Id,
                    SessionTitle = a.Session.Title,
                    CourseName = a.Session.Course.Name,
                    CourseCode = a.Session.Course.Code,
                    Date = a.Session.Date,
                    a.IsPresent,
                    a.RegisteredAt,
                    a.Notes
                })
                .OrderByDescending(a => a.Date)
                .ToListAsync();

            return Ok(attendances);
        }

        private bool StudentExists(int id)
        {
            return _context.Students.Any(e => e.Id == id);
        }
    }
}
