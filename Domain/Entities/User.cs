namespace Domain;

public class User : BaseEntity
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public UserRole Role { get; set; }
    public FirstAidKit? ResponsibleKit { get; set; }
    public ICollection<Journal> Journals { get; set; } = new List<Journal>();
    public string? AvatarUrl { get; set; }
    
}
