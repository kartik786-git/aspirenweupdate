using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class MedicalRecordEndpoints
{
    public static WebApplication MapMedicalRecordEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/medical-records").WithOpenApi().RequireAuthorization();

        group.MapGet("/patient/{patientId}", async (int patientId, HospitalDbContext db) =>
            await db.MedicalRecords
                .Include(m => m.Doctor)
                .Include(m => m.Appointment)
                .Where(m => m.PatientId == patientId)
                .OrderByDescending(m => m.RecordDate)
                .ToListAsync());

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var record = await db.MedicalRecords
                .Include(m => m.Patient)
                .Include(m => m.Doctor)
                .Include(m => m.Appointment)
                .FirstOrDefaultAsync(m => m.Id == id);
            return record is null ? Results.NotFound() : Results.Ok(record);
        });

        group.MapPost("/", async (MedicalRecord record, HospitalDbContext db) =>
        {
            record.RecordDate = DateTime.UtcNow;
            db.MedicalRecords.Add(record);
            await db.SaveChangesAsync();
            return Results.Created($"/api/medical-records/{record.Id}", record);
        });

        group.MapPut("/{id}", async (int id, MedicalRecord updated, HospitalDbContext db) =>
        {
            var record = await db.MedicalRecords.FindAsync(id);
            if (record is null) return Results.NotFound();
            record.Diagnosis = updated.Diagnosis;
            record.Treatment = updated.Treatment;
            record.Prescription = updated.Prescription;
            record.Notes = updated.Notes;
            await db.SaveChangesAsync();
            return Results.Ok(record);
        });

        return app;
    }
}
