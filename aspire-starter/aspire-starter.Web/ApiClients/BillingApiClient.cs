using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class BillingApiClient(HttpClient http)
{
    public async Task<List<BillingDto>> GetAllAsync(string? status = null)
    {
        var qs = !string.IsNullOrWhiteSpace(status) ? $"?status={Uri.EscapeDataString(status)}" : "";
        return await http.GetFromJsonAsync<List<BillingDto>>($"/api/billing{qs}") ?? [];
    }

    public async Task<List<BillingDto>> GetByPatientAsync(int patientId) =>
        await http.GetFromJsonAsync<List<BillingDto>>($"/api/billing/patient/{patientId}") ?? [];

    public async Task<BillingDto?> GetByIdAsync(int id) =>
        await http.GetFromJsonAsync<BillingDto>($"/api/billing/{id}");

    public async Task<BillingDto?> CreateAsync(BillingDto bill)
    {
        var response = await http.PostAsJsonAsync("/api/billing", bill);
        return await response.Content.ReadFromJsonAsync<BillingDto>();
    }

    public async Task PayAsync(int id, decimal amount) =>
        await http.PutAsJsonAsync($"/api/billing/{id}/pay?amount={amount}", new { });
}
