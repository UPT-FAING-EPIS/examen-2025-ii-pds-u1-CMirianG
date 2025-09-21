using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Models;
using AttendanceSystem.API.DTOs;

namespace AttendanceSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AttendanceController : ControllerBase
    {
        private readonly AttendanceContext _context;

        public AttendanceController(AttendanceContext context)
        {
            _context = context;
        }

        // POST: api/attendance
        [HttpPost]
        public async Task<ActionResult<AttendanceDto>> RegisterAttendance(RegisterAttendanceDto dto)
        {
            // Find session by code
            var session = await _context.Sessions
                .Include(s => s.Course)
                .FirstOrDefaultAsync(s => s.UniqueCode == dto.SessionCode && s.IsActive);

            if (session == null)
            {
                return BadRequest("Código de sesión no válido");
            }

            // Check if session is for today
            if (session.Date.Date != DateTime.Today)
            {
                return BadRequest("Esta sesión no está activa para hoy");
            }

            // Find student
            var student = await _context.Students.FindAsync(dto.StudentId);
            if (student == null)
            {
                return BadRequest("Estudiante no encontrado");
            }

            // Check if attendance already exists
            var existingAttendance = await _context.Attendances
                .FirstOrDefaultAsync(a => a.StudentId == dto.StudentId && a.SessionId == session.Id);

            if (existingAttendance != null)
            {
                return BadRequest("La asistencia ya fue registrada para esta sesión");
            }

            // Create attendance record
            var attendance = new Attendance
            {
                StudentId = dto.StudentId,
                SessionId = session.Id,
                IsPresent = true,
                Notes = dto.Notes,
                RegisteredAt = DateTime.UtcNow
            };

            _context.Attendances.Add(attendance);
            await _context.SaveChangesAsync();

            // Return DTO
            var attendanceDto = new AttendanceDto
            {
                Id = attendance.Id,
                StudentId = student.Id,
                StudentName = $"{student.FirstName} {student.LastName}",
                StudentCode = student.StudentCode,
                SessionId = session.Id,
                SessionTitle = session.Title,
                CourseCode = session.Course.Code,
                CourseName = session.Course.Name,
                RegisteredAt = attendance.RegisteredAt,
                IsPresent = attendance.IsPresent,
                Notes = attendance.Notes
            };

            return CreatedAtAction("GetAttendance", new { id = attendance.Id }, attendanceDto);
        }

        // GET: api/attendance/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<AttendanceDto>> GetAttendance(int id)
        {
            var attendance = await _context.Attendances
                .Include(a => a.Student)
                .Include(a => a.Session)
                    .ThenInclude(s => s.Course)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (attendance == null)
            {
                return NotFound();
            }

            var dto = new AttendanceDto
            {
                Id = attendance.Id,
                StudentId = attendance.Student.Id,
                StudentName = $"{attendance.Student.FirstName} {attendance.Student.LastName}",
                StudentCode = attendance.Student.StudentCode,
                SessionId = attendance.Session.Id,
                SessionTitle = attendance.Session.Title,
                CourseCode = attendance.Session.Course.Code,
                CourseName = attendance.Session.Course.Name,
                RegisteredAt = attendance.RegisteredAt,
                IsPresent = attendance.IsPresent,
                Notes = attendance.Notes
            };

            return dto;
        }

        // GET: api/attendance
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AttendanceDto>>> GetAttendances(
            [FromQuery] int? courseId, 
            [FromQuery] int? studentId,
            [FromQuery] int? sessionId)
        {
            var query = _context.Attendances
                .Include(a => a.Student)
                .Include(a => a.Session)
                    .ThenInclude(s => s.Course)
                .AsQueryable();

            if (courseId.HasValue)
            {
                query = query.Where(a => a.Session.CourseId == courseId.Value);
            }

            if (studentId.HasValue)
            {
                query = query.Where(a => a.StudentId == studentId.Value);
            }

            if (sessionId.HasValue)
            {
                query = query.Where(a => a.SessionId == sessionId.Value);
            }

            var attendances = await query.ToListAsync();

            var dtos = attendances.Select(a => new AttendanceDto
            {
                Id = a.Id,
                StudentId = a.Student.Id,
                StudentName = $"{a.Student.FirstName} {a.Student.LastName}",
                StudentCode = a.Student.StudentCode,
                SessionId = a.Session.Id,
                SessionTitle = a.Session.Title,
                CourseCode = a.Session.Course.Code,
                CourseName = a.Session.Course.Name,
                RegisteredAt = a.RegisteredAt,
                IsPresent = a.IsPresent,
                Notes = a.Notes
            }).ToList();

            return dtos;
        }

        // GET: api/attendance/students
        [HttpGet("students")]
        public async Task<ActionResult<IEnumerable<Student>>> GetStudents()
        {
            return await _context.Students.ToListAsync();
        }
    }
}
