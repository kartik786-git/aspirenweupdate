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
        options.TokenValidationParameters.ValidIssuer = $"{keycloakAuthority}/realms/hospital-hms";
        options.TokenValidationParameters.ValidateAudience = false;
    });
builder.Services.AddAuthorization();

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

app.Run();
