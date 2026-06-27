# 🏥 HospiCare — Hospital Management System

A comprehensive, modern hospital management system built with **.NET Aspire 13.4**, **Blazor Interactive Server**, **Flutter Mobile App**, **Keycloak authentication**, and **SQL Server**.

---

## 📋 Overview

HospiCare is a full-stack hospital management application that provides a unified dashboard for managing patients, doctors, appointments, medical records, billing, rooms/beds, departments, and staff. It leverages .NET Aspire for cloud-native orchestration, service discovery, and observability — with **two frontends**: a **Blazor Web App** (desktop/server) and a **Flutter Mobile App** (Android/Web).

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     .NET Aspire AppHost                              │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  ┌───────────┐│
│  │  Keycloak    │  │  API Service │  │  Web App   │  │  Flutter  ││
│  │  (Port 8082) │  │  (Backend)   │  │  (Blazor)  │  │  Mobile   ││
│  │  Auth Server │◄─┤  REST APIs   │◄─┤  Frontend  │  │  (Android)││
│  └──────────────┘  └──┬───────────┘  └────────────┘  └───────────┘│
│                       │                              ┌───────────┐│
│              ┌────────▼────────┐                     │  Flutter  ││
│              │   SQL Server    │                     │   Web     ││
│              │  (hospital-db)  │                     │  (Port    ││
│              └─────────────────┘                     │   5160)   ││
└──────────────────────────────────────────────────────┴───────────┘
```

### Projects

| Project | Description | Framework |
|---------|-------------|-----------|
| **AppHost** | Aspire orchestration — manages containers, service discovery, and startup ordering | .NET 10 |
| **ApiService** | REST API — handles all business logic and data access | .NET 10 |
| **Web** | Blazor Interactive Server UI — modern responsive frontend | .NET 10 |
| **ServiceDefaults** | Shared Aspire defaults — OpenTelemetry, health checks, resilience | .NET 10 |
| **Flutter App** | Cross-platform mobile app for Android and Web | Flutter 3.10+ |

---

## ✨ Features

### Clinical Management
- **Patient Management** — Register, search, edit, and view patient details with full medical history
- **Doctor Directory** — Manage doctors with specializations, departments, qualifications, and schedules
- **Appointments** — Book, complete, cancel, and filter appointments by date/status
- **Medical Records** — Create and view diagnosis, treatment, and prescription records per patient

### Administrative
- **Department Management** — Add/delete departments with locations and heads
- **Room & Bed Management** — Track bed occupancy, assign/discharge patients, view daily rates
- **Staff Directory** — Manage nurses, receptionists, admins, and technicians by role/department
- **Billing & Invoices** — Generate invoices, track payments, filter by payment status

### Dashboard & Analytics
- **Real-time dashboard** with total patients, active doctors, today's appointments, monthly revenue
- **Bed occupancy** tracking with progress bars
- **Quick actions** for common tasks

### Authentication & Security
- **Keycloak SSO** — Secure authentication with OpenID Connect / OAuth 2.0
- **Role-based access** — Admin, Doctor, Nurse, Receptionist roles
- **JWT Bearer tokens** for API authorization
- **Token propagation** from Blazor to API via `TokenHandler`
- **Mobile ROPC flow** — Direct username/password auth for mobile clients

---

## 🚀 Getting Started

### Prerequisites

| Prerequisite | Version | Purpose |
|-------------|---------|---------|
| [.NET SDK](https://dotnet.microsoft.com/download) | 10.0+ | Build and run the application |
| [Aspire CLI](https://learn.microsoft.com/en-us/dotnet/aspire/) | 13.4+ | Application orchestration |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Latest | Runs Keycloak and SQL Server containers |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.10+ | Build the mobile app (optional) |
| [Node.js](https://nodejs.org/) (optional) | 18+ | Only needed for Aspire dashboard |

### 1️⃣ Clone & Restore

```bash
cd aspire-starter
dotnet restore
```

### 2️⃣ Configure Secrets (First Time Only)

Set the SQL Server connection string in user secrets:

```bash
dotnet user-secrets set "ConnectionStrings:hospitalDb" "Server=localhost;Database=hospitalhms;User Id=sa;Password=YourPassword123!;TrustServerCertificate=True" --project aspire-starter.ApiService
```

### 3️⃣ Start the Application

```bash
aspire start
```

Or with the .NET CLI:

```bash
dotnet run --project aspire-starter.AppHost
```

This starts all services via the Aspire orchestrator:
1. **SQL Server** — Database container with persistent volume
2. **Keycloak** — Authentication server on port **8082** (auto-imports realm config)
3. **API Service** — Backend REST API
4. **Web Frontend** — Blazor UI
5. **Flutter Web** — Mobile app running as web on port **5160** (optional)

### 4️⃣ Access the Application

| Service | URL |
|---------|-----|
| Blazor Web App | `http://localhost:5100` (or the port shown in Aspire dashboard) |
| Flutter Web App | `http://localhost:5160` |
| Aspire Dashboard | `http://localhost:18888` (shown after `aspire start`) |
| Keycloak Admin | `http://localhost:8082/admin` (admin/admin) |
| API Scalar UI | `http://localhost:5520/scalar` (API documentation) |

