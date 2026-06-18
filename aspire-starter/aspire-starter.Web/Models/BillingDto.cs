using System.ComponentModel.DataAnnotations;

namespace aspire_starter.Web.Models;

public class BillingDto
{
    public int Id { get; set; }
    public int PatientId { get; set; }
    public PatientDto? Patient { get; set; }
    public int? AppointmentId { get; set; }

    [Required, MaxLength(20)]
    public string InvoiceNumber { get; set; } = string.Empty;

    public DateTime BillDate { get; set; }
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
