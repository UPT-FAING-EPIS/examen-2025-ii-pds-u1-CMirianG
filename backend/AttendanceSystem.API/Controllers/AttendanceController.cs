using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Models;
using AttendanceSystem.API.DTOs;
using AttendanceSystem.API.Interfaces;

namespace AttendanceSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AttendanceController : ControllerBase
    {
        private readonly IAttendanceService _attendanceService;
        private readonly AttendanceContext _context;

        public AttendanceController(IAttendanceService attendanceService, AttendanceContext context)
        {
            _attendanceService = attendanceService;
            _context = context;
        }

        // POST: api/attendance
        [HttpPost]
        public async Task<ActionResult<AttendanceDto>> RegisterAttendance(RegisterAttendanceDto dto)
        {
            try
            {
                var result = await _attendanceService.RegisterAttendanceAsync(dto);
                return CreatedAtAction("GetAttendance", new { id = result.Id }, result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // GET: api/attendance/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<AttendanceDto>> GetAttendance(int id)
        {
            var result = await _attendanceService.GetAttendanceByIdAsync(id);
            return result != null ? Ok(result) : NotFound();
        }

        // GET: api/attendance
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AttendanceDto>>> GetAttendances(
            [FromQuery] int? courseId, 
            [FromQuery] int? studentId,
            [FromQuery] int? sessionId)
        {
            var result = await _attendanceService.GetAttendancesAsync(courseId, studentId, sessionId);
            return Ok(result);
        }

        // GET: api/attendance/students
        [HttpGet("students")]
        public async Task<ActionResult<IEnumerable<Student>>> GetStudents()
        {
            return await _context.Students.ToListAsync();
        }

        // PUT: api/attendance/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAttendance(int id, AttendanceDto attendanceDto)
        {
            if (id != attendanceDto.Id)
            {
                return BadRequest("ID mismatch");
            }

            var attendance = await _context.Attendances.FindAsync(id);
            if (attendance == null)
            {
                return NotFound();
            }

            attendance.IsPresent = attendanceDto.IsPresent;
            attendance.Notes = attendanceDto.Notes;

            try
            {
                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!AttendanceExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }
        }

        // DELETE: api/attendance/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAttendance(int id)
        {
            var attendance = await _context.Attendances.FindAsync(id);
            if (attendance == null)
            {
                return NotFound();
            }

            _context.Attendances.Remove(attendance);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // GET: api/attendance/reports
        [HttpGet("reports")]
        public async Task<ActionResult<IEnumerable<AttendanceReportDto>>> GetAttendanceReports([FromQuery] int? courseId)
        {
            var reports = await _attendanceService.GetAttendanceReportsAsync(courseId);
            return Ok(reports);
        }

        // GET: api/attendance/alerts
        [HttpGet("alerts")]
        public async Task<ActionResult<IEnumerable<object>>> GetAttendanceAlerts([FromQuery] double threshold = 70.0)
        {
            var alerts = await _attendanceService.GetAttendanceAlertsAsync(threshold);
            return Ok(alerts);
        }

        // GET: api/attendance/student/{studentId}/history
        [HttpGet("student/{studentId}/history")]
        public async Task<ActionResult<IEnumerable<AttendanceDto>>> GetStudentAttendanceHistory(int studentId)
        {
            var history = await _attendanceService.GetStudentAttendanceHistoryAsync(studentId);
            return Ok(history);
        }

        private bool AttendanceExists(int id)
        {
            return _context.Attendances.Any(e => e.Id == id);
        }
    }
}
