using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class AppointmentEndpoints
{
    public static WebApplication MapAppointmentEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/appointments").WithOpenApi().RequireAuthorization();

        group.MapGet("/", async (DateTime? date, string? status, HospitalDbContext db) =>
        {
            var query = db.Appointments
                .Include(a => a.Patient)
                .Include(a => a.Doctor)
                .AsQueryable();
            if (date.HasValue)
                query = query.Where(a => a.AppointmentDate == DateOnly.FromDateTime(date.Value));
            if (!string.IsNullOrWhiteSpace(status))
                query = query.Where(a => a.Status == status);
            return await query.OrderBy(a => a.AppointmentDate).ThenBy(a => a.StartTime).ToListAsync();
        });

        group.MapGet("/patient/{patientId}", async (int patientId, HospitalDbContext db) =>
            await db.Appointments
                .Include(a => a.Doctor)
                .Where(a => a.PatientId == patientId)
                .OrderByDescending(a => a.AppointmentDate)
                .ToListAsync());

        group.MapGet("/doctor/{doctorId}/date/{date}", async (int doctorId, DateOnly date, HospitalDbContext db) =>
            await db.Appointments
                .Include(a => a.Patient)
                .Where(a => a.DoctorId == doctorId && a.AppointmentDate == date)
                .OrderBy(a => a.StartTime)
                .ToListAsync());

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var appointment = await db.Appointments
                .Include(a => a.Patient)
                .Include(a => a.Doctor)
                .FirstOrDefaultAsync(a => a.Id == id);
            return appointment is null ? Results.NotFound() : Results.Ok(appointment);
        });

        group.MapPost("/", async (Appointment appointment, HospitalDbContext db) =>
        {
            var conflict = await db.Appointments.AnyAsync(a =>
                a.DoctorId == appointment.DoctorId &&
                a.AppointmentDate == appointment.AppointmentDate &&
                a.StartTime < appointment.EndTime &&
                a.EndTime > appointment.StartTime &&
                a.Status != "Cancelled");
            if (conflict)
                return Results.Conflict(new { message = "Doctor already has an appointment in this time slot" });

            appointment.CreatedAt = DateTime.UtcNow;
            appointment.Status = "Scheduled";
            db.Appointments.Add(appointment);
            await db.SaveChangesAsync();
            return Results.Created($"/api/appointments/{appointment.Id}", appointment);
        });

        group.MapPut("/{id}/cancel", async (int id, HospitalDbContext db) =>
        {
            var appointment = await db.Appointments.FindAsync(id);
            if (appointment is null) return Results.NotFound();
            appointment.Status = "Cancelled";
            await db.SaveChangesAsync();
            return Results.Ok(appointment);
        });

        group.MapPut("/{id}/complete", async (int id, HospitalDbContext db) =>
        {
            var appointment = await db.Appointments.FindAsync(id);
            if (appointment is null) return Results.NotFound();
            appointment.Status = "Completed";
            await db.SaveChangesAsync();
            return Results.Ok(appointment);
        });

        return app;
    }
}