### 5️⃣ Login Credentials

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin123` | Admin + Doctor |
| `dr.smith` | `doctor123` | Doctor |
| `nurse.jane` | `nurse123` | Nurse |
| `reception.alice` | `reception123` | Receptionist |

---

## 📂 Project Structure

```
aspire-starter/
├── aspire-starter.AppHost/              # Aspire orchestration
│   └── AppHost.cs                       # Service wiring, container config
├── aspire-starter.ApiService/           # Backend REST API
│   ├── Data/
│   │   └── HospitalDbContext.cs         # EF Core DbContext + seed data
│   ├── Endpoints/                       # Minimal API endpoints
│   │   ├── DashboardEndpoints.cs
│   │   ├── PatientEndpoints.cs
│   │   ├── DoctorEndpoints.cs
│   │   ├── DepartmentEndpoints.cs
│   │   ├── AppointmentEndpoints.cs
│   │   ├── MedicalRecordEndpoints.cs
│   │   ├── BillingEndpoints.cs
│   │   ├── RoomEndpoints.cs
│   │   └── StaffEndpoints.cs
│   │   └── MobileEndpoints.cs           # Mobile-specific endpoints
│   ├── Models/                          # Entity models
│   └── Program.cs
├── aspire-starter.Web/                  # Blazor frontend
│   ├── ApiClients/                      # HTTP client classes
│   ├── Components/
│   │   ├── Layout/                      # MainLayout, NavMenu
│   │   └── Pages/                       # All page components
│   ├── Models/                          # DTOs
│   └── Program.cs
├── aspire-starter.ServiceDefaults/      # Shared Aspire config
├── flutter_app/                         # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart                    # App entry + theme
│   │   ├── models/                      # DTOs (patient, doctor, etc.)
│   │   ├── screens/                     # 17 screen files
│   │   ├── services/                    # API + auth clients
│   │   └── widgets/                     # Reusable widgets
│   └── pubspec.yaml
├── keycloak/
│   └── import/
│       └── hospital-realm.json          # Keycloak realm config
└── README.md
```

---

## 📱 Flutter Mobile App

A full-featured cross-platform mobile interface for HospiCare, built with Flutter. Runs on **Android** and **Web** with a responsive design that adapts to each platform.

> **Detailed documentation**: See [`flutter_app/README.md`](./flutter_app/README.md)

### Features

| Module | Screens | Capabilities |
|---------|---------|--------------|
| **Dashboard** | Home + Dashboard | Animated stats cards, bed occupancy chart, quick actions, pull-to-refresh |
| **Patients** | List + Form | Search, register/edit, archive, emergency contact info |
| **Doctors** | List + Form | Department filter chips, add/edit, deactivate |
| **Appointments** | List + Form | Date & status filters, book, cancel, complete |
| **Departments** | List + Form | Department icons, add/edit |
| **Medical Records** | List + Form | Patient selector, diagnosis/treatment/prescription |
| **Billing** | List | Status filter, mark as paid (Cash/Card/Insurance/Online) |
| **Rooms** | List | Ward filters, admit patient, discharge |
| **Staff** | List + Form | Role filter chips, add/edit, deactivate |

### Responsive Layout

| Platform | Navigation | Breakpoint |
|----------|-----------|------------|
| **Web** (wide) | 200px sidebar with all 9 modules, user info, and sign out | ≥ 900px width |
| **Mobile** (narrow) | Bottom NavigationBar (5 destinations) + Drawer | < 900px width |

### Running the Flutter App

Via the **Aspire dashboard** (recommended — auto-starts with backend):

```bash
cd aspire-starter
dotnet run --project aspire-starter.AppHost
```

Or **independently**:

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Run on web
flutter run -d web-server --web-port 5160 --web-hostname 0.0.0.0

# Run on Android
flutter run
```

