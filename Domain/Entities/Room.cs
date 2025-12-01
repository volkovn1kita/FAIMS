namespace Domain;

public class Room : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    public Guid DepartmentId { get; set; }
    public Department Department { get; set; } = null!; 

    public FirstAidKit? FirstAidKit { get; set; }
}
