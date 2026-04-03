using Application.DTOs;
using Application.Interfaces;
using Application.Services;
using Domain;
using Domain.Exceptions;
using NSubstitute;
using Xunit;

namespace Tests.Services;

public class FirstAidKitServiceTests
{
    private readonly IFirstAidKitRepository _kitRepo = Substitute.For<IFirstAidKitRepository>();
    private readonly IUserRepository _userRepo = Substitute.For<IUserRepository>();
    private readonly IDepartmentRepository _deptRepo = Substitute.For<IDepartmentRepository>();
    private readonly IJournalRepository _journalRepo = Substitute.For<IJournalRepository>();
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly FirstAidKitService _service;

    private static readonly Guid OrgId = Guid.NewGuid();

    public FirstAidKitServiceTests()
    {
        _currentUser.GetOrganizationId().Returns(OrgId);
        _service = new FirstAidKitService(_kitRepo, _userRepo, _deptRepo, _journalRepo, _currentUser);
    }

    private static FirstAidKitCreateDto ValidCreateDto(string uniqueNumber = "KIT-001") =>
        new(uniqueNumber, "Test Kit", Guid.NewGuid(), Guid.NewGuid());

    [Fact]
    public async Task AddKitAsync_Throws_WhenOrgIdIsEmpty()
    {
        _currentUser.GetOrganizationId().Returns(Guid.Empty);

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AddKitAsync(ValidCreateDto()));
    }

    [Fact]
    public async Task AddKitAsync_Throws_WhenUniqueNumberAlreadyExists()
    {
        _kitRepo.GetKitByUniqueNumberAsync("KIT-001").Returns(new FirstAidKit { UniqueNumber = "KIT-001" });

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AddKitAsync(ValidCreateDto("KIT-001")));
    }

    [Fact]
    public async Task AddKitAsync_Throws_WhenRoomNotFound()
    {
        _kitRepo.GetKitByUniqueNumberAsync(Arg.Any<string>()).Returns((FirstAidKit?)null);
        _deptRepo.GetRoomByIdAsync(Arg.Any<Guid>()).Returns((Room?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _service.AddKitAsync(ValidCreateDto()));
    }

    [Fact]
    public async Task AddKitAsync_Throws_WhenResponsibleUserNotFound()
    {
        _kitRepo.GetKitByUniqueNumberAsync(Arg.Any<string>()).Returns((FirstAidKit?)null);
        _deptRepo.GetRoomByIdAsync(Arg.Any<Guid>()).Returns(new Room { Name = "Room 1" });
        _userRepo.GetByIdAsync(Arg.Any<Guid>()).Returns((User?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _service.AddKitAsync(ValidCreateDto()));
    }

    [Fact]
    public async Task AddKitAsync_Succeeds_WhenAllValid()
    {
        _kitRepo.GetKitByUniqueNumberAsync(Arg.Any<string>()).Returns((FirstAidKit?)null);
        _deptRepo.GetRoomByIdAsync(Arg.Any<Guid>()).Returns(new Room { Name = "Room 1" });
        _userRepo.GetByIdAsync(Arg.Any<Guid>()).Returns(new User { FirstName = "John", LastName = "Doe" });

        await _service.AddKitAsync(ValidCreateDto());

        await _kitRepo.Received(1).AddKitAsync(Arg.Is<FirstAidKit>(k =>
            k.UniqueNumber == "KIT-001" && k.OrganizationId == OrgId));
        await _kitRepo.Received(1).SaveChangesAsync();
    }
}