### Building APKs

The Aspire AppHost includes two build resources (`flutter-debug-apk` and `flutter-release-apk`) that appear in the Aspire dashboard. They are **stopped by default** and **never auto-trigger** — click **Start** to build:

| Resource | Command | Output |
|----------|---------|--------|
| `flutter-debug-apk` | `flutter build apk --debug` | `flutter_app/build/app/outputs/flutter-apk/app-debug.apk` |
| `flutter-release-apk` | `flutter build apk --release` | `flutter_app/build/app/outputs/flutter-apk/app-release.apk` |

Or from CLI:

```bash
cd flutter_app
flutter build apk --debug
```

### Auth Flow (Mobile)

The Flutter app uses the **Resource Owner Password Credentials (ROPC)** flow — no external browser:

```
Flutter App → POST username+password → Keycloak Token Endpoint → JWT Token
    → Token stored in SharedPreferences → Bearer token on all API requests
    → Auto-refresh on expiry → Logout on refresh failure
```

### Tech Stack (Flutter)

| Technology | Purpose |
|------------|---------|
| Flutter 3.10+ | Cross-platform UI framework |
| `http` package | REST API client |
| `shared_preferences` | JWT token persistence |
| Material 3 | Design system with custom blue theme |

---

## 📡 API Endpoints

All API endpoints are under `/api/` and require JWT Bearer authentication.

### Dashboard & Mobile

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/dashboard/summary` | Get hospital statistics |
| GET | `/api/mobile/summary` | Mobile-optimized summary (dashboard) |

### Patients
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/patients` | List all patients |
| GET | `/api/patients/search?q=` | Search patients by name/phone |
| GET | `/api/patients/{id}` | Get patient by ID |
| POST | `/api/patients` | Create new patient |
| PUT | `/api/patients/{id}` | Update patient |
| DELETE | `/api/patients/{id}` | Delete patient |

### Doctors
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/doctors` | List all doctors |
| GET | `/api/doctors/department/{id}` | Filter by department |
| GET | `/api/doctors/{id}` | Get doctor by ID |
| POST | `/api/doctors` | Create new doctor |
| PUT | `/api/doctors/{id}` | Update doctor |
| DELETE | `/api/doctors/{id}` | Delete doctor |

### Departments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/departments` | List all departments |
| GET | `/api/departments/{id}` | Get department by ID |
| POST | `/api/departments` | Create department |
| PUT | `/api/departments/{id}` | Update department |

### Appointments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/appointments` | List appointments (optional `?date=&status=`) |
| GET | `/api/appointments/{id}` | Get appointment by ID |
| POST | `/api/appointments` | Create appointment |
| PUT | `/api/appointments/{id}/complete` | Mark appointment as completed |
| PUT | `/api/appointments/{id}/cancel` | Cancel appointment |

### Medical Records
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/medical-records/patient/{patientId}` | Get records by patient |
| POST | `/api/medical-records` | Create medical record |

### Billing
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/billing` | List bills |
| GET | `/api/billing/patient/{patientId}` | Get bills by patient |
| PUT | `/api/billing/{id}/pay?amount=` | Mark bill as paid |

### Rooms
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/rooms` | List all rooms |
| PUT | `/api/rooms/{id}/assign?patientId=` | Assign patient to room |
| PUT | `/api/rooms/{id}/discharge` | Discharge patient |

### Staff
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/staff` | List staff |
| POST | `/api/staff` | Create staff member |
| PUT | `/api/staff/{id}` | Update staff member |
| DELETE | `/api/staff/{id}` | Delete staff member |

---

