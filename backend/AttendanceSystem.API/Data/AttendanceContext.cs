using Microsoft.EntityFrameworkCore;
using AttendanceSystem.API.Models;

namespace AttendanceSystem.API.Data
{
    public class AttendanceContext : DbContext
    {
        public AttendanceContext(DbContextOptions<AttendanceContext> options) : base(options)
        {
        }

        public DbSet<Student> Students { get; set; }
        public DbSet<Course> Courses { get; set; }
        public DbSet<Session> Sessions { get; set; }
        public DbSet<Attendance> Attendances { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure Student
            modelBuilder.Entity<Student>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
                entity.Property(e => e.StudentCode).IsRequired().HasMaxLength(20);
                entity.HasIndex(e => e.Email).IsUnique();
                entity.HasIndex(e => e.StudentCode).IsUnique();
            });

            // Configure Course
            modelBuilder.Entity<Course>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Code).IsRequired().HasMaxLength(20);
                entity.Property(e => e.Description).HasMaxLength(1000);
                entity.Property(e => e.InstructorName).IsRequired().HasMaxLength(200);
                entity.HasIndex(e => e.Code).IsUnique();
            });

            // Configure Session
            modelBuilder.Entity<Session>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
                entity.Property(e => e.UniqueCode).IsRequired().HasMaxLength(10);
                entity.HasIndex(e => e.UniqueCode).IsUnique();
                
                entity.HasOne(s => s.Course)
                    .WithMany(c => c.Sessions)
                    .HasForeignKey(s => s.CourseId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Configure Attendance
            modelBuilder.Entity<Attendance>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Notes).HasMaxLength(500);
                
                entity.HasOne(a => a.Student)
                    .WithMany(s => s.Attendances)
                    .HasForeignKey(a => a.StudentId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                entity.HasOne(a => a.Session)
                    .WithMany(s => s.Attendances)
                    .HasForeignKey(a => a.SessionId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Prevent duplicate attendance for same student in same session
                entity.HasIndex(e => new { e.StudentId, e.SessionId }).IsUnique();
            });

            // Seed data
            modelBuilder.Entity<Student>().HasData(
                new Student { Id = 1, FirstName = "Juan", LastName = "Pérez", Email = "juan.perez@email.com", StudentCode = "EST001" },
                new Student { Id = 2, FirstName = "María", LastName = "González", Email = "maria.gonzalez@email.com", StudentCode = "EST002" },
                new Student { Id = 3, FirstName = "Carlos", LastName = "Rodríguez", Email = "carlos.rodriguez@email.com", StudentCode = "EST003" }
            );

            modelBuilder.Entity<Course>().HasData(
                new Course { Id = 1, Name = "Programación Web", Code = "PW001", Description = "Curso de desarrollo web con tecnologías modernas", InstructorName = "Dr. Ana López" },
                new Course { Id = 2, Name = "Base de Datos", Code = "BD001", Description = "Fundamentos de bases de datos relacionales", InstructorName = "Ing. Roberto Silva" }
            );
        }
    }
}
