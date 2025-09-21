namespace AttendanceSystem.API.Models
{
    public class Attendance
    {
        public int Id { get; set; }
        public int StudentId { get; set; }
        public int SessionId { get; set; }
        public DateTime RegisteredAt { get; set; } = DateTime.UtcNow;
        public bool IsPresent { get; set; } = true;
        public string? Notes { get; set; }
        
        // Navigation properties
        public virtual Student Student { get; set; } = null!;
        public virtual Session Session { get; set; } = null!;
    }
}