## 🗄️ Database Schema

### Entity Relationship Diagram (Core Tables)

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│  Department  │     │   Doctor     │     │   Patient    │
├─────────────┤     ├──────────────┤     ├──────────────┤
│ Id (PK)     │──┬──│ Id (PK)      │     │ Id (PK)      │
│ Name        │  │  │ FirstName    │     │ FirstName    │
│ Description │  │  │ LastName     │     │ LastName     │
│ Location    │  │  │ Specializ.   │     │ Phone        │
│ HeadDoctorId│  │  │ DepartmentId │──┐  │ Email        │
└─────────────┘  │  │ Phone        │  │  │ BloodGroup   │
                 │  │ Email        │  │  │ Gender       │
                 │  └──────────────┘  │  │ DOB          │
                 │                    │  │ Address      │
┌─────────────┐  │  ┌──────────────┐  │  │ RegDate      │
│    Room     │  │  │ Appointment  │  │  │ IsActive     │
├─────────────┤  │  ├──────────────┤  │  └──────────────┘
│ Id (PK)     │  │  │ Id (PK)      │  │         │
│ RoomNumber  │  │  │ PatientId    │──┤         │
│ BedNumber   │  │  │ DoctorId     │──┘         │
│ DeptId (FK) │──┘  │ ApptDate     │            │
│ IsOccupied  │     │ StartTime    │            │
│ DailyRate   │     │ EndTime      │            │
│ PatientId   │     │ Status       │            │
└─────────────┘     │ Reason       │            │
                    └──────────────┘            │
┌──────────────┐     ┌──────────────┐           │
│  Billing     │     │MedicalRecord │           │
├──────────────┤     ├──────────────┤           │
│ Id (PK)      │     │ Id (PK)      │           │
│ PatientId──┘──┐   │ PatientId──┘──┘           │
│ AppointmentId │   │ DoctorId──┐               │
│ InvoiceNumber │   │ Diagnosis  │               │
│ TotalAmount   │   │ Treatment  │               │
│ PaidAmount    │   │ Prescript. │               │
│ Status        │   └──────────────┘             │
└──────────────┘                                 │
┌──────────────┐                                 │
│    Staff     │                                 │
├──────────────┤                                 │
│ Id (PK)      │                                 │
│ FirstName    │    ┌──────────────┐             │
│ LastName     │    │  Department  │             │
│ Role         │    │  (same as    │             │
│ DeptId (FK)──┘────┤   above)     │             │
│ Phone        │    └──────────────┘             │
│ Salary       │                                 │
└──────────────┘                                 │
                                                  │
           All foreign keys reference Patient ────┘
           (appointments, bills, records, rooms)
```

### Tables
- **Departments** — Hospital departments (General Medicine, Cardiology, etc.)
- **Doctors** — Medical staff with specialization and department assignment
- **Patients** — Patient demographic and contact information
- **Appointments** — Scheduled appointments linking patients and doctors
- **MedicalRecords** — Clinical notes, diagnosis, treatment, prescriptions
- **Billings** — Invoices with payment tracking
- **Rooms** — Bed management with ward type and daily rates
- **Staff** — Non-doctor hospital staff (nurses, admin, etc.)

### Seed Data
The application includes seed data with 5 departments, 5 doctors, 3 patients, 5 rooms, and 3 staff members for immediate testing.

---

## 🔐 Authentication Flow

### Web (Blazor) — OpenID Connect

```
User → Blazor Web App (OIDC) → Keycloak (Login Page)
    → JWT Token → Blazor Stores Token
    → API Call with Bearer Token → API Validates JWT
    → Returns Data
```

### Mobile (Flutter) — ROPC

```
User enters credentials → Flutter App → POST to Keycloak Token Endpoint
    → JWT Token returned → Stored in SharedPreferences
    → All API requests include Bearer token
    → Auto-refresh on 401 response → Logout if refresh fails
