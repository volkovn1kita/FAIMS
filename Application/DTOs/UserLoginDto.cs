using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record class UserLoginDto
(
    [Required]
    [EmailAddress]
    [MaxLength(256)]
    string Email,

    [Required]
    [MinLength(6)]
    [MaxLength(100)]
    string Password
);
