using System.ComponentModel.DataAnnotations;

namespace aspire_starter.ApiService.Models;

public class Billing
{
    public int Id { get; set; }

    public int PatientId { get; set; }
    public Patient Patient { get; set; } = null!;

    public int? AppointmentId { get; set; }
    public Appointment? Appointment { get; set; }

    [Required, MaxLength(20)]
    public string InvoiceNumber { get; set; } = string.Empty;

    public DateTime BillDate { get; set; } = DateTime.UtcNow;

    public decimal TotalAmount { get; set; }

    public decimal PaidAmount { get; set; }

    public decimal DueAmount => TotalAmount - PaidAmount;

    [MaxLength(20)]
    public string Status { get; set; } = "Unpaid";

    [MaxLength(50)]
    public string? PaymentMethod { get; set; }

    [MaxLength(500)]
    public string? Remarks { get; set; }
}
