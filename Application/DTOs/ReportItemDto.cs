namespace Application.DTOs;

public class ReportItemDto
{
    public string MedicationName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string Unit { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
}