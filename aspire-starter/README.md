# 🏥 HospiCare — Hospital Management System

A comprehensive, modern hospital management system built with **.NET Aspire 13.4**, **Blazor Interactive Server**, **Keycloak authentication**, and **SQL Server**.

## 📋 Overview

HospiCare is a full-stack hospital management application that provides a unified dashboard for managing patients, doctors, appointments, medical records, billing, rooms/beds, departments, and staff. It leverages .NET Aspire for cloud-native orchestration, service discovery, and observability.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                  .NET Aspire AppHost                  │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │  Keycloak    │  │  API Service │  │  Web App   │ │
│  │  (Port 8082) │  │  (Backend)   │  │  (Frontend)│ │
│  │  Auth Server │◄─┤  REST APIs   │◄─┤  Blazor UI │ │
│  └──────────────┘  └──┬───────────┘  └────────────┘ │
│                       │                              │
│              ┌────────▼────────┐                     │
│              │   SQL Server    │                     │
│              │  (hospital-db)  │                     │
│              └─────────────────┘                     │
└─────────────────────────────────────────────────────┘
```

### Projects

| Project | Description | Framework |
|---------|-------------|-----------|
| **AppHost** | Aspire orchestration — manages containers, service discovery, and startup ordering | .NET 10 |
| **ApiService** | REST API — handles all business logic and data access | .NET 10 |
| **Web** | Blazor Interactive Server UI — modern responsive frontend | .NET 10 |
| **ServiceDefaults** | Shared Aspire defaults — OpenTelemetry, health checks, resilience | .NET 10 |

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

---

## 🚀 Getting Started

### Prerequisites

| Prerequisite | Version | Purpose |
|-------------|---------|---------|
| [.NET SDK](https://dotnet.microsoft.com/download) | 10.0+ | Build and run the application |
| [Aspire CLI](https://learn.microsoft.com/en-us/dotnet/aspire/) | 13.4+ | Application orchestration |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Latest | Runs Keycloak and SQL Server containers |
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

This starts all services via the Aspire orchestrator:
1. **SQL Server** — Database container with persistent volume
2. **Keycloak** — Authentication server on port **8082** (auto-imports realm config)
3. **API Service** — Backend REST API
4. **Web Frontend** — Blazor UI

### 4️⃣ Access the Application

| Service | URL |
|---------|-----|
| Web App | `http://localhost:5100` (or the port shown in Aspire dashboard) |
| Aspire Dashboard | `http://localhost:18888` (shown after `aspire start`) |
| Keycloak Admin | `http://localhost:8082/admin` (admin/admin) |

### 5️⃣ Login Credentials

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin123` | Admin + Doctor |
| `dr.smith` | `doctor123` | Doctor |
| `nurse.jane` | `nurse123` | Nurse |
| `reception.alice` | `reception123` | Receptionist |

---

## 🧩 Project Structure

```
aspire-starter/
├── aspire-starter.AppHost/          # Aspire orchestration
│   └── AppHost.cs                   # Service wiring, container config
├── aspire-starter.ApiService/       # Backend REST API
│   ├── Data/
│   │   └── HospitalDbContext.cs     # EF Core DbContext + seed data
│   ├── Endpoints/                   # Minimal API endpoints
│   │   ├── DashboardEndpoints.cs
│   │   ├── PatientEndpoints.cs
│   │   ├── DoctorEndpoints.cs
│   │   ├── DepartmentEndpoints.cs
│   │   ├── AppointmentEndpoints.cs
│   │   ├── MedicalRecordEndpoints.cs
│   │   ├── BillingEndpoints.cs
│   │   ├── RoomEndpoints.cs
│   │   └── StaffEndpoints.cs
│   ├── Models/                      # Entity models
│   └── Program.cs
├── aspire-starter.Web/              # Blazor frontend
│   ├── ApiClients/                  # HTTP client classes
│   ├── Components/
│   │   ├── Layout/                  # MainLayout, NavMenu
│   │   └── Pages/                   # All page components
│   ├── Models/                      # DTOs
│   └── Program.cs
├── aspire-starter.ServiceDefaults/  # Shared Aspire config
├── keycloak/
│   └── import/
│       └── hospital-realm.json      # Keycloak realm config
└── README.md
```

---

## 📡 API Endpoints

All API endpoints are under `/api/` and require JWT Bearer authentication.

### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/dashboard/summary` | Get hospital statistics (patients, doctors, appointments, revenue, occupancy) |

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
| GET | `/api/doctors/{id}` | Get doctor by ID |
| POST | `/api/doctors` | Create new doctor |
| PUT | `/api/doctors/{id}` | Update doctor |
| DELETE | `/api/doctors/{id}` | Delete doctor |

