namespace Application.DTOs;

public record class AuthResultDto
(
    string Token,
    string RefreshToken,
    string Email,
    string Role,
    string Name
);
