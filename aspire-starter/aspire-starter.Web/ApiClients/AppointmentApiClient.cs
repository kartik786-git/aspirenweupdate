using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class AppointmentApiClient(HttpClient http)
{
    public async Task<List<AppointmentDto>> GetAllAsync(DateTime? date = null, string? status = null)
    {
        var query = new List<string>();
        if (date.HasValue) query.Add($"date={date.Value:yyyy-MM-dd}");
        if (!string.IsNullOrWhiteSpace(status)) query.Add($"status={Uri.EscapeDataString(status)}");
        var qs = query.Count > 0 ? "?" + string.Join("&", query) : "";
        return await http.GetFromJsonAsync<List<AppointmentDto>>($"/api/appointments{qs}") ?? [];
    }

    public async Task<List<AppointmentDto>> GetByPatientAsync(int patientId) =>
        await http.GetFromJsonAsync<List<AppointmentDto>>($"/api/appointments/patient/{patientId}") ?? [];

    public async Task<List<AppointmentDto>> GetByDoctorAndDateAsync(int doctorId, DateOnly date) =>
        await http.GetFromJsonAsync<List<AppointmentDto>>($"/api/appointments/doctor/{doctorId}/date/{date:yyyy-MM-dd}") ?? [];

    public async Task<AppointmentDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<AppointmentDto>($"/api/appointments/{id}");

    public async Task<AppointmentDto?> CreateAsync(AppointmentDto appointment)
    {
        var response = await http.PostAsJsonAsync("/api/appointments", appointment);
        if (!response.IsSuccessStatusCode) return null;
        return await response.Content.ReadFromJsonAsync<AppointmentDto>();
    }

    public async Task CancelAsync(int id) =>
        await http.PutAsJsonAsync($"/api/appointments/{id}/cancel", new { });

    public async Task CompleteAsync(int id) =>
        await http.PutAsJsonAsync($"/api/appointments/{id}/complete", new { });
}
