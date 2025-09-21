using AttendanceSystem.API.DTOs;
using AttendanceSystem.API.Models;

namespace AttendanceSystem.API.Interfaces
{
    public interface IAttendanceService
    {
        Task<AttendanceDto> RegisterAttendanceAsync(RegisterAttendanceDto dto);
        Task<IEnumerable<AttendanceDto>> GetAttendancesAsync(int? courseId = null, int? studentId = null, int? sessionId = null);
        Task<AttendanceDto?> GetAttendanceByIdAsync(int id);
        Task<IEnumerable<AttendanceReportDto>> GetAttendanceReportsAsync(int? courseId = null);
        Task<IEnumerable<object>> GetAttendanceAlertsAsync(double threshold = 70.0);
        Task<IEnumerable<AttendanceDto>> GetStudentAttendanceHistoryAsync(int studentId);
    }
}
