using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using aspire_starter.Web;
using aspire_starter.Web.Components;
using aspire_starter.Web.ApiClients;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

var keycloakAuthority = builder.Configuration["Keycloak:Authority"] ?? "http://localhost:8082";

builder.Services.AddAuthentication(options =>
    {
        options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
    })
    .AddCookie(options =>
    {
        options.Cookie.Name = "hospital-auth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
    })
    .AddOpenIdConnect(options =>
    {
        options.Authority = $"{keycloakAuthority}/realms/hospital-hms";
        options.ClientId = "hospital-web";
        options.ResponseType = "code";
        options.CallbackPath = "/signin-oidc";
        options.SignedOutCallbackPath = "/signout-callback-oidc";
        options.SaveTokens = true;
        options.GetClaimsFromUserInfoEndpoint = true;
        options.Scope.Add("openid");
        options.Scope.Add("profile");
        options.Scope.Add("roles");
        options.RequireHttpsMetadata = false;
    });
builder.Services.AddAuthorization();
builder.Services.AddHttpContextAccessor();
builder.Services.AddCascadingAuthenticationState();

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddOutputCache();

builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<AuthEventService>();
builder.Services.AddTransient<TokenHandler>();

builder.Services.AddHttpClient<WeatherApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<DashboardApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<PatientApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<DoctorApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<DepartmentApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<AppointmentApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<MedicalRecordApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<BillingApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<RoomApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();
builder.Services.AddHttpClient<StaffApiClient>(client =>
    {
        client.BaseAddress = new("https+http://apiservice");
    }).AddHttpMessageHandler<TokenHandler>();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.UseAntiforgery();
app.UseOutputCache();
app.MapStaticAssets();

app.MapGroup("/auth").MapLoginAndLogout();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.MapDefaultEndpoints();

app.Run();

public class TokenService
{
    public string? AccessToken { get; set; }
    public string? RefreshToken { get; set; }
}

/// Scoped service shared by TokenHandler and MainLayout.
/// TokenHandler sets <see cref="ReauthenticationRequired"/> to true when the
/// API returns a 401 and token refresh fails. MainLayout reads the flag at
/// render time to show a global "Session Expired" overlay over any page.
public class AuthEventService
{
    public bool ReauthenticationRequired { get; set; }
}

public class TokenHandler(
    IHttpContextAccessor httpContextAccessor,
    TokenService tokenService,
    IConfiguration configuration,
    AuthEventService authEventService) : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await GetValidAccessTokenAsync(cancellationToken);

        if (!string.IsNullOrEmpty(token))
        {
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        }

        var response = await base.SendAsync(request, cancellationToken);

        // If the API rejected the token, set the global auth-error flag.
        // MainLayout reads this flag at render time and shows a "Session Expired"
        // overlay over any page content.
        if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
        {
            authEventService.ReauthenticationRequired = true;
        }

        return response;
    }

    private async Task<string?> GetValidAccessTokenAsync(CancellationToken cancellationToken)
    {
        string? accessToken;
        string? refreshToken;

        var httpContext = httpContextAccessor.HttpContext;

        if (httpContext is not null)
        {
            // Prerendering — get tokens from auth cookie
            accessToken = await httpContext.GetTokenAsync("access_token");
            refreshToken = await httpContext.GetTokenAsync("refresh_token");
        }
        else
        {
            // SignalR circuit — get tokens from TokenService
            accessToken = tokenService.AccessToken;
            refreshToken = tokenService.RefreshToken;
        }

        if (string.IsNullOrEmpty(accessToken))
            return null;

        // Return immediately if the token is still valid
        if (!IsTokenExpired(accessToken))
            return accessToken;

        // Token is expired — try to refresh with the stored refresh token
        if (string.IsNullOrEmpty(refreshToken))
            return null;

        var authority = configuration["Keycloak:Authority"] ?? "http://localhost:8082";
        var tokenEndpoint = $"{authority}/realms/hospital-hms/protocol/openid-connect/token";

        try
        {
            using var client = new HttpClient { Timeout = TimeSpan.FromSeconds(10) };
            var body = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["client_id"] = "hospital-web",
                ["grant_type"] = "refresh_token",
                ["refresh_token"] = refreshToken,
            });

            var response = await client.PostAsync(tokenEndpoint, body, cancellationToken);
            if (!response.IsSuccessStatusCode)
                return null;

            var json = await response.Content.ReadFromJsonAsync<Dictionary<string, JsonElement>>(
                cancellationToken: cancellationToken);
            if (json is null) return null;

            var newAccessToken = json.TryGetValue("access_token", out var atEl) ? atEl.GetString() : null;
            var newRefreshToken = json.TryGetValue("refresh_token", out var rtEl) ? rtEl.GetString() : null;

            if (string.IsNullOrEmpty(newAccessToken)) return null;

            // Update TokenService (used by both prerendering and SignalR circuit)
            tokenService.AccessToken = newAccessToken;
            if (newRefreshToken is not null)
                tokenService.RefreshToken = newRefreshToken;

            // If HttpContext is available, also update the auth cookie
            if (httpContext is not null)
            {
                var authResult = await httpContext.AuthenticateAsync();
                if (authResult.Succeeded && authResult.Properties is not null)
                {
                    authResult.Properties.UpdateTokenValue("access_token", newAccessToken);
                    if (newRefreshToken is not null)
                        authResult.Properties.UpdateTokenValue("refresh_token", newRefreshToken);

                    await httpContext.SignInAsync(authResult.Principal!, authResult.Properties);
                }
            }

            return newAccessToken;
        }
        catch
        {
            return null;
        }
    }

    private static bool IsTokenExpired(string token, int bufferSeconds = 60)
    {
        try
        {
            var parts = token.Split('.');
            if (parts.Length < 2) return true;

            var payload = parts[1];
            var padding = 4 - payload.Length % 4;
            if (padding != 4)
                payload += new string('=', padding);

            var decoded = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(payload));
            using var doc = JsonDocument.Parse(decoded);
            if (!doc.RootElement.TryGetProperty("exp", out var expElement))
                return true;

            var exp = expElement.GetInt64();
            var now = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            return now >= exp - bufferSeconds;
        }
        catch
        {
            return true; // Assume expired if we can't decode
        }
    }
}

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapLoginAndLogout(this IEndpointRouteBuilder group)
    {
        group.MapGet("/login", async (HttpContext httpContext, string? returnUrl) =>
        {
            await httpContext.ChallengeAsync(new AuthenticationProperties
            {
                RedirectUri = returnUrl ?? "/"
            });
        });

        group.MapGet("/logout", async (HttpContext httpContext, string? returnUrl) =>
        {
            await httpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            await httpContext.SignOutAsync(OpenIdConnectDefaults.AuthenticationScheme, new AuthenticationProperties
            {
                RedirectUri = "/auth/login?returnUrl=" + Uri.EscapeDataString(returnUrl ?? "/")
            });
        });

        /// Force re-authentication: clear the stale cookie and immediately challenge
        /// for a fresh login. Used when the access token is expired and can't be refreshed.
        group.MapGet("/reauth", async (HttpContext httpContext, string? returnUrl) =>
        {
            await httpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            await httpContext.SignOutAsync(OpenIdConnectDefaults.AuthenticationScheme);
            await httpContext.ChallengeAsync(new AuthenticationProperties
            {
                RedirectUri = returnUrl ?? "/"
            });
        });

        return group;
    }
}
