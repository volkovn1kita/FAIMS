namespace Application.DTOs;

public record class UpdateFcmTokenRequest
{
    public string Token { get; set; } = string.Empty;
}
