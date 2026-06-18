content = r'''@attribute [Authorize]
@page "/patients/{id:int}"
@inject PatientApiClient PatientApi
@inject AppointmentApiClient AppointmentApi
@inject BillingApiClient BillingApi
@rendermode RenderMode.InteractiveServer

<PageTitle>Patient Details - HospiCare</PageTitle>

@if (patient is null)
{
    <div class="d-flex justify-content-center py-5">
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
        </div>
    </div>
}
else
{
    <div class="page-header">
        <div>
            <h3>@patient.FullName</h3>
            <p class="text-muted mb-0" style="font-size:0.875rem;">Patient #@patient.Id</p>
        </div>
        <div class="page-actions">
            <a href="/patients/edit/@patient.Id" class="btn btn-warning">Edit</a>
            <a href="/patients" class="btn btn-secondary">Back</a>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">Phone</small>
                    <span class="fw-medium">@patient.Phone</span>
                </div>
                <div class="col-md-3">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">Email</small>
                    <span class="fw-medium">@patient.Email</span>
                </div>
                <div class="col-md-3">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">Gender</small>
                    <span class="fw-medium">@patient.Gender</span>
                </div>
                <div class="col-md-3">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">Blood Group</small>
                    <span class="badge bg-secondary">@patient.BloodGroup</span>
                </div>
                <div class="col-md-3">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">DOB</small>
                    <span class="fw-medium">@patient.DateOfBirth?.ToShortDateString()</span>
                </div>
                <div class="col-md-3">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">Registered</small>
                    <span class="fw-medium">@patient.RegistrationDate.ToShortDateString()</span>
                </div>
                <div class="col-md-6">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">Emergency Contact</small>
                    <span class="fw-medium">@patient.EmergencyContactName (@patient.EmergencyContactPhone)</span>
                </div>
                <div class="col-12">
                    <small class="text-muted d-block text-uppercase" style="font-size:0.75rem;font-weight:600;">Address</small>
                    <span class="fw-medium">@patient.Address</span>
                </div>
            </div>
        </div>
    </div>

    <ul class="nav nav-tabs mb-3">
        <li class="nav-item">
            <button class="nav-link @(activeTab == "appointments" ? "active" : "")" @onclick="(() => activeTab = "appointments")">Appointments</button>
        </li>
        <li class="nav-item">
            <button class="nav-link @(activeTab == "bills" ? "active" : "")" @onclick="(() => activeTab = "bills")">Bills</button>
        </li>
        <li class="nav-item">
            <button class="nav-link @(activeTab == "records" ? "active" : "")" @onclick="(() => activeTab = "records")">Medical Records</button>
        </li>
    </ul>

    @if (activeTab == "appointments")
    {
        <div class="card">
            <div class="card-body p-0">
                <div class="table-card">
                    <table class="table mb-0">
                        <thead>
                            <tr><th>Date</th><th>Time</th><th>Doctor</th><th>Status</th></tr>
                        </thead>
                        <tbody>
                            @foreach (var a in appointments)
                            {
                                <tr>
                                    <td>@a.AppointmentDate.ToShortDateString()</td>
                                    <td>@a.StartTime - @a.EndTime</td>
                                    <td>@a.Doctor?.FullName</td>
                                    <td><span class="badge @GetStatusBadge(a.Status)">@a.Status</span></td>
                                </tr>
                            }
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    }
    else if (activeTab == "bills")
    {
        <div class="card">
            <div class="card-body p-0">
                <div class="table-card">
                    <table class="table mb-0">
                        <thead>
                            <tr><th>Invoice</th><th>Date</th><th>Total</th><th>Paid</th><th>Due</th><th>Status</th></tr>
                        </thead>
                        <tbody>
                            @foreach (var b in bills)
                            {
                                <tr>
                                    <td class="fw-medium">@b.InvoiceNumber</td>
                                    <td>@b.BillDate.ToShortDateString()</td>
                                    <td>$@b.TotalAmount</td>
                                    <td>$@b.PaidAmount</td>
                                    <td class="fw-semibold @(b.DueAmount > 0 ? "text-danger" : "text-success")">$@b.DueAmount</td>
                                    <td><span class="badge @GetBillStatusBadge(b.Status)">@b.Status</span></td>
                                </tr>
                            }
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    }
    else if (activeTab == "records")
    {
        @if (medicalRecords is not null && medicalRecords.Count > 0)
        {
            @foreach (var r in medicalRecords)
            {
                <div class="record-card">
                    <div class="card-header d-flex justify-content-between">
                        <span class="fw-medium">@r.RecordDate.ToShortDateString()</span>
                        <span class="text-muted">Dr. @r.Doctor?.FullName</span>
                    </div>
                    <div class="card-body">
                        <p><strong>Diagnosis:</strong> @r.Diagnosis</p>
                        @if (!string.IsNullOrWhiteSpace(r.Treatment))
                        {
                            <p><strong>Treatment:</strong> @r.Treatment</p>
                        }
                        @if (!string.IsNullOrWhiteSpace(r.Prescription))
                        {
                            <p><strong>Prescription:</strong> @r.Prescription</p>
                        }
                    </div>
                </div>
            }
        }
        else
        {
            <div class="empty-state">
                <div class="empty-icon"><i class="bi bi-file-medical"></i></div>
                <h5>No medical records found</h5>
                <p class="text-muted">No records for this patient yet.</p>
            </div>
        }
    }
}

@code {
    [Parameter] public int Id { get; set; }

    private PatientDto? patient;
    private List<AppointmentDto> appointments = [];
    private List<BillingDto> bills = [];
    private List<MedicalRecordDto> medicalRecords = [];
    private string activeTab = "appointments";

    protected override async Task OnInitializedAsync()
    {
        patient = await PatientApi.GetByIdAsync(Id);
        if (patient is not null)
        {
            appointments = await AppointmentApi.GetByPatientAsync(Id);
            bills = await BillingApi.GetByPatientAsync(Id);
        }
    }

    private static string GetStatusBadge(stri
