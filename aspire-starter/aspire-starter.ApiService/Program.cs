using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;
using aspire_starter.ApiService.Data;
using aspire_starter.ApiService.Endpoints;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

builder.Services.AddProblemDetails();
builder.Services.AddOpenApi();
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
});

var keycloakAuthority = builder.Configuration["Keycloak:Authority"] ?? "http://localhost:8082";
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = $"{keycloakAuthority}/realms/hospital-hms";
        options.RequireHttpsMetadata = false;
        // Retry Keycloak metadata fetch every 30s (default is 5 min) so if Keycloak
        // isn't fully ready when the API starts, the middleware self-heals quickly.
        options.RefreshInterval = TimeSpan.FromSeconds(30);
        options.RefreshOnIssuerKeyNotFound = true;
        options.TokenValidationParameters.ValidIssuer = $"{keycloakAuthority}/realms/hospital-hms";
        options.TokenValidationParameters.ValidateAudience = false;
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.WriteLine($"[JWT-ERROR] {context.Request.Path} | {context.Exception.GetType().Name}: {context.Exception.Message}");
                return Task.CompletedTask;
            }
        };
    });
builder.Services.AddAuthorization();

// Configure CORS for the Flutter mobile app — allow all origins in development
// so the Flutter web app (port 5160) and DevTunnel URLs can reach the API
builder.Services.AddCors(options =>
{
    options.AddPolicy("MobileApp", policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.AddSqlServerDbContext<HospitalDbContext>("hospitalDb");

var app = builder.Build();

app.UseExceptionHandler();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        options.WithTitle("HospiCare — Hospital Management API")
               .WithDefaultHttpClient(ScalarTarget.CSharp, ScalarClient.HttpClient);
    });
}

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<HospitalDbContext>();
    db.Database.Migrate();
}

// 🔄 Startup warmup: wait for Keycloak to be ready before accepting requests.
// This avoids the race where the first API call triggers JWT metadata fetch
// before Keycloak has finished starting up, causing a 5-minute window of 401s.
var keycloakMetadataUrl = $"{keycloakAuthority}/realms/hospital-hms/.well-known/openid-configuration";
using (var warmupClient = new HttpClient { Timeout = TimeSpan.FromSeconds(5) })
{
    for (var attempt = 1; attempt <= 15; attempt++)
    {
        try
        {
            var response = await warmupClient.GetAsync(keycloakMetadataUrl);
            if (response.IsSuccessStatusCode)
            {
                Console.WriteLine($"[AUTH-WARMUP] Keycloak ready (attempt {attempt})");
                break;
            }
        }
        catch
        {
            // Keycloak not ready yet
        }
        if (attempt < 15)
        {
            Console.WriteLine($"[AUTH-WARMUP] Waiting for Keycloak (attempt {attempt}/15)...");
            await Task.Delay(2000);
        }
    }
}

// 🔍 Debug logging: log every request + response with method, path, auth header, token length, and status
app.Use(async (context, next) =>
{
    var authHeader = context.Request.Headers.Authorization.FirstOrDefault();
    var tokenLen = authHeader is not null && authHeader.StartsWith("Bearer ")
        ? authHeader.Length - 7  // length of the actual token after "Bearer "
        : 0;
    var tokenPreview = authHeader is not null && authHeader.Length > 25
        ? authHeader[..25] + "..."
        : authHeader ?? "(none)";
    Console.WriteLine($"[AUTH-DEBUG-IN] {context.Request.Method} {context.Request.Path}{context.Request.QueryString} | Auth: {tokenPreview} | TokenLen: {tokenLen} | RemoteIP: {context.Connection.RemoteIpAddress?.ToString() ?? "(unknown)"}");
    
    await next();
    
    Console.WriteLine($"[AUTH-DEBUG-OUT] {context.Request.Method} {context.Request.Path} | Status: {context.Response.StatusCode}");
});

app.UseCors("MobileApp");

app.UseAuthentication();
app.UseAuthorization();

app.MapDefaultEndpoints();

app.MapDepartmentEndpoints();
app.MapPatientEndpoints();
app.MapDoctorEndpoints();
app.MapAppointmentEndpoints();
app.MapMedicalRecordEndpoints();
app.MapBillingEndpoints();
app.MapRoomEndpoints();
app.MapStaffEndpoints();
app.MapDashboardEndpoints();
app.MapMobileEndpoints();

app.Run();
