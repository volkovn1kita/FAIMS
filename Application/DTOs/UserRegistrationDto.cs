namespace Application.DTOs;

public record class UserRegistrationDto
(
    string Email,
    string FirstName,
    string LastName,
    string Password
);