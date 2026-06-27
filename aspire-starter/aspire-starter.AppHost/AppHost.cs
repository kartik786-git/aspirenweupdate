var builder = DistributedApplication.CreateBuilder(args);

var sqlServer = builder.AddSqlServer("hospital-db")
    .WithDataVolume("hospital-data");
var hospitalDb = sqlServer.AddDatabase("hospitalDb");

const string keycloakUrl = "http://localhost:8082";

var keycloak = builder.AddContainer("keycloak", "quay.io/keycloak/keycloak:25.0")
    .WithEnvironment("KEYCLOAK_ADMIN", "admin")
    .WithEnvironment("KEYCLOAK_ADMIN_PASSWORD", "admin")
    .WithEnvironment("KC_HOSTNAME", "localhost")
    .WithHttpEndpoint(port: 8082, targetPort: 8080, name: "http")
    // No persistent volume in dev — each restart imports the realm fresh from hospital-realm.json.
    // A persistent volume can cause stale state where the realm name already exists but users/clients
    // are missing or corrupted, causing login to fail with "invalid credentials".
    // For production, use a persistent volume with an init script that provisions users via the Admin API.
    .WithBindMount("D:\\Project\\aspirenweupdate\\aspire-starter\\keycloak\\import", "/opt/keycloak/data/import")
    .WithArgs("start-dev", "--import-realm");

var apiService = builder.AddProject<Projects.aspire_starter_ApiService>("apiservice")
    .WithReference(hospitalDb)
    .WithEnvironment("Keycloak__Authority", keycloakUrl)
    .WaitFor(sqlServer)
    .WaitFor(keycloak);

// Expose the API via DevTunnel for external apps (e.g., mobile apps)
var apiTunnel = builder.AddDevTunnel("api-tunnel")
    .WithReference(apiService)
    .WaitFor(apiService)
    .WaitFor(keycloak)
    .WithAnonymousAccess();

// Flutter mobile app — runs as a web app during development
var flutterWeb = builder.AddExecutable("flutter-web", "flutter", Path.Combine("..", "flutter_app"))
    .WithArgs("run", "-d", "web-server", "--web-port", "5160", "--web-hostname", "0.0.0.0")
    .WithHttpEndpoint(port: 5160, targetPort: 5160, name: "http", isProxied: false)
    .WithExternalHttpEndpoints()
    .WithReference(apiService)
    .WaitFor(apiService)
    .WaitFor(keycloak);

// Flutter Android app — uncomment and provide a device id to run on Android
// Uses --dart-define to pass the API URL so the app can find the backend
var flutterAndroid = builder.AddExecutable("flutter-android", "flutter", Path.Combine("..", "flutter_app"))
    .WithArgs("run", "-d", "emulator-5554", "--dart-define=API_BASE_URL=http://10.0.2.2:5520")
    .WithReference(apiService)
    .WaitFor(apiService)
    .WaitFor(keycloak);

  // ── Flutter APK Build Resources ────────────────────────────────────
// These appear as resources in the Aspire dashboard. Trigger a build by
// clicking Start / Restart on the respective resource.
// Output APKs are written to:
//   flutter_app/build/app/outputs/flutter-apk/app-debug.apk
//   flutter_app/build/app/outputs/flutter-apk/app-release.apk

var flutterDebugApk = builder.AddExecutable("flutter-debug-apk", "flutter", Path.Combine("..", "flutter_app"))
    .WithArgs("build", "apk", "--debug");
    

var flutterReleaseApk = builder.AddExecutable("flutter-release-apk", "flutter", Path.Combine("..", "flutter_app"))
    .WithArgs("build", "apk", "--release");

builder.AddProject<Projects.aspire_starter_Web>("webfrontend")
    .WithExternalHttpEndpoints()
    .WithReference(apiService)
    .WithEnvironment("Keycloak__Authority", keycloakUrl)
    .WaitFor(apiService)
    .WaitFor(keycloak);

builder.Build().Run();
