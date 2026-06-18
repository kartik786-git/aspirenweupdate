using System.ComponentModel.DataAnnotations;

namespace aspire_starter.Web.Models;

public class AppointmentDto
{
    public int Id { get; set; }

    public int PatientId { get; set; }
    public PatientDto? Patient { get; set; }

    public int DoctorId { get; set; }
    public DoctorDto? Doctor { get; set; }

    public DateOnly AppointmentDate { get; set; }
    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }

    [MaxLength(20)]
    public string Status { get; set; } = "Scheduled";

    [MaxLength(500)]
    public string? Reason { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; }
}
