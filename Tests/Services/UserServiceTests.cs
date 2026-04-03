using Application.DTOs;
using Application.Interfaces;
using Application.Services;
using Domain;
using Domain.Exceptions;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Hosting;
using NSubstitute;
using Xunit;

namespace Tests.Services;

public class UserServiceTests
{
    private readonly IUserRepository _userRepo = Substitute.For<IUserRepository>();
    private readonly IPasswordHasher<User> _hasher = Substitute.For<IPasswordHasher<User>>();
    private readonly ITokenService _tokenService = Substitute.For<ITokenService>();
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly IFirstAidKitRepository _kitRepo = Substitute.For<IFirstAidKitRepository>();
    private readonly IHostEnvironment _env = Substitute.For<IHostEnvironment>();
    private readonly IOrganizationRepository _orgRepo = Substitute.For<IOrganizationRepository>();
    private readonly IRefreshTokenRepository _refreshTokenRepo = Substitute.For<IRefreshTokenRepository>();
    private readonly UserService _service;

    private static readonly Guid OrgId = Guid.NewGuid();

    public UserServiceTests()
    {
        _currentUser.GetOrganizationId().Returns(OrgId);
        _env.ContentRootPath.Returns(".");
        _env.EnvironmentName.Returns("Testing");
        _service = new UserService(
            _userRepo, _hasher, _tokenService, _orgRepo,
            _currentUser, _kitRepo, _env, _refreshTokenRepo);
    }

    [Fact]
    public async Task GetUserByIdAsync_Throws_WhenUserNotFound()
    {
        _userRepo.GetByIdAsync(Arg.Any<Guid>()).Returns((User?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _service.GetUserByIdAsync(Guid.NewGuid()));
    }

    [Fact]
    public async Task GetUserByIdAsync_ReturnsDto_WhenFound()
    {
        var userId = Guid.NewGuid();
        _userRepo.GetByIdAsync(userId).Returns(new User
        {
            Id = userId,
            Email = "user@test.com",
            FirstName = "John",
            LastName = "Doe",
            Role = UserRole.User,
        });

        var result = await _service.GetUserByIdAsync(userId);

        Assert.Equal(userId, result.Id);
        Assert.Equal("user@test.com", result.Email);
        Assert.Equal("John", result.FirstName);
        Assert.Equal("User", result.Role);
    }

    [Fact]
    public async Task AdminCreateUserAsync_Throws_WhenEmailAlreadyExists()
    {
        _userRepo.GetByEmailAsync("existing@test.com").Returns(new User { Email = "existing@test.com" });

        var dto = new AdminCreateUserDto
        {
            Email = "existing@test.com",
            FirstName = "John",
            LastName = "Doe",
            Password = "password123",
            Role = UserRole.User,
        };

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AdminCreateUserAsync(dto));
    }

    [Fact]
    public async Task AdminCreateUserAsync_Throws_WhenEmailIsEmpty()
    {
        var dto = new AdminCreateUserDto
        {
            Email = "",
            FirstName = "John",
            LastName = "Doe",
            Password = "password123",
            Role = UserRole.User,
        };

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AdminCreateUserAsync(dto));
    }

    [Fact]
    public async Task AdminCreateUserAsync_Succeeds_WhenValid()
    {
        _userRepo.GetByEmailAsync(Arg.Any<string>()).Returns((User?)null);
        _hasher.HashPassword(Arg.Any<User>(), Arg.Any<string>()).Returns("hashed");

        var dto = new AdminCreateUserDto
        {
            Email = "new@test.com",
            FirstName = "Jane",
            LastName = "Doe",
            Password = "password123",
            Role = UserRole.User,
        };

        await _service.AdminCreateUserAsync(dto);

        await _userRepo.Received(1).AddAsync(Arg.Is<User>(u =>
            u.Email == "new@test.com" &&
            u.OrganizationId == OrgId));
        await _userRepo.Received(1).SaveChangesAsync();
    }

    [Fact]
    public async Task UpdateUserAsync_Throws_WhenUpdatingSelf()
    {
        var userId = Guid.NewGuid();
        _currentUser.GetUserId().Returns(userId);

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.UpdateUserAsync(userId, new UpdateUserDto
            {
                Email = "me@test.com",
                FirstName = "Me",
                LastName = "Myself",
                Role = UserRole.Administrator,
            }));
    }

    [Fact]
    public async Task UpdateUserAsync_Throws_WhenUserNotFound()
    {
        _currentUser.GetUserId().Returns(Guid.NewGuid());
        _userRepo.GetByIdAsync(Arg.Any<Guid>()).Returns((User?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _service.UpdateUserAsync(Guid.NewGuid(), new UpdateUserDto
            {
                Email = "x@test.com",
                FirstName = "X",
                LastName = "Y",
                Role = UserRole.User,
            }));
    }
}
