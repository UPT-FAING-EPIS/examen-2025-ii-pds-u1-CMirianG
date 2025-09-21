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
    }
}
