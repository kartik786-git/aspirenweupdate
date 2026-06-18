# Hospital Management System — Implementation Plan

## Project Structure
```
aspire-starter/
├── aspire-starter.AppHost/           # Aspire orchestrator
│   ├── AppHost.cs                    # SQL Server + project references
│   └── aspire-starter.AppHost.csproj
├── aspire-starter.ApiService/        # .NET Core Web API backend
│   ├── Data/
│   │   └── HospitalDbContext.cs      # EF Core context + seed
│   ├── Models/
│   │   ├── Patient.cs
│   │   ├── Doctor.cs
│   │   ├── Department.cs
│   │   ├── Appointment.cs
│   │   ├── MedicalRecord.cs
│   │   ├── Billing.cs
│   │   ├── Room.cs
│   │   └── Staff.cs
│   ├── Program.cs                    # API endpoints
│   └── aspire-starter.ApiService.csproj
├── aspire-starter.Web/               # Blazor Server frontend
│   ├── ApiClients/                   # Typed HTTP clients
│   ├── Components/Pages/
│   │   ├── Dashboard.razor
│   │   ├── Patients/
│   │   ├── Doctors/
│   │   ├── Departments/
│   │   ├── Appointments/
│   │   ├── MedicalRecords/
│   │   ├── Billing/
│   │   ├── Rooms/
│   │   └── Staff/
│   └── Models/                       # Shared DTOs
└── aspire-starter.ServiceDefaults/
```

## NuGet Packages
- **AppHost**: `Aspire.Hosting.SqlServer`
- **ApiService**: `Microsoft.EntityFrameworkCore.SqlServer`, `Microsoft.EntityFrameworkCore.Design`, `Aspire.Microsoft.EntityFrameworkCore.SqlServer`
- **Web**: `Microsoft.AspNetCore.Components.QuickGrid`

## Database Schema — 8 Tables
| Table | Key Relationships |
|-------|------------------|
| Departments | HeadDoctorId → Doctor (nullable) |
| Doctors | DepartmentId → Departments |
| Patients | — |
| Appointments | PatientId → Patients, DoctorId → Doctors |
| MedicalRecords | PatientId → Patients, DoctorId → Doctors, AppointmentId → Appointments |
| Billing | PatientId → Patients, AppointmentId → Appointments |
| Rooms | DepartmentId → Departments, CurrentPatientId → Patients |
| Staff | DepartmentId → Departments |

## API Endpoints — 9 Groups
Departments, Patients, Doctors, Appointments, MedicalRecords, Billing, Rooms, Staff, Dashboard

## Blazor Pages — 14+ Pages
Dashboard, Patient List/Form/Detail, Doctor List/Form, Department List, Appointment List/Form, MedicalRecord List, Billing List/Detail, Room List, Staff List/Form
