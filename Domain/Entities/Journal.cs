namespace Domain;

public class Journal : BaseEntity
{
    public JournalAction ActionType { get; set; }
    public string? Reason { get; set; }

    public string MedicationName { get; set; } = string.Empty; 
    public int Quantity { get; set; }
    public MeasurementUnit Unit { get; set; }

    public Guid FirstAidKitId { get; set; }
    public FirstAidKit FirstAidKit { get; set; } = null!;

    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    public Guid? BatchId { get; set; }
    
}
