using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.DTOs;
using AttendanceSystem.API.Interfaces;
using AttendanceSystem.API.Models;

namespace AttendanceSystem.API.Services
{
    public class AttendanceService : IAttendanceService
    {
        private readonly AttendanceContext _context;

        public AttendanceService(AttendanceContext context)
        {
            _context = context;
        }

        public async Task<AttendanceDto> RegisterAttendanceAsync(RegisterAttendanceDto dto)
        {
            var session = await ValidateSessionAsync(dto.SessionCode);
            var student = await ValidateStudentAsync(dto.StudentId);
            await ValidateAttendanceNotExistsAsync(dto.StudentId, session.Id);

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

            return MapToAttendanceDto(attendance, student, session);
        }

        public async Task<IEnumerable<AttendanceDto>> GetAttendancesAsync(int? courseId = null, int? studentId = null, int? sessionId = null)
        {
            var query = _context.Attendances
                .Include(a => a.Student)
                .Include(a => a.Session)
                    .ThenInclude(s => s.Course)
                .AsQueryable();

            if (courseId.HasValue)
                query = query.Where(a => a.Session.CourseId == courseId.Value);

            if (studentId.HasValue)
                query = query.Where(a => a.StudentId == studentId.Value);

            if (sessionId.HasValue)
                query = query.Where(a => a.SessionId == sessionId.Value);

            var attendances = await query.ToListAsync();
            return attendances.Select(a => MapToAttendanceDto(a, a.Student, a.Session));
        }

        public async Task<AttendanceDto?> GetAttendanceByIdAsync(int id)
        {
            var attendance = await _context.Attendances
                .Include(a => a.Student)
                .Include(a => a.Session)
                    .ThenInclude(s => s.Course)
                .FirstOrDefaultAsync(a => a.Id == id);

            return attendance != null ? MapToAttendanceDto(attendance, attendance.Student, attendance.Session) : null;
        }

        public async Task<IEnumerable<AttendanceReportDto>> GetAttendanceReportsAsync(int? courseId = null)
        {
            var coursesQuery = _context.Courses.Where(c => c.IsActive);
            
            if (courseId.HasValue)
                coursesQuery = coursesQuery.Where(c => c.Id == courseId.Value);

            var courses = await coursesQuery.ToListAsync();
            var reports = new List<AttendanceReportDto>();

            foreach (var course in courses)
            {
                var report = await GenerateCourseReportAsync(course);
                reports.Add(report);
            }

            return reports;
        }

        public async Task<IEnumerable<object>> GetAttendanceAlertsAsync(double threshold = 70.0)
        {
            var courses = await _context.Courses.Where(c => c.IsActive).ToListAsync();
            var alerts = new List<object>();

            foreach (var course in courses)
            {
                var courseAlerts = await GenerateCourseAlertsAsync(course, threshold);
                alerts.AddRange(courseAlerts);
            }

            return alerts.OrderBy(a => ((dynamic)a).AttendanceRate);
        }

        public async Task<IEnumerable<AttendanceDto>> GetStudentAttendanceHistoryAsync(int studentId)
        {
            var student = await ValidateStudentAsync(studentId);

            var attendances = await _context.Attendances
                .Include(a => a.Session)
                    .ThenInclude(s => s.Course)
                .Where(a => a.StudentId == studentId)
                .OrderByDescending(a => a.RegisteredAt)
                .ToListAsync();

            return attendances.Select(a => MapToAttendanceDto(a, student, a.Session));
        }

        private async Task<Session> ValidateSessionAsync(string sessionCode)
        {
            var session = await _context.Sessions
                .Include(s => s.Course)
                .FirstOrDefaultAsync(s => s.UniqueCode == sessionCode && s.IsActive);

            if (session == null)
                throw new ArgumentException("Código de sesión no válido");

            if (session.Date.Date != DateTime.Today)
                throw new ArgumentException("Esta sesión no está activa para hoy");

            return session;
        }

        private async Task<Student> ValidateStudentAsync(int studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null)
                throw new ArgumentException("Estudiante no encontrado");

            return student;
        }

        private async Task ValidateAttendanceNotExistsAsync(int studentId, int sessionId)
        {
            var existingAttendance = await _context.Attendances
                .FirstOrDefaultAsync(a => a.StudentId == studentId && a.SessionId == sessionId);

            if (existingAttendance != null)
                throw new InvalidOperationException("La asistencia ya fue registrada para esta sesión");
        }

        private async Task<AttendanceReportDto> GenerateCourseReportAsync(Course course)
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

            return new AttendanceReportDto
            {
                CourseId = course.Id,
                CourseName = course.Name,
                CourseCode = course.Code,
                TotalSessions = sessions.Count,
                TotalStudents = students.Count,
                AttendanceRate = Math.Round(overallAttendanceRate, 2),
                StudentSummaries = studentSummaries
            };
        }

        private async Task<IEnumerable<object>> GenerateCourseAlertsAsync(Course course, double threshold)
        {
            var sessions = await _context.Sessions
                .Where(s => s.CourseId == course.Id && s.IsActive)
                .ToListAsync();

            if (sessions.Count == 0) return new List<object>();

            var students = await _context.Students.ToListAsync();
            var alerts = new List<object>();

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

            return alerts;
        }

        private static AttendanceDto MapToAttendanceDto(Attendance attendance, Student student, Session session)
        {
            return new AttendanceDto
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
        }
    }
}