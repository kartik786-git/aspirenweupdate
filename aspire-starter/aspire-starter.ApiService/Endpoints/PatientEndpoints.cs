using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class PatientEndpoints
{
    public static WebApplication MapPatientEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/patients").WithOpenApi().RequireAuthorization();

        group.MapGet("/", async (HospitalDbContext db) =>
            await db.Patients.OrderByDescending(p => p.RegistrationDate).ToListAsync());

        group.MapGet("/search", async (string? q, HospitalDbContext db) =>
        {
            if (string.IsNullOrWhiteSpace(q))
                return await db.Patients.Take(20).ToListAsync();
            return await db.Patients
                .Where(p => p.FirstName.Contains(q) || p.LastName.Contains(q) || p.Phone.Contains(q))
                .ToListAsync();
        });

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var patient = await db.Patients.FindAsync(id);
            return patient is null ? Results.NotFound() : Results.Ok(patient);
        });

        group.MapPost("/", async (Patient patient, HospitalDbContext db) =>
        {
            patient.RegistrationDate = DateTime.UtcNow;
            patient.IsActive = true;
            db.Patients.Add(patient);
            await db.SaveChangesAsync();
            return Results.Created($"/api/patients/{patient.Id}", patient);
        });

        group.MapPut("/{id}", async (int id, Patient updated, HospitalDbContext db) =>
        {
            var patient = await db.Patients.FindAsync(id);
            if (patient is null) return Results.NotFound();
            patient.FirstName = updated.FirstName;
            patient.LastName = updated.LastName;
            patient.DateOfBirth = updated.DateOfBirth;
            patient.Gender = updated.Gender;
            patient.Phone = updated.Phone;
            patient.Email = updated.Email;
            patient.Address = updated.Address;
            patient.BloodGroup = updated.BloodGroup;
            patient.EmergencyContactName = updated.EmergencyContactName;
            patient.EmergencyContactPhone = updated.EmergencyContactPhone;
            await db.SaveChangesAsync();
            return Results.Ok(patient);
        });

        group.MapDelete("/{id}", async (int id, HospitalDbContext db) =>
        {
            var patient = await db.Patients.FindAsync(id);
            if (patient is null) return Results.NotFound();
            patient.IsActive = false;
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        return app;
    }
}
