using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Models;
using AttendanceSystem.API.Interfaces;

namespace AttendanceSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CoursesController : ControllerBase
    {
        private readonly AttendanceContext _context;
        private readonly IRepository<Course> _courseRepository;

        public CoursesController(AttendanceContext context, IRepository<Course> courseRepository)
        {
            _context = context;
            _courseRepository = courseRepository;
        }

        // GET: api/courses
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Course>>> GetCourses()
        {
            try
            {
                var courses = await _context.Courses
                    .Where(c => c.IsActive)
                    .ToListAsync();
                return Ok(courses);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error getting courses: {ex.Message}");
            }
        }

        // GET: api/courses/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Course>> GetCourse(int id)
        {
            try
            {
                var course = await _context.Courses
                    .FirstOrDefaultAsync(c => c.Id == id && c.IsActive);

                if (course == null)
                {
                    return NotFound();
                }

                return Ok(course);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error getting course: {ex.Message}");
            }
        }

        // POST: api/courses
        [HttpPost]
        public async Task<ActionResult<Course>> PostCourse(Course course)
        {
            try
            {
                // Set default values
                course.IsActive = true;
                course.CreatedAt = DateTime.UtcNow;
                
                // Use context directly for in-memory database
                _context.Courses.Add(course);
                await _context.SaveChangesAsync();
                
                return CreatedAtAction("GetCourse", new { id = course.Id }, course);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error creating course: {ex.Message}");
            }
        }

        // PUT: api/courses/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> PutCourse(int id, Course course)
        {
            if (id != course.Id)
            {
                return BadRequest("ID mismatch");
            }

            try
            {
                var existingCourse = await _context.Courses.FindAsync(id);
                if (existingCourse == null)
                {
                    return NotFound();
                }

                // Update properties
                existingCourse.Name = course.Name;
                existingCourse.Code = course.Code;
                existingCourse.Description = course.Description;
                existingCourse.InstructorName = course.InstructorName;
                existingCourse.IsActive = course.IsActive;

                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest($"Error updating course: {ex.Message}");
            }
        }

        // DELETE: api/courses/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCourse(int id)
        {
            try
            {
                var course = await _context.Courses.FindAsync(id);
                if (course == null)
                {
                    return NotFound();
                }

                // Soft delete
                course.IsActive = false;
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest($"Error deleting course: {ex.Message}");
            }
        }

        private bool CourseExists(int id)
        {
            return _context.Courses.Any(e => e.Id == id);
        }
    }
}
