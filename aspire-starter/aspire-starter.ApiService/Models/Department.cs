using System.ComponentModel.DataAnnotations;

namespace aspire_starter.ApiService.Models;

public class Department
{
    public int Id { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Description { get; set; }

    [MaxLength(200)]
    public string? Location { get; set; }

    public int? HeadDoctorId { get; set; }
    public Doctor? HeadDoctor { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Doctor> Doctors { get; set; } = [];
    public ICollection<Room> Rooms { get; set; } = [];
    public ICollection<Staff> StaffMembers { get; set; } = [];
}
