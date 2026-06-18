using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class DoctorEndpoints
{
    public static WebApplication MapDoctorEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/doctors").WithOpenApi().RequireAuthorization();

        group.MapGet("/", async (HospitalDbContext db) =>
            await db.Doctors.Include(d => d.Department).ToListAsync());

        group.MapGet("/department/{deptId}", async (int deptId, HospitalDbContext db) =>
            await db.Doctors.Where(d => d.DepartmentId == deptId).Include(d => d.Department).ToListAsync());

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var doctor = await db.Doctors.Include(d => d.Department).FirstOrDefaultAsync(d => d.Id == id);
            return doctor is null ? Results.NotFound() : Results.Ok(doctor);
        });

        group.MapPost("/", async (Doctor doctor, HospitalDbContext db) =>
        {
            doctor.CreatedAt = DateTime.UtcNow;
            db.Doctors.Add(doctor);
            await db.SaveChangesAsync();
            return Results.Created($"/api/doctors/{doctor.Id}", doctor);
        });

        group.MapPut("/{id}", async (int id, Doctor updated, HospitalDbContext db) =>
        {
            var doctor = await db.Doctors.FindAsync(id);
            if (doctor is null) return Results.NotFound();
            doctor.FirstName = updated.FirstName;
            doctor.LastName = updated.LastName;
            doctor.Specialization = updated.Specialization;
            doctor.DepartmentId = updated.DepartmentId;
            doctor.Phone = updated.Phone;
            doctor.Email = updated.Email;
            doctor.Qualification = updated.Qualification;
            doctor.ExperienceYears = updated.ExperienceYears;
            doctor.Schedule = updated.Schedule;
            doctor.IsActive = updated.IsActive;
            await db.SaveChangesAsync();
            return Results.Ok(doctor);
        });

        group.MapDelete("/{id}", async (int id, HospitalDbContext db) =>
        {
            var doctor = await db.Doctors.FindAsync(id);
            if (doctor is null) return Results.NotFound();
            doctor.IsActive = false;
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        return app;
    }
}
