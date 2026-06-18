var builder = DistributedApplication.CreateBuilder(args);

var sqlServer = builder.AddSqlServer("hospital-db")
    .WithDataVolume("hospital-data");
var hospitalDb = sqlServer.AddDatabase("hospitalDb");

const string keycloakUrl = "http://localhost:8082";

var keycloak = builder.AddContainer("keycloak", "quay.io/keycloak/keycloak:25.0")
    .WithEnvironment("KEYCLOAK_ADMIN", "admin")
    .WithEnvironment("KEYCLOAK_ADMIN_PASSWORD", "admin")
    .WithHttpEndpoint(port: 8082, targetPort: 8080, name: "http")
    .WithVolume("keycloak-data", "/opt/keycloak/data")
    .WithBindMount("D:\\Project\\aspirenweupdate\\aspire-starter\\keycloak\\import", "/opt/keycloak/data/import")
    .WithArgs("start-dev", "--import-realm");

var apiService = builder.AddProject<Projects.aspire_starter_ApiService>("apiservice")
    .WithReference(hospitalDb)
    .WithEnvironment("Keycloak__Authority", keycloakUrl)
    .WaitFor(sqlServer)
    .WaitFor(keycloak);

builder.AddProject<Projects.aspire_starter_Web>("webfrontend")
    .WithExternalHttpEndpoints()
    .WithReference(apiService)
    .WithEnvironment("Keycloak__Authority", keycloakUrl)
    .WaitFor(apiService)
    .WaitFor(keycloak);

builder.Build().Run();
