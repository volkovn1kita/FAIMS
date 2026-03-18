using System.Security.Claims;

namespace Backend.Services;

public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid GetUserId()
    {
        var user = _httpContextAccessor.HttpContext?.User;
        var userIdClaim = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (Guid.TryParse(userIdClaim, out var userId))
        {
            return userId;
        }
        
        return Guid.Empty;
    }

    public string? GetUserRole()
    {
        return _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Role)?.Value;
    }

    public Guid GetOrganizationId()
    {
        var user = _httpContextAccessor.HttpContext?.User;
        var orgIdClaim = user?.FindFirst("OrganizationId")?.Value;

        if (Guid.TryParse(orgIdClaim, out var orgId))
        {
            return orgId;
        }

        return Guid.Empty;
    }
}