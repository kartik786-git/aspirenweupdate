using System.ComponentModel.DataAnnotations;

namespace aspire_starter.ApiService.Models;

public class Room
{
    public int Id { get; set; }

    [Required, MaxLength(10)]
    public string RoomNumber { get; set; } = string.Empty;

    [Required, MaxLength(10)]
    public string BedNumber { get; set; } = string.Empty;

    [MaxLength(50)]
    public string WardType { get; set; } = "General";

    public int DepartmentId { get; set; }
    public Department Department { get; set; } = null!;

    public bool IsOccupied { get; set; }

    public int? CurrentPatientId { get; set; }
    public Patient? CurrentPatient { get; set; }

    public DateTime? AdmissionDate { get; set; }

    public decimal DailyRate { get; set; }

    [MaxLength(500)]
    public string? Notes { get; set; }
}
