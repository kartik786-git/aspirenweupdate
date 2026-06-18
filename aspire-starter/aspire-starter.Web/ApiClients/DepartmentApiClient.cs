using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class DepartmentApiClient(HttpClient http)
{
    public async Task<List<DepartmentDto>> GetAllAsync() =>
        await http.GetFromJsonAsync<List<DepartmentDto>>("/api/departments") ?? [];

    public async Task<DepartmentDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<DepartmentDto>($"/api/departments/{id}");

    public async Task<DepartmentDto?> CreateAsync(DepartmentDto dept)
    {
        var response = await http.PostAsJsonAsync("/api/departments", dept);
        return await response.Content.ReadFromJsonAsync<DepartmentDto>();
    }

    public async Task UpdateAsync(int id, DepartmentDto dept) =>
        await http.PutAsJsonAsync($"/api/departments/{id}", dept);

    public async Task DeleteAsync(int id) =>
        await http.DeleteAsync($"/api/departments/{id}");
}
