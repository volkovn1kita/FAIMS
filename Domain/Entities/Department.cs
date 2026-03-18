using Domain.Interfaces;

namespace Domain;

public class Department : BaseEntity, IMustHaveTenant
{
    public string Name { get; set; } = string.Empty;
    
    public Guid OrganizationId { get; set; }
    public Organization Organization { get; set; } = null!;
    
    public ICollection<Room> Rooms { get; set; } = new List<Room>();
}
