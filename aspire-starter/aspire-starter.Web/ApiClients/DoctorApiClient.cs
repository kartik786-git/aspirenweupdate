using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class DoctorApiClient(HttpClient http)
{
    public async Task<List<DoctorDto>> GetAllAsync() =>
        await http.GetFromJsonAsync<List<DoctorDto>>("/api/doctors") ?? [];

    public async Task<List<DoctorDto>> GetByDepartmentAsync(int deptId) =>
        await http.GetFromJsonAsync<List<DoctorDto>>($"/api/doctors/department/{deptId}") ?? [];

    public async Task<DoctorDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<DoctorDto>($"/api/doctors/{id}");

    public async Task<DoctorDto?> CreateAsync(DoctorDto doctor)
    {
        var response = await http.PostAsJsonAsync("/api/doctors", doctor);
        return await response.Content.ReadFromJsonAsync<DoctorDto>();
    }

    public async Task UpdateAsync(int id, DoctorDto doctor) =>
        await http.PutAsJsonAsync($"/api/doctors/{id}", doctor);

    public async Task DeleteAsync(int id) =>
        await http.DeleteAsync($"/api/doctors/{id}");
}
