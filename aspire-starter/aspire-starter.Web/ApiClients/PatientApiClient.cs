using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class PatientApiClient(HttpClient http)
{
    public async Task<List<PatientDto>> GetAllAsync() =>
        await http.GetFromJsonAsync<List<PatientDto>>("/api/patients") ?? [];

    public async Task<List<PatientDto>> SearchAsync(string query) =>
        await http.GetFromJsonAsync<List<PatientDto>>($"/api/patients/search?q={Uri.EscapeDataString(query)}") ?? [];

    public async Task<PatientDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<PatientDto>($"/api/patients/{id}");

    public async Task<PatientDto?> CreateAsync(PatientDto patient)
    {
        var response = await http.PostAsJsonAsync("/api/patients", patient);
        return await response.Content.ReadFromJsonAsync<PatientDto>();
    }

    public async Task UpdateAsync(int id, PatientDto patient) =>
        await http.PutAsJsonAsync($"/api/patients/{id}", patient);

    public async Task DeleteAsync(int id) =>
        await http.DeleteAsync($"/api/patients/{id}");
}
