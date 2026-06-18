using Microsoft.EntityFrameworkCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Models;

namespace aspire_starter.ApiService.Endpoints;

public static class RoomEndpoints
{
    public static WebApplication MapRoomEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/rooms").WithOpenApi().RequireAuthorization();

        group.MapGet("/", async (HospitalDbContext db) =>
            await db.Rooms.Include(r => r.Department).Include(r => r.CurrentPatient).ToListAsync());

        group.MapGet("/available", async (HospitalDbContext db) =>
            await db.Rooms.Where(r => !r.IsOccupied).Include(r => r.Department).ToListAsync());

        group.MapGet("/{id}", async (int id, HospitalDbContext db) =>
        {
            var room = await db.Rooms.Include(r => r.Department).Include(r => r.CurrentPatient).FirstOrDefaultAsync(r => r.Id == id);
            return room is null ? Results.NotFound() : Results.Ok(room);
        });

        group.MapPost("/", async (Room room, HospitalDbContext db) =>
        {
            db.Rooms.Add(room);
            await db.SaveChangesAsync();
            return Results.Created($"/api/rooms/{room.Id}", room);
        });

        group.MapPut("/{id}/assign", async (int id, int patientId, HospitalDbContext db) =>
        {
            var room = await db.Rooms.FindAsync(id);
            if (room is null) return Results.NotFound();
            if (room.IsOccupied) return Results.Conflict(new { message = "Room is already occupied" });
            room.IsOccupied = true;
            room.CurrentPatientId = patientId;
            room.AdmissionDate = DateTime.UtcNow;
            await db.SaveChangesAsync();
            return Results.Ok(room);
        });

        group.MapPut("/{id}/discharge", async (int id, HospitalDbContext db) =>
        {
            var room = await db.Rooms.FindAsync(id);
            if (room is null) return Results.NotFound();
            room.IsOccupied = false;
            room.CurrentPatientId = null;
            room.AdmissionDate = null;
            await db.SaveChangesAsync();
            return Results.Ok(room);
        });

        return app;
    }
}
