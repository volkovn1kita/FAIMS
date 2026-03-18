using Domain;

namespace Application.Interfaces;

public interface ITokenService
{
    Task<string> GenerateTokenAsync(Guid userId, string email, UserRole role, Guid organizationId);
}
