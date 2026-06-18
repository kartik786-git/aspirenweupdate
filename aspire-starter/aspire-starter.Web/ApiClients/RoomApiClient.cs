using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class RoomApiClient(HttpClient http)
{
    public async Task<List<RoomDto>> GetAllAsync() =>
        await http.GetFromJsonAsync<List<RoomDto>>("/api/rooms") ?? [];

    public async Task<List<RoomDto>> GetAvailableAsync() =>
        await http.GetFromJsonAsync<List<RoomDto>>("/api/rooms/available") ?? [];

    public async Task<RoomDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<RoomDto>($"/api/rooms/{id}");

    public async Task AssignAsync(int roomId, int patientId) =>
        await http.PutAsJsonAsync($"/api/rooms/{roomId}/assign?patientId={patientId}", new { });

    public async Task DischargeAsync(int roomId) =>
        await http.PutAsJsonAsync($"/api/rooms/{roomId}/discharge", new { });
}
