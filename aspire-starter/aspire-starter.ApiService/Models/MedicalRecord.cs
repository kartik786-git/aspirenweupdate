using System.ComponentModel.DataAnnotations;

namespace aspire_starter.ApiService.Models;

public class MedicalRecord
{
    public int Id { get; set; }

    public int PatientId { get; set; }
    public Patient Patient { get; set; } = null!;

    public int DoctorId { get; set; }
    public Doctor Doctor { get; set; } = null!;

    public int? AppointmentId { get; set; }
    public Appointment? Appointment { get; set; }

    [Required, MaxLength(2000)]
    public string Diagnosis { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Treatment { get; set; }

    [MaxLength(2000)]
    public string? Prescription { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    public DateTime RecordDate { get; set; } = DateTime.UtcNow;
}
