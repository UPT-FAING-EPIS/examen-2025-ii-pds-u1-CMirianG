namespace AttendanceSystem.API.DTOs
{
    public class AttendanceDto
    {
        public int Id { get; set; }
        public int StudentId { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string StudentCode { get; set; } = string.Empty;
        public int SessionId { get; set; }
        public string SessionTitle { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public DateTime RegisteredAt { get; set; }
        public bool IsPresent { get; set; }
        public string? Notes { get; set; }
    }

    public class RegisterAttendanceDto
    {
        public int StudentId { get; set; }
        public string SessionCode { get; set; } = string.Empty;
        public string? Notes { get; set; }
    }

    public class AttendanceReportDto
    {
        public int CourseId { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public int TotalSessions { get; set; }
        public int TotalStudents { get; set; }
        public double AttendanceRate { get; set; }
        public List<StudentAttendanceSummary> StudentSummaries { get; set; } = new List<StudentAttendanceSummary>();
    }

    public class StudentAttendanceSummary
    {
        public int StudentId { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string StudentCode { get; set; } = string.Empty;
        public int AttendedSessions { get; set; }
        public int TotalSessions { get; set; }
        public double AttendanceRate { get; set; }
    }
}
