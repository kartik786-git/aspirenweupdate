using System.Net.Http.Json;
using aspire_starter.Web.Models;

namespace aspire_starter.Web.ApiClients;

public class DashboardApiClient(HttpClient http)
{
    public async Task<DashboardSummaryDto?> GetSummaryAsync() =>
        await http.GetFromJsonAsync<DashboardSummaryDto>("/api/dashboard/summary");
}
