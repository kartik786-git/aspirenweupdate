using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class StaffApiClient(HttpClient http)
{
    public async Task<List<StaffDto>> GetAllAsync(string? role = null)
    {
        var qs = !string.IsNullOrWhiteSpace(role) ? $"?role={Uri.EscapeDataString(role)}" : "";
        return await http.GetFromJsonAsync<List<StaffDto>>($"/api/staff{qs}") ?? [];
    }

    public async Task<List<StaffDto>> GetByDepartmentAsync(int deptId) =>
        await http.GetFromJsonAsync<List<StaffDto>>($"/api/staff/department/{deptId}") ?? [];

    public async Task<StaffDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<StaffDto>($"/api/staff/{id}");

    public async Task<StaffDto?> CreateAsync(StaffDto staff)
    {
        var response = await http.PostAsJsonAsync("/api/staff", staff);
        return await response.Content.ReadFromJsonAsync<StaffDto>();
    }

    public async Task UpdateAsync(int id, StaffDto staff) =>
        await http.PutAsJsonAsync($"/api/staff/{id}", staff);

    public async Task DeleteAsync(int id) =>
        await http.DeleteAsync($"/api/staff/{id}");
}
