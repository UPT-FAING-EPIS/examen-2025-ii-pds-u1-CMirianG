using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Data;
using AttendanceSystem.API.Models;

namespace AttendanceSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SessionsController : ControllerBase
    {
        private readonly AttendanceContext _context;

        public SessionsController(AttendanceContext context)
        {
            _context = context;
        }

        // GET: api/sessions
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Session>>> GetSessions([FromQuery] int? courseId)
        {
            var query = _context.Sessions
                .Include(s => s.Course)
                .Where(s => s.IsActive);

            if (courseId.HasValue)
            {
                query = query.Where(s => s.CourseId == courseId.Value);
            }

            return await query.ToListAsync();
        }

        // GET: api/sessions/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Session>> GetSession(int id)
        {
            var session = await _context.Sessions
                .Include(s => s.Course)
                .Include(s => s.Attendances)
                    .ThenInclude(a => a.Student)
                .FirstOrDefaultAsync(s => s.Id == id && s.IsActive);

            if (session == null)
            {
                return NotFound();
            }

            return session;
        }

        // POST: api/sessions
        [HttpPost]
        public async Task<ActionResult<Session>> PostSession(Session session)
        {
            try
            {
                // Set default values
                session.UniqueCode = GenerateUniqueCode();
                session.IsActive = true;
                session.CreatedAt = DateTime.UtcNow;
                
                _context.Sessions.Add(session);
                await _context.SaveChangesAsync();

                return CreatedAtAction("GetSession", new { id = session.Id }, session);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error creating session: {ex.Message}");
            }
        }

        // PUT: api/sessions/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> PutSession(int id, Session session)
        {
            if (id != session.Id)
            {
                return BadRequest();
            }

            _context.Entry(session).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!SessionExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/sessions/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSession(int id)
        {
            var session = await _context.Sessions.FindAsync(id);
            if (session == null)
            {
                return NotFound();
            }

            session.IsActive = false;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // GET: api/sessions/by-code/{code}
        [HttpGet("by-code/{code}")]
        public async Task<ActionResult<Session>> GetSessionByCode(string code)
        {
            var session = await _context.Sessions
                .Include(s => s.Course)
                .FirstOrDefaultAsync(s => s.UniqueCode == code && s.IsActive);

            if (session == null)
            {
                return NotFound("Código de sesión no válido");
            }

            // Check if session is still valid (today's date)
            if (session.Date.Date != DateTime.Today)
            {
                return BadRequest("Esta sesión no está activa para hoy");
            }

            return session;
        }

        private string GenerateUniqueCode()
        {
            var random = new Random();
            string code;
            do
            {
                code = random.Next(100000, 999999).ToString();
            } 
            while (_context.Sessions.Any(s => s.UniqueCode == code));
            
            return code;
        }

        private bool SessionExists(int id)
        {
            return _context.Sessions.Any(e => e.Id == id);
        }
    }
}
