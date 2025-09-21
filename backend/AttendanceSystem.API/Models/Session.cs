namespace AttendanceSystem.API.Models
{
    public class Session
    {
        public int Id { get; set; }
        public int CourseId { get; set; }
        public string Title { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public string UniqueCode { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public virtual Course Course { get; set; } = null!;
        public virtual ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
    }
}
