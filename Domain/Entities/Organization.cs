namespace Domain
{
    public class Organization : BaseEntity
    {
        public string Name { get; set; } = string.Empty;
        public string? Address { get; set; }

        public ICollection<User> Users { get; set; } = new List<User>();
        public ICollection<Department> Departments { get; set; } = new List<Department>();
    }
}