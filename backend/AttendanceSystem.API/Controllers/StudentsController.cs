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
