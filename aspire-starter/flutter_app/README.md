# 🏥 HospiCare — Flutter Mobile App

A full-featured **Hospital Management System** mobile application built with Flutter, connecting to a .NET Aspire backend with Keycloak authentication.

> **HospiCare** is part of the [ASP.NET Aspire Starter](https://learn.microsoft.com/en-us/dotnet/aspire/get-started/aspire-overview) hospital management demo. This Flutter app provides a responsive mobile-first interface for managing patients, doctors, appointments, billing, rooms, staff, and more.

---

## ✨ Features

| Module | Screens | Capabilities |
|---------|---------|--------------|
| **Dashboard** | Dashboard | Animated stats cards, bed occupancy chart, quick actions, pull-to-refresh |
| **Patients** | List + Form | Search, register/edit, archive, emergency contact info |
| **Doctors** | List + Form | Department filter chips, add/edit, deactivate, specialization tracking |
| **Appointments** | List + Form | Date & status filters, book, cancel, complete appointments |
| **Departments** | List + Form | Department icons, add/edit, head doctor assignment |
| **Medical Records** | List + Form | Patient selector, diagnosis/treatment/prescription management |
| **Billing** | List | Status filter (Paid/Unpaid/Partial), mark as paid (Cash/Card/Insurance/Online) |
| **Rooms** | List | Ward filters, admit patient, discharge |
| **Staff** | List + Form | Role filter chips, add/edit, deactivate |

### Authentication
- Keycloak **Resource Owner Password Credentials (ROPC)** flow
- JWT token storage with `SharedPreferences`
- Automatic token refresh on expiry
- Session persistence across app restarts
- Graceful logout on token failure

### UI Highlights
- **Material 3** design system with custom blue color scheme
- **Responsive layout** — sidebar navigation on web, bottom nav + drawer on mobile
- Fade-in animations on dashboard load
- Gradient hero headers, stat cards with colored icons
- Pull-to-refresh on all list screens
- Dark and light mode ready

---

## 📱 Screenshots

| Web (Sidebar) | Mobile (Bottom Nav) | Dashboard |
|:---:|:---:|:---:|
| Sidebar with all 9 modules, user profile, and sign out | Gradient AppBar, NavigationBar, and Drawer | Animated stats, occupancy bar, quick actions |

> *(Add actual screenshots by placing them in a `screenshots/` directory)*

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | >= 3.10.8 | Cross-platform framework |
| [Dart SDK](https://dart.dev/get-dart) | ^3.10.8 | Language runtime |
| [.NET SDK](https://dotnet.microsoft.com/download) | >= 9.0 | Aspire backend |
| [Keycloak](https://www.keycloak.org/) | 26+ | Authentication server |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Any | SQL Server + Keycloak containers |
| [Aspire CLI](https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/setup-tooling) | 13.4+ | Orchestration & dashboard |

### 1. Clone & Install Dependencies

```bash
# Navigate to the project root (above flutter_app/)
cd aspire-starter

# Run the full backend + Flutter app via Aspire
dotnet run --project aspire-starter.AppHost
```

Or install Flutter dependencies manually:

```bash
cd flutter_app
flutter pub get
```

### 2. Start Backend Services

The Aspire AppHost orchestrates everything:

- **SQL Server** (Docker container with hospital database)
- **Keycloak** (Docker container with pre-configured realm)
- **API Service** (.NET Web API with JWT auth)
- **Flutter Web** (Dev server on port 5160)
- **Flutter APK build targets** (manual trigger only — see section below)

Run from the `aspire-starter/` directory:

```bash
dotnet run --project aspire-starter.AppHost
```

The Aspire dashboard opens at `http://localhost:1519` (or the configured port).

### 3. Login Credentials

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin123` | Administrator |
| `dr.smith` | `doctor123` | Doctor |

---

## 📂 Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                      # App entry, theme, AuthGate
│   ├── models/                        # Data models (DTOs)
│   │   ├── user_info.dart             # JWT-decoded user info + AuthState enum
│   │   ├── patient.dart
│   │   ├── doctor.dart
│   │   ├── appointment.dart
│   │   ├── department.dart
│   │   ├── medical_record.dart
│   │   ├── billing.dart
│   │   ├── room.dart
│   │   ├── staff.dart
│   │   └── dashboard_summary.dart
│   ├── screens/                       # All UI screens
│   │   ├── login_screen.dart          # Keycloak login form
│   │   ├── home_screen.dart           # Responsive shell (sidebar/bottom nav)
│   │   ├── dashboard_screen.dart      # Animated stats dashboard
│   │   ├── patients_list_screen.dart
│   │   ├── patient_form_screen.dart
│   │   ├── doctors_list_screen.dart
│   │   ├── doctor_form_screen.dart
│   │   ├── appointments_list_screen.dart
│   │   ├── appointment_form_screen.dart
│   │   ├── departments_list_screen.dart
│   │   ├── department_form_screen.dart
│   │   ├── medical_records_list_screen.dart
│   │   ├── medical_record_form_screen.dart
│   │   ├── billing_list_screen.dart
│   │   ├── rooms_list_screen.dart
│   │   ├── staff_list_screen.dart
│   │   └── staff_form_screen.dart
│   ├── services/                      # API and auth clients
│   │   ├── api_service.dart           # All REST API calls
│   │   └── auth_service.dart          # Keycloak ROPC auth flow
│   └── widgets/                       # Reusable widgets
│       └── stat_card.dart             # Dashboard stat card component
├── test/                              # Unit & widget tests
├── pubspec.yaml                       # Flutter dependencies
└── analysis_options.yaml              # Dart lint rules
```

---

## 🧩 Architecture

### Authentication Flow

```
┌─────────┐     ┌──────────┐     ┌──────────┐
│  Flutter │────▶│ Keycloak │────▶│   JWT    │
│   App    │◀────│  Server  │◀────│  Token   │
└─────────┘     └──────────┘     └──────────┘
     │                                  │
     │         ┌──────────┐            │
     └────────▶│  .NET    │◀───────────┘
               │ Web API  │  Bearer Token
               └──────────┘
```

1. User enters username/password on the login screen
2. `AuthService` sends ROPC request to Keycloak's token endpoint
3. Keycloak returns an access token + refresh token
4. Tokens are stored in `SharedPreferences` (not FlutterSecureStorage — see [Token Storage](#token-storage) note)
5. `ApiService` attaches the Bearer token to every API request
6. If a 401 is received, `AuthService` attempts a token refresh
7. If refresh fails, the user is logged out and redirected to the login screen

### Token Storage

The app uses `SharedPreferences` (plaintext) rather than `FlutterSecureStorage` because:
- JWT access tokens are ~1000+ characters
- On Android, `FlutterSecureStorage`'s Keystore encryption can corrupt long strings when read back
- `SharedPreferences` is safe for a mobile client token — the access token is short-lived (typically 5-15 minutes)

### State Management

The app uses **`setState`** + **`FutureBuilder`** for simplicity:
- No external state management library (Provider, Riverpod, Bloc, etc.)
- Each screen manages its own loading/error/data state
- `AuthGate` uses `StreamBuilder` to react to auth state changes
- `IndexedStack` preserves child widget state across tab switches

### Responsive Layout

The `HomeScreen` adapts based on screen width (breakpoint: 900px):

**Web / Wide (≥ 900px):**
- Fixed 200px sidebar with logo header, navigation list, and user info/sign out at bottom
- Main content area with white AppBar
- All 9 modules visible in the sidebar

**Mobile / Narrow (< 900px):**
- Gradient blue AppBar with hamburger menu
- Bottom NavigationBar with 5 primary destinations (Dashboard, Patients, Doctors, Appointments, More)
- Drawer with all 9 modules accessible via hamburger or "More" button

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [flutter](https://flutter.dev/) | SDK | UI framework |
| [http](https://pub.dev/packages/http) | ^1.6.0 | REST API client |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.3.0 | JWT token persistence |
| [cupertino_icons](https://pub.dev/packages/cupertino_icons) | ^1.0.8 | iOS-style icons |
| [flutter_lints](https://pub.dev/packages/flutter_lints) | ^6.0.0 | Lint rules (dev) |

---

## 🔨 Building APKs

### From Aspire Dashboard (Recommended)

The Aspire AppHost includes two build resources that appear in the dashboard:

| Resource Name | Command | Output |
|---------------|---------|--------|
| `flutter-debug-apk` | `flutter build apk --debug` | `build/app/outputs/flutter-apk/app-debug.apk` |
| `flutter-release-apk` | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |

**How to trigger:**
1. Start the AppHost: `dotnet run --project aspire-starter.AppHost`
2. Open the Aspire dashboard (default: `http://localhost:1519`)
3. Find `flutter-debug-apk` or `flutter-release-apk` in the resource list
4. Click **Start** on the resource to trigger the build
5. Build logs stream live in the dashboard

> These resources are **stopped by default** and **never auto-trigger** — they only run when you explicitly start them.

### From CLI (Direct)

```bash
cd flutter_app

# Debug APK
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Release APK (requires keystore setup)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Running on Android Emulator

```bash
cd flutter_app
flutter run

# Or target a specific device
flutter devices
flutter run -d <device_id>
```

### Running on Web

```bash
cd flutter_app
flutter run -d web-server --web-port 5160 --web-hostname 0.0.0.0
```

---

## 🔐 API Endpoints

The Flutter app communicates with the backend through these endpoints (base URL: `http://localhost:5520` or `http://10.0.2.2:5520` on Android emulator):

### Mobile
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/mobile/summary` | Dashboard analytics |

### Patients
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/patients` | List all patients |
| GET | `/api/patients/search?q={query}` | Search patients |
| GET | `/api/patients/{id}` | Get patient by ID |
| POST | `/api/patients` | Create patient |
| PUT | `/api/patients/{id}` | Update patient |
| DELETE | `/api/patients/{id}` | Delete/archive patient |

### Doctors
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/doctors` | List all doctors |
| GET | `/api/doctors/department/{id}` | Filter by department |
| GET | `/api/doctors/{id}` | Get doctor by ID |
| POST | `/api/doctors` | Create doctor |
| PUT | `/api/doctors/{id}` | Update doctor |
| DELETE | `/api/doctors/{id}` | Delete doctor |

### Appointments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/appointments` | List (with date/status query params) |
| GET | `/api/appointments/{id}` | Get appointment |
| POST | `/api/appointments` | Create appointment |
| PUT | `/api/appointments/{id}/cancel` | Cancel appointment |
| PUT | `/api/appointments/{id}/complete` | Complete appointment |

### Departments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/departments` | List departments |
| GET | `/api/departments/{id}` | Get department |
| POST | `/api/departments` | Create department |
| PUT | `/api/departments/{id}` | Update department |

### Medical Records
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/medical-records/patient/{patientId}` | List records for patient |
| POST | `/api/medical-records` | Create record |

### Billing
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/billing` | List all bills |
| GET | `/api/billing/patient/{patientId}` | List bills for patient |
| PUT | `/api/billing/{id}/pay?amount={amount}` | Mark bill as paid |

### Rooms
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/rooms` | List all rooms |
| PUT | `/api/rooms/{id}/assign?patientId={id}` | Admit patient |
| PUT | `/api/rooms/{id}/discharge` | Discharge patient |

### Staff
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/staff` | List all staff |
| POST | `/api/staff` | Create staff |
| PUT | `/api/staff/{id}` | Update staff |
| DELETE | `/api/staff/{id}` | Delete staff |

---

## 🔧 Configuration

### API Base URL

The API base URL is determined automatically in `ApiService`:

```dart
// Android emulator → uses host machine's localhost
if (Android) → http://10.0.2.2:5520

// Web / iOS / Desktop → uses localhost directly
if (Web / iOS / Desktop) → http://localhost:5520

// Aspire environment variable override
if (services__apiservice__http__0) → uses that URL

// Custom environment variable
if (API_BASE_URL) → uses that URL
```

### Keycloak Configuration

Configured in `AuthService`:

| Setting | Value |
|---------|-------|
| Keycloak URL | `http://localhost:8082` |
| Realm | `hospital-hms` |
| Client ID | `hospital-mobile` |
| Grant Type | `password` (ROPC) |

---

## 🧪 Testing

```bash
cd flutter_app

# Analyze code for errors/warnings
flutter analyze

# Run unit and widget tests
flutter test

# Check for outdated dependencies
flutter pub outdated
```

### Code Quality

The project uses `flutter_lints` with the recommended lint rules. Run analysis frequently:

```bash
flutter analyze
```

Expected output: **0 errors, 0 warnings**

---

## 📋 Requirements

- **Flutter SDK** ≥ 3.10.8
- **Dart SDK** ^3.10.8
- **Backend**: .NET Aspire project with hospital API running
- **Keycloak**: Pre-configured realm with `hospital-hms` and `hospital-mobile` client
- **Database**: SQL Server with the hospital schema (migrations run automatically)

---

## 🐳 Docker Services

The Aspire AppHost manages these Docker containers:

| Service | Port | Purpose |
|---------|------|---------|
| SQL Server | 1433 | Hospital database |
| Keycloak | 8082 | Authentication server |

---

## 🗺️ Roadmap

- [ ] Offline support with local caching
- [ ] Push notifications for appointment reminders
- [ ] Dark mode toggle
- [ ] File/image upload for medical records
- [ ] Multi-language support (i18n)
- [ ] iOS deployment (Xcode project setup)
- [ ] End-to-end tests with integration testing

---

## 🛠️ Troubleshooting

### "Could not connect to server"
- Ensure the Aspire AppHost is running: `dotnet run --project aspire-starter.AppHost`
- Check that Keycloak is accessible at `http://localhost:8082`
- For Android emulator, the app automatically uses `10.0.2.2` instead of `localhost`

### Token expired / Login loop
- The app automatically refreshes tokens in the background
- If refresh fails (e.g., Keycloak restarted), the app logs out gracefully
- Simply log in again with your credentials

### Flutter analyze errors
```bash
# Clean and re-fetch dependencies
flutter clean
flutter pub get
flutter analyze
```

### APK build fails
```bash
# Check Flutter doctor
flutter doctor -v

# Clean build cache
flutter clean
flutter build apk --debug
```

---

## 📄 License

This project is part of the ASP.NET Aspire Starter demo. Licensed under the MIT License.

---

## 👥 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -am 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Submit a pull request

---

*Built with [Flutter](https://flutter.dev/) + [.NET Aspire](https://learn.microsoft.com/en-us/dotnet/aspire/get-started/aspire-overview) + [Keycloak](https://www.keycloak.org/)*
