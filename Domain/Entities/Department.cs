namespace Domain;

public class Department : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    public ICollection<Room> Rooms { get; set; } = new List<Room>();
}
