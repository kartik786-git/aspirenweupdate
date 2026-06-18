using System.ComponentModel.DataAnnotations;

namespace aspire_starter.Web.Models;

public class DoctorDto
{
    public int Id { get; set; }

    [Required, MaxLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required, MaxLength(50)]
    public string LastName { get; set; } = string.Empty;

    [MaxLength(100)]
    public string Specialization { get; set; } = string.Empty;

    public int DepartmentId { get; set; }
    public DepartmentDto? Department { get; set; }

    [MaxLength(20)]
    public string? Phone { get; set; }

    [MaxLength(100)]
    public string? Email { get; set; }

    [MaxLength(200)]
    public string? Qualification { get; set; }

    public int ExperienceYears { get; set; }

    [MaxLength(500)]
    public string? Schedule { get; set; }

    public bool IsActive { get; set; } = true;

    public string FullName => $"{FirstName} {LastName}";
}
