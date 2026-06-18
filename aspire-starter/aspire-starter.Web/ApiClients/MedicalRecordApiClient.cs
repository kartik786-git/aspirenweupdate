using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class MedicalRecordApiClient(HttpClient http)
{
    public async Task<List<MedicalRecordDto>> GetByPatientAsync(int patientId) =>
        await http.GetFromJsonAsync<List<MedicalRecordDto>>($"/api/medical-records/patient/{patientId}") ?? [];

    public async Task<MedicalRecordDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<MedicalRecordDto>($"/api/medical-records/{id}");

    public async Task<MedicalRecordDto?> CreateAsync(MedicalRecordDto record)
    {
        var response = await http.PostAsJsonAsync("/api/medical-records", record);
        return await response.Content.ReadFromJsonAsync<MedicalRecordDto>();
    }

    public async Task UpdateAsync(int id, MedicalRecordDto record) =>
        await http.PutAsJsonAsync($"/api/medical-records/{id}", record);
}
