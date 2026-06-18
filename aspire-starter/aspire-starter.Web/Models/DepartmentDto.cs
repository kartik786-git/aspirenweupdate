using System.ComponentModel.DataAnnotations;

namespace aspire_starter.Web.Models;

public class DepartmentDto
{
    public int Id { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Description { get; set; }

    [MaxLength(200)]
    public string? Location { get; set; }

    public int? HeadDoctorId { get; set; }
    public DoctorDto? HeadDoctor { get; set; }
    public DateTime CreatedAt { get; set; }
}
