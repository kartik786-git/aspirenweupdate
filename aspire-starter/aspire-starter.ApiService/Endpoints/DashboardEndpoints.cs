using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;

namespace aspire_starter.ApiService.Endpoints;

public static class DashboardEndpoints
{
    public static WebApplication MapDashboardEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/dashboard").WithOpenApi().RequireAuthorization();

        group.MapGet("/summary", async (HospitalDbContext db) =>
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            var monthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1, 0, 0, 0, DateTimeKind.Utc);

            var totalPatients = await db.Patients.CountAsync(p => p.IsActive);
            var activeDoctors = await db.Doctors.CountAsync(d => d.IsActive);
            var todayAppointments = await db.Appointments.CountAsync(a => a.AppointmentDate == today);
            var totalRooms = await db.Rooms.CountAsync();
            var occupiedRooms = await db.Rooms.CountAsync(r => r.IsOccupied);
            var occupancyRate = totalRooms > 0 ? (double)occupiedRooms / totalRooms * 100 : 0;
            var monthlyRevenue = await db.Billings
                .Where(b => b.BillDate >= monthStart && b.Status != "Cancelled")
                .SumAsync(b => (decimal?)b.PaidAmount) ?? 0;
            var pendingBills = await db.Billings.CountAsync(b => b.Status == "Unpaid" || b.Status == "Partial");

            return Results.Ok(new
            {
                totalPatients,
                activeDoctors,
                todayAppointments,
                totalRooms,
                occupiedRooms,
                occupancyRate = Math.Round(occupancyRate, 1),
                monthlyRevenue,
                pendingBills
            });
        });

        return app;
    }
}
