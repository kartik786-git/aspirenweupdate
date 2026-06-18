using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Data;

public class HospitalDbContext(DbContextOptions<HospitalDbContext> options) : DbContext(options)
{
    public DbSet<Department> Departments => Set<Department>();
    public DbSet<Doctor> Doctors => Set<Doctor>();
    public DbSet<Patient> Patients => Set<Patient>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<MedicalRecord> MedicalRecords => Set<MedicalRecord>();
    public DbSet<Billing> Billings => Set<Billing>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<Staff> Staff => Set<Staff>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Department>(e =>
        {
            e.HasIndex(d => d.Name).IsUnique();
            e.HasOne(d => d.HeadDoctor)
                .WithMany()
                .HasForeignKey(d => d.HeadDoctorId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Doctor>(e =>
        {
            e.HasIndex(d => d.Email).IsUnique().HasFilter("[Email] IS NOT NULL");
            e.HasOne(d => d.Department)
                .WithMany(dept => dept.Doctors)
                .HasForeignKey(d => d.DepartmentId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Patient>(e =>
        {
            e.HasIndex(p => p.Phone).IsUnique();
        });

        modelBuilder.Entity<Appointment>(e =>
        {
            e.HasOne(a => a.Patient)
                .WithMany(p => p.Appointments)
                .HasForeignKey(a => a.PatientId)
                .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(a => a.Doctor)
                .WithMany(d => d.Appointments)
                .HasForeignKey(a => a.DoctorId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<MedicalRecord>(e =>
        {
            e.HasOne(m => m.Patient)
                .WithMany(p => p.MedicalRecords)
                .HasForeignKey(m => m.PatientId)
                .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(m => m.Doctor)
                .WithMany(d => d.MedicalRecords)
                .HasForeignKey(m => m.DoctorId)
                .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(m => m.Appointment)
                .WithMany()
                .HasForeignKey(m => m.AppointmentId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Billing>(e =>
        {
            e.HasOne(b => b.Patient)
                .WithMany(p => p.Bills)
                .HasForeignKey(b => b.PatientId)
                .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(b => b.Appointment)
                .WithMany()
                .HasForeignKey(b => b.AppointmentId)
                .OnDelete(DeleteBehavior.SetNull);
            e.HasIndex(b => b.InvoiceNumber).IsUnique();
        });

        modelBuilder.Entity<Room>(e =>
        {
            e.HasOne(r => r.Department)
                .WithMany(dept => dept.Rooms)
                .HasForeignKey(r => r.DepartmentId)
                .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(r => r.CurrentPatient)
                .WithMany()
                .HasForeignKey(r => r.CurrentPatientId)
                .OnDelete(DeleteBehavior.SetNull);
            e.HasIndex(r => new { r.RoomNumber, r.BedNumber }).IsUnique();
        });

        modelBuilder.Entity<Staff>(e =>
        {
            e.HasIndex(s => s.Email).IsUnique().HasFilter("[Email] IS NOT NULL");
            e.HasOne(s => s.Department)
                .WithMany(dept => dept.StaffMembers)
                .HasForeignKey(s => s.DepartmentId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Billing>(e => e.Property(b => b.TotalAmount).HasPrecision(18, 2));
        modelBuilder.Entity<Billing>(e => e.Property(b => b.PaidAmount).HasPrecision(18, 2));
        modelBuilder.Entity<Room>(e => e.Property(r => r.DailyRate).HasPrecision(18, 2));
        modelBuilder.Entity<Staff>(e => e.Property(s => s.Salary).HasPrecision(18, 2));

        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        var now = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        modelBuilder.Entity<Department>().HasData(
            new Department { Id = 1, Name = "General Medicine", Description = "Primary care and internal medicine", Location = "Ground Floor", CreatedAt = now },
            new Department { Id = 2, Name = "Cardiology", Description = "Heart and cardiovascular system", Location = "First Floor", CreatedAt = now },
            new Department { Id = 3, Name = "Neurology", Description = "Brain and nervous system", Location = "Second Floor", CreatedAt = now },
            new Department { Id = 4, Name = "Orthopedics", Description = "Bones, joints, and muscles", Location = "Third Floor", CreatedAt = now },
            new Department { Id = 5, Name = "Pediatrics", Description = "Child healthcare", Location = "Ground Floor", CreatedAt = now }
        );

        modelBuilder.Entity<Doctor>().HasData(
            new Doctor { Id = 1, FirstName = "John", LastName = "Smith", Specialization = "General Physician", DepartmentId = 1, Phone = "1111111111", Email = "john.smith@hospital.com", Qualification = "MBBS, MD", ExperienceYears = 12, IsActive = true, CreatedAt = now },
            new Doctor { Id = 2, FirstName = "Sarah", LastName = "Johnson", Specialization = "Cardiologist", DepartmentId = 2, Phone = "2222222222", Email = "sarah.johnson@hospital.com", Qualification = "MBBS, DM Cardiology", ExperienceYears = 15, IsActive = true, CreatedAt = now },
            new Doctor { Id = 3, FirstName = "Michael", LastName = "Brown", Specialization = "Neurologist", DepartmentId = 3, Phone = "3333333333", Email = "michael.brown@hospital.com", Qualification = "MBBS, DM Neurology", ExperienceYears = 10, IsActive = true, CreatedAt = now },
            new Doctor { Id = 4, FirstName = "Emily", LastName = "Davis", Specialization = "Orthopedic Surgeon", DepartmentId = 4, Phone = "4444444444", Email = "emily.davis@hospital.com", Qualification = "MBBS, MS Ortho", ExperienceYears = 8, IsActive = true, CreatedAt = now },
            new Doctor { Id = 5, FirstName = "James", LastName = "Wilson", Specialization = "Pediatrician", DepartmentId = 5, Phone = "5555555555", Email = "james.wilson@hospital.com", Qualification = "MBBS, MD Pediatrics", ExperienceYears = 9, IsActive = true, CreatedAt = now }
        );

        modelBuilder.Entity<Patient>().HasData(
            new Patient { Id = 1, FirstName = "Alice", LastName = "Williams", DateOfBirth = new DateTime(1990, 5, 15), Gender = "Female", Phone = "6666666666", Email = "alice.w@email.com", Address = "123 Main St", BloodGroup = "A+", RegistrationDate = now, IsActive = true },
            new Patient { Id = 2, FirstName = "Bob", LastName = "Taylor", DateOfBirth = new DateTime(1985, 8, 22), Gender = "Male", Phone = "7777777777", Email = "bob.t@email.com", Address = "456 Oak Ave", BloodGroup = "O+", RegistrationDate = now, IsActive = true },
            new Patient { Id = 3, FirstName = "Carol", LastName = "Anderson", DateOfBirth = new DateTime(1975, 12, 3), Gender = "Female", Phone = "8888888888", Email = "carol.a@email.com", Address = "789 Pine Rd", BloodGroup = "B-", RegistrationDate = now, IsActive = true }
        );

        modelBuilder.Entity<Room>().HasData(
            new Room { Id = 1, RoomNumber = "101", BedNumber = "A", WardType = "General", DepartmentId = 1, IsOccupied = false, DailyRate = 500 },
            new Room { Id = 2, RoomNumber = "101", BedNumber = "B", WardType = "General", DepartmentId = 1, IsOccupied = false, DailyRate = 500 },
            new Room { Id = 3, RoomNumber = "201", BedNumber = "A", WardType = "Private", DepartmentId = 2, IsOccupied = false, DailyRate = 2000 },
            new Room { Id = 4, RoomNumber = "201", BedNumber = "B", WardType = "Private", DepartmentId = 2, IsOccupied = false, DailyRate = 2000 },
            new Room { Id = 5, RoomNumber = "301", BedNumber = "A", WardType = "ICU", DepartmentId = 3, IsOccupied = false, DailyRate = 5000 }
        );

        modelBuilder.Entity<Staff>().HasData(
            new Staff { Id = 1, FirstName = "Nurse", LastName = "Rachel", Role = "Nurse", DepartmentId = 1, Phone = "9990001111", Email = "rachel@hospital.com", HireDate = now, IsActive = true },
            new Staff { Id = 2, FirstName = "Nurse", LastName = "Tom", Role = "Nurse", DepartmentId = 2, Phone = "9990002222", Email = "tom@hospital.com", HireDate = now, IsActive = true },
            new Staff { Id = 3, FirstName = "Reception", LastName = "Kate", Role = "Receptionist", DepartmentId = 1, Phone = "9990003333", Email = "kate@hospital.com", HireDate = now, IsActive = true }
        );
    }
}
