using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class StaffEndpoints
{
    public static WebApplication MapStaffEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/staff").WithOpenApi().RequireAuthorization();

        group.MapGet("/", async (string? role, HospitalDbContext db) =>
        {
            var query = db.Staff.Include(s => s.Department).AsQueryable();
            if (!string.IsNullOrWhiteSpace(role))
                query = query.Where(s => s.Role == role);
            return await query.ToListAsync();
        });

        group.MapGet("/department/{deptId}", async (int deptId, HospitalDbContext db) =>
            await db.Staff.Where(s => s.DepartmentId == deptId).Include(s => s.Department).ToListAsync());

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var staff = await db.Staff.Include(s => s.Department).FirstOrDefaultAsync(s => s.Id == id);
            return staff is null ? Results.NotFound() : Results.Ok(staff);
        });

        group.MapPost("/", async (Staff staff, HospitalDbContext db) =>
        {
            staff.HireDate = DateTime.UtcNow;
            db.Staff.Add(staff);
            await db.SaveChangesAsync();
            return Results.Created($"/api/staff/{staff.Id}", staff);
        });

        group.MapPut("/{id}", async (int id, Staff updated, HospitalDbContext db) =>
        {
            var staff = await db.Staff.FindAsync(id);
            if (staff is null) return Results.NotFound();
            staff.FirstName = updated.FirstName;
            staff.LastName = updated.LastName;
            staff.Role = updated.Role;
            staff.DepartmentId = updated.DepartmentId;
            staff.Phone = updated.Phone;
            staff.Email = updated.Email;
            staff.Salary = updated.Salary;
            staff.IsActive = updated.IsActive;
            await db.SaveChangesAsync();
            return Results.Ok(staff);
        });

        group.MapDelete("/{id}", async (int id, HospitalDbContext db) =>
        {
            var staff = await db.Staff.FindAsync(id);
            if (staff is null) return Results.NotFound();
            staff.IsActive = false;
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        return app;
    }
}
