namespace Application.DTOs;

public record class AuthResultDto
(
    string Token,
    string Email,
    string Role,
    string Name
);
