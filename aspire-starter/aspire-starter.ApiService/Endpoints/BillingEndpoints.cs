using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class BillingEndpoints
{
    private static int _invoiceCounter;

    public static WebApplication MapBillingEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/billing").WithOpenApi().RequireAuthorization();

        group.MapGet("/", async (string? status, HospitalDbContext db) =>
        {
            var query = db.Billings
                .Include(b => b.Patient)
                .AsQueryable();
            if (!string.IsNullOrWhiteSpace(status))
                query = query.Where(b => b.Status == status);
            return await query.OrderByDescending(b => b.BillDate).ToListAsync();
        });

        group.MapGet("/patient/{patientId}", async (int patientId, HospitalDbContext db) =>
            await db.Billings
                .Where(b => b.PatientId == patientId)
                .OrderByDescending(b => b.BillDate)
                .ToListAsync());

        group.MapGet("/revenue", async (DateTime? from, DateTime? to, HospitalDbContext db) =>
        {
            var query = db.Billings.Where(b => b.Status != "Cancelled");
            if (from.HasValue)
                query = query.Where(b => b.BillDate >= from.Value);
            if (to.HasValue)
                query = query.Where(b => b.BillDate <= to.Value);
            var revenue = await query.SumAsync(b => (decimal?)b.PaidAmount) ?? 0;
            return Results.Ok(new { totalRevenue = revenue });
        });

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var bill = await db.Billings
                .Include(b => b.Patient)
                .Include(b => b.Appointment)
                .FirstOrDefaultAsync(b => b.Id == id);
            return bill is null ? Results.NotFound() : Results.Ok(bill);
        });

        group.MapPost("/", async (Billing billing, HospitalDbContext db) =>
        {
            _invoiceCounter++;
            billing.InvoiceNumber = $"INV-{DateTime.UtcNow:yyyyMMdd}-{_invoiceCounter:D4}";
            billing.BillDate = DateTime.UtcNow;
            billing.Status = billing.PaidAmount >= billing.TotalAmount ? "Paid" : billing.PaidAmount > 0 ? "Partial" : "Unpaid";
            db.Billings.Add(billing);
            await db.SaveChangesAsync();
            return Results.Created($"/api/billing/{billing.Id}", billing);
        });

        group.MapPut("/{id}/pay", async (int id, decimal amount, HospitalDbContext db) =>
        {
            var bill = await db.Billings.FindAsync(id);
            if (bill is null) return Results.NotFound();
            bill.PaidAmount += amount;
            bill.Status = bill.PaidAmount >= bill.TotalAmount ? "Paid" : "Partial";
            await db.SaveChangesAsync();
            return Results.Ok(bill);
        });

        return app;
    }
}
