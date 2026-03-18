using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public class RegisterOrganizationDto
{
    [Required]
    [MaxLength(100)]
    public string OrganizationName { get; set; } = string.Empty;

    public string? OrganizationAddress { get; set; }

    [Required]
    [MaxLength(50)]
    public string AdminFirstName { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string AdminLastName { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    public string AdminEmail { get; set; } = string.Empty;
    
    [Required]
    [MinLength(6)]
    public string AdminPassword { get; set; } = string.Empty;
}
