namespace Domain;

public class FirstAidKit : BaseEntity
{
    public string UniqueNumber { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;

    public Guid RoomId { get; set; }
    public Room Room { get; set; } = null!;
    
    public Guid ResponsibleUserId { get; set; }
    public User ResponsibleUser { get; set; } = null!;

    public ICollection<Medication> Medications { get; set; } = new List<Medication>();
    public ICollection<Journal> Journals { get; set; } = new List<Journal>();
}