```

### Keycloak Configuration
- **Realm**: `hospital-hms`
- **Web Client**: `hospital-web` (public client, no secret)
- **API Client**: `hospital-api` (bearer-only, secret: `hospital-api-secret`)
- **Mobile Client**: `hospital-mobile` (public client, ROPC enabled)
- **Token Lifetime**: 3600 seconds (1 hour)

### CORS
The API service has CORS configured to allow all origins in development (`MobileApp` policy), enabling the Flutter web app on port 5160 and DevTunnel URLs to reach the API.

---

## 🎨 UI Design

### Blazor Web App
- **Framework**: Bootstrap 5 + Bootstrap Icons + Custom CSS
- **Layout**: Dark sidebar (`#1b2533` gradient) with clean white content area
- **Navigation**: Categorized sections (Clinical, Administration) with SVG icons
- **Responsive**: Mobile-responsive with sidebar toggle
- **Theme**: Primary blue (`#2563eb`), clean cards with shadows, rounded corners

### Flutter Mobile App
- **Framework**: Material 3 with custom blue color scheme
- **Layout**: Responsive — sidebar on web, bottom nav + drawer on mobile
- **Dashboard**: Animated fade-in, gradient hero header, 6 stat cards, bed occupancy bar, quick actions
- **Lists**: Searchable, pull-to-refresh, status chips with color coding
- **Forms**: Validation, sectioned layout, patient/doctor selectors

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Orchestration** | .NET Aspire 13.4 |
| **Web Frontend** | Blazor Interactive Server (ASP.NET Core 10) |
| **Mobile App** | Flutter 3.10+ (Android + Web) |
| **Backend** | Minimal APIs (ASP.NET Core 10) |
| **Database** | SQL Server via Entity Framework Core 10 |
| **Auth** | Keycloak 25 (OpenID Connect / JWT / ROPC) |
| **Service Defaults** | OpenTelemetry, Health Checks, Resilience, Service Discovery |
| **Web Styling** | Bootstrap 5, Bootstrap Icons, Custom CSS |

---

## 📊 Observability

The application includes built-in observability via Aspire's service defaults:
- **Distributed Tracing** — OpenTelemetry with ASP.NET Core and HTTP client instrumentation
- **Metrics** — Runtime metrics, HTTP metrics
- **Logging** — Structured logging with OpenTelemetry
- **Health Checks** — `/health` and `/alive` endpoints
- **Aspire Dashboard** — Real-time traces, logs, and metrics visualization

---

## 📦 Deployment

### Docker Compose (via Aspire)
```bash
# Generate deployment manifests
aspire publish --output-dir ./deploy
```

### Azure Container Apps
```bash
# Deploy to Azure
az containerapp up --name hospicare --resource-group my-group --environment my-env
```

### Notes
- Keycloak and SQL Server run as Docker containers managed by Aspire
- Persistent data volumes are used for both databases
- The application requires Docker Desktop to be running for local development
- For mobile APK builds, use the Aspire dashboard resources or Flutter CLI

---

## 🧪 Testing

```bash
# Build the .NET solution
cd aspire-starter
dotnet build

# Flutter analysis (mobile app)
cd flutter_app
flutter analyze

# Run Flutter tests
flutter test

# Run .NET tests (when added)
dotnet test
```

---

## ❓ Troubleshooting

### 401 Unauthorized when loading dashboard
For Blazor: The `TokenService` captures the token during pre-render. If tokens expire, re-login.
For Flutter: The app auto-refreshes tokens. If refresh fails, re-login.

### File lock errors during build
```bash
# Kill running processes
taskkill /F /IM aspires* 2>/dev/null
# Then rebuild
dotnet build
```

### Keycloak startup failures
Ensure Docker Desktop is running and port 8082 is available. The API service includes startup warmup logic that waits for Keycloak (up to 30 seconds).

### SQL Server connection issues
Verify Docker has the SQL Server image and check the connection string in user secrets.

### Flutter "Could not connect to server"
- Ensure the Aspire AppHost is running
- Android emulator uses `10.0.2.2` automatically instead of `localhost`
- For web, ensure CORS is configured (it is — the `MobileApp` policy allows all origins)

### Flutter APK build fails
```bash
cd flutter_app
flutter doctor -v
flutter clean
flutter pub get
flutter build apk --debug
```

---

## 📄 License

This project is provided as a demonstration and learning resource.

---

## 👥 Contributors

Built with .NET Aspire, Blazor, Flutter, and Keycloak. Designed for modern hospital management.
