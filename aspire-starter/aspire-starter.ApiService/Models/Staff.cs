using System.ComponentModel.DataAnnotations;

namespace aspire_starter.ApiService.Models;

public class Staff
{
    public int Id { get; set; }

    [Required, MaxLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required, MaxLength(50)]
    public string LastName { get; set; } = string.Empty;

    [MaxLength(50)]
    public string Role { get; set; } = string.Empty;

    public int DepartmentId { get; set; }
    public Department Department { get; set; } = null!;

    [MaxLength(20)]
    public string? Phone { get; set; }

    [MaxLength(100)]
    public string? Email { get; set; }

    public DateTime HireDate { get; set; } = DateTime.UtcNow;

    public decimal? Salary { get; set; }

    public bool IsActive { get; set; } = true;
}
