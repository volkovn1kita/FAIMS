using Domain.Interfaces;

namespace Domain;

public class User : BaseEntity, IMustHaveTenant
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public UserRole Role { get; set; }

    public string? FcmToken { get; set; } 

    public Guid OrganizationId { get; set; }
    public Organization Organization { get; set; } = null!;

    public FirstAidKit? ResponsibleKit { get; set; }
    public ICollection<Journal> Journals { get; set; } = new List<Journal>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public string? AvatarUrl { get; set; }
}