### Departments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/departments` | List all departments |
| POST | `/api/departments` | Create department |
| DELETE | `/api/departments/{id}` | Delete department |

### Appointments
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/appointments` | List appointments (optional `?date=&status=`) |
| GET | `/api/appointments/patient/{patientId}` | Get appointments by patient |
| POST | `/api/appointments` | Create appointment |
| POST | `/api/appointments/{id}/complete` | Mark appointment as completed |
| POST | `/api/appointments/{id}/cancel` | Cancel appointment |

### Medical Records
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/medical-records/patient/{patientId}` | Get records by patient |
| POST | `/api/medical-records` | Create medical record |

### Billing
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/billing` | List bills (optional `?status=`) |
| GET | `/api/billing/patient/{patientId}` | Get bills by patient |
| POST | `/api/billing` | Create invoice |
| POST | `/api/billing/{id}/pay` | Make a payment |

### Rooms
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/rooms` | List all rooms |
| POST | `/api/rooms` | Create room |
| POST | `/api/rooms/{id}/assign` | Assign patient to room |
| POST | `/api/rooms/{id}/discharge` | Discharge patient |
| DELETE | `/api/rooms/{id}` | Delete room |

### Staff
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/staff` | List staff (optional `?role=`) |
| GET | `/api/staff/{id}` | Get staff by ID |
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

```
User → Blazor Web App (OIDC) → Keycloak (Login Page)
    → JWT Token → Blazor Stores Token
    → API Call with Bearer Token → API Validates JWT
    → Returns Data
```

### Keycloak Configuration
- **Realm**: `hospital-hms`
- **Web Client**: `hospital-web` (public client, no secret)
- **API Client**: `hospital-api` (bearer-only, secret: `hospital-api-secret`)
- **Token Lifetime**: 3600 seconds (1 hour)

### Blazor Token Propagation
The app uses a `TokenService` + `TokenHandler` pattern to propagate the access token from the initial HTTP request (pre-render) to SignalR circuit operations:

1. **Pre-render phase**: `MainLayout.OnInitializedAsync` captures the token from `HttpContext` and stores it in `TokenService`
2. **SignalR circuit phase**: `TokenHandler` falls back to `TokenService.AccessToken` when `HttpContext` is unavailable

---

## 🎨 UI Design

- **Framework**: Bootstrap 5 + Bootstrap Icons + Custom CSS
- **Layout**: Dark sidebar (`#1b2533` gradient) with clean white content area
- **Navigation**: Categorized sections (Clinical, Administration) with SVG icons
- **Responsive**: Mobile-responsive with sidebar toggle
- **Interactions**: Hover animations, active state highlighting, content fade-in

### Theme
- **Sidebar**: Dark navy gradient with bright white text
- **Main Content**: Clean light gray background (`#f8f9fb`)
- **Primary Color**: Blue (`#2563eb`)
- **Cards**: White with subtle shadows and rounded corners
- **Tables**: Clean headers with hover effects

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Orchestration** | .NET Aspire 13.4 |
| **Frontend** | Blazor Interactive Server (ASP.NET Core 10) |
| **Backend** | Minimal APIs (ASP.NET Core 10) |
| **Database** | SQL Server via Entity Framework Core 10 |
| **Auth** | Keycloak 25 (OpenID Connect / JWT) |
| **Service Defaults** | OpenTelemetry, Health Checks, Resilience, Service Discovery |
| **Styling** | Bootstrap 5, Bootstrap Icons, Custom CSS |

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

---

## 🧪 Testing

```bash
# Build the solution
dotnet build

# Run tests (when added)
dotnet test
```

---

## ❓ Troubleshooting

### 401 Unauthorized when loading dashboard
The `TokenService` in `MainLayout` captures the token during pre-render for use during SignalR circuit operations. If tokens expire, re-login.

### File lock errors during build
```bash
# Kill running processes
taskkill /F /IM aspires* 2>/dev/null
# Then rebuild
dotnet build
```

### Keycloak startup failures
Ensure Docker Desktop is running and port 8082 is available.

### SQL Server connection issues
Verify Docker has the SQL Server image and check the connection string in user secrets.

---

## 📄 License

This project is provided as a demonstration and learning resource.

---

## 👥 Contributors

Built with .NET Aspire, Blazor, and Keycloak. Designed for modern hospital management.
