using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.DTOs;

namespace AttendanceSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReportsController : ControllerBase
    {
        private readonly AttendanceContext _context;

        public ReportsController(AttendanceContext context)
        {
            _context = context;
        }

        // GET: api/reports/attendance
        [HttpGet("attendance")]
        public async Task<ActionResult<IEnumerable<AttendanceReportDto>>> GetAttendanceReports([FromQuery] int? courseId)
        {
            var coursesQuery = _context.Courses.Where(c => c.IsActive);
            
            if (courseId.HasValue)
            {
                coursesQuery = coursesQuery.Where(c => c.Id == courseId.Value);
            }

            var courses = await coursesQuery.ToListAsync();
            var reports = new List<AttendanceReportDto>();

            foreach (var course in courses)
            {
                var sessions = await _context.Sessions
                    .Where(s => s.CourseId == course.Id && s.IsActive)
                    .ToListAsync();

                var students = await _context.Students.ToListAsync();

                var attendances = await _context.Attendances
                    .Include(a => a.Student)
                    .Include(a => a.Session)
                    .Where(a => a.Session.CourseId == course.Id)
                    .ToListAsync();

                var studentSummaries = students.Select(student =>
                {
                    var studentAttendances = attendances.Where(a => a.StudentId == student.Id).Count();
                    var attendanceRate = sessions.Count > 0 ? (double)studentAttendances / sessions.Count * 100 : 0;

                    return new StudentAttendanceSummary
                    {
                        StudentId = student.Id,
                        StudentName = $"{student.FirstName} {student.LastName}",
                        StudentCode = student.StudentCode,
                        AttendedSessions = studentAttendances,
                        TotalSessions = sessions.Count,
                        AttendanceRate = Math.Round(attendanceRate, 2)
                    };
                }).ToList();

                var overallAttendanceRate = studentSummaries.Count > 0 ? 
                    studentSummaries.Average(s => s.AttendanceRate) : 0;

                reports.Add(new AttendanceReportDto
                {
                    CourseId = course.Id,
                    CourseName = course.Name,
                    CourseCode = course.Code,
                    TotalSessions = sessions.Count,
                    TotalStudents = students.Count,
                    AttendanceRate = Math.Round(overallAttendanceRate, 2),
                    StudentSummaries = studentSummaries
                });
            }

            return reports;
        }

        // GET: api/reports/attendance/student/{studentId}
        [HttpGet("attendance/student/{studentId}")]
        public async Task<ActionResult<IEnumerable<AttendanceDto>>> GetStudentAttendanceHistory(int studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null)
            {
                return NotFound("Estudiante no encontrado");
            }

            var attendances = await _context.Attendances
                .Include(a => a.Session)
                    .ThenInclude(s => s.Course)
                .Where(a => a.StudentId == studentId)
                .OrderByDescending(a => a.RegisteredAt)
                .ToListAsync();

            var dtos = attendances.Select(a => new AttendanceDto
            {
                Id = a.Id,
                StudentId = studentId,
                StudentName = $"{student.FirstName} {student.LastName}",
                StudentCode = student.StudentCode,
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

        // GET: api/reports/attendance/alerts
        [HttpGet("attendance/alerts")]
        public async Task<ActionResult<object>> GetAttendanceAlerts([FromQuery] double threshold = 70.0)
        {
            var courses = await _context.Courses.Where(c => c.IsActive).ToListAsync();
            var alerts = new List<object>();

            foreach (var course in courses)
            {
                var sessions = await _context.Sessions
                    .Where(s => s.CourseId == course.Id && s.IsActive)
                    .ToListAsync();

                if (sessions.Count == 0) continue;

                var students = await _context.Students.ToListAsync();

                foreach (var student in students)
                {
                    var attendanceCount = await _context.Attendances
                        .CountAsync(a => a.StudentId == student.Id && 
                                   a.Session.CourseId == course.Id);

                    var attendanceRate = (double)attendanceCount / sessions.Count * 100;

                    if (attendanceRate < threshold)
                    {
                        alerts.Add(new
                        {
                            StudentId = student.Id,
                            StudentName = $"{student.FirstName} {student.LastName}",
                            StudentCode = student.StudentCode,
                            CourseId = course.Id,
                            CourseName = course.Name,
                            CourseCode = course.Code,
                            AttendanceRate = Math.Round(attendanceRate, 2),
                            AttendedSessions = attendanceCount,
                            TotalSessions = sessions.Count,
                            AlertLevel = attendanceRate < 50 ? "Critical" : "Warning"
                        });
                    }
                }
            }

            return alerts.OrderBy(a => ((dynamic)a).AttendanceRate).ToList();
        }
    }
}
