using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class DepartmentEndpoints
{
    public static WebApplication MapDepartmentEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/departments").WithOpenApi().RequireAuthorization();

        group.MapGet("/", async (HospitalDbContext db) =>
            await db.Departments.Include(d => d.HeadDoctor).ToListAsync());

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var dept = await db.Departments.Include(d => d.HeadDoctor).FirstOrDefaultAsync(d => d.Id == id);
            return dept is null ? Results.NotFound() : Results.Ok(dept);
        });

        group.MapPost("/", async (Department department, HospitalDbContext db) =>
        {
            department.CreatedAt = DateTime.UtcNow;
            db.Departments.Add(department);
            await db.SaveChangesAsync();
            return Results.Created($"/api/departments/{department.Id}", department);
        });

        group.MapPut("/{id}", async (int id, Department updated, HospitalDbContext db) =>
        {
            var dept = await db.Departments.FindAsync(id);
            if (dept is null) return Results.NotFound();
            dept.Name = updated.Name;
            dept.Description = updated.Description;
            dept.Location = updated.Location;
            dept.HeadDoctorId = updated.HeadDoctorId;
            await db.SaveChangesAsync();
            return Results.Ok(dept);
        });

        group.MapDelete("/{id}", async (int id, HospitalDbContext db) =>
        {
            var dept = await db.Departments.FindAsync(id);
            if (dept is null) return Results.NotFound();
            db.Departments.Remove(dept);
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        return app;
    }
}
