namespace aspire_starter.Web.Models;

public class DashboardSummaryDto
{
    public int TotalPatients { get; set; }
    public int ActiveDoctors { get; set; }
    public int TodayAppointments { get; set; }
    public int TotalRooms { get; set; }
    public int OccupiedRooms { get; set; }
    public double OccupancyRate { get; set; }
    public decimal MonthlyRevenue { get; set; }
    public int PendingBills { get; set; }
}
