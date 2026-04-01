using Application.Interfaces;
using Domain;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class RefreshTokenRepository : IRefreshTokenRepository
{
    private readonly ApplicationDbContext _dbContext;

    public RefreshTokenRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<RefreshToken?> GetByTokenAsync(string token)
    {
        return await _dbContext.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == token && !rt.IsRevoked && rt.ExpiresAt > DateTime.UtcNow);
    }

    public async Task AddAsync(RefreshToken refreshToken)
    {
        await _dbContext.RefreshTokens.AddAsync(refreshToken);
    }

    public async Task SaveChangesAsync()
    {
        await _dbContext.SaveChangesAsync();
    }
}
