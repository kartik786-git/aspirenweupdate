using System.ComponentModel.DataAnnotations;

namespace aspire_starter.Web.Models;

public class MedicalRecordDto
{
    public int Id { get; set; }
    public int PatientId { get; set; }
    public int DoctorId { get; set; }
    public DoctorDto? Doctor { get; set; }
    public int? AppointmentId { get; set; }

    [Required, MaxLength(2000)]
    public string Diagnosis { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Treatment { get; set; }

    [MaxLength(2000)]
    public string? Prescription { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    public DateTime RecordDate { get; set; }
}
