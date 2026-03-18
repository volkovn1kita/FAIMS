using Domain.Interfaces;

namespace Domain;

public class Room : BaseEntity,IMustHaveTenant
{
    public string Name { get; set; } = string.Empty;

    public Guid DepartmentId { get; set; }
    public Department Department { get; set; } = null!; 

    public Guid OrganizationId { get; set; }
    public Organization Organization { get; set; } = null!;

    public FirstAidKit? FirstAidKit { get; set; }
}
