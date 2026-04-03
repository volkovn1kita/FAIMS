using Application.DTOs;
using Application.Interfaces;
using Application.Services;
using Domain;
using Domain.Exceptions;
using NSubstitute;
using Xunit;

namespace Tests.Services;

public class DepartmentServiceTests
{
    private readonly IDepartmentRepository _deptRepo = Substitute.For<IDepartmentRepository>();
    private readonly IFirstAidKitRepository _kitRepo = Substitute.For<IFirstAidKitRepository>();
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly DepartmentService _service;

    private static readonly Guid OrgId = Guid.NewGuid();

    public DepartmentServiceTests()
    {
        _currentUser.GetOrganizationId().Returns(OrgId);
        _service = new DepartmentService(_deptRepo, _kitRepo, _currentUser);
    }

    [Fact]
    public async Task AddDepartmentAsync_Throws_WhenNameAlreadyExists()
    {
        _deptRepo.GetAllDepartmentsAsync().Returns([
            new Department { Name = "Surgery", OrganizationId = OrgId }
        ]);

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AddDepartmentAsync(new DepartmentCreateDto("Surgery")));
    }

    [Fact]
    public async Task AddDepartmentAsync_Throws_WhenNameExistsCaseInsensitive()
    {
        _deptRepo.GetAllDepartmentsAsync().Returns([
            new Department { Name = "surgery", OrganizationId = OrgId }
        ]);

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AddDepartmentAsync(new DepartmentCreateDto("SURGERY")));
    }

    [Fact]
    public async Task AddDepartmentAsync_Succeeds_WhenNameIsUnique()
    {
        _deptRepo.GetAllDepartmentsAsync().Returns([]);

        var id = await _service.AddDepartmentAsync(new DepartmentCreateDto("Cardiology"));

        await _deptRepo.Received(1).AddDepartmentAsync(Arg.Any<Department>());
        await _deptRepo.Received(1).SaveChangesAsync();
    }

    [Fact]
    public async Task AddDepartmentAsync_Throws_WhenOrgIdIsEmpty()
    {
        _currentUser.GetOrganizationId().Returns(Guid.Empty);

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AddDepartmentAsync(new DepartmentCreateDto("X")));
    }

    [Fact]
    public async Task DeleteDepartmentAsync_Throws_WhenDepartmentHasRooms()
    {
        var dept = new Department
        {
            Id = Guid.NewGuid(),
            Name = "Surgery",
            Rooms = [new Room { Name = "Room 1" }]
        };
        _deptRepo.GetDepartmentByIdAsync(dept.Id).Returns(dept);

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.DeleteDepartmentAsync(dept.Id));
    }

    [Fact]
    public async Task DeleteDepartmentAsync_Succeeds_WhenNoRooms()
    {
        var dept = new Department { Id = Guid.NewGuid(), Name = "Empty", Rooms = [] };
        _deptRepo.GetDepartmentByIdAsync(dept.Id).Returns(dept);

        await _service.DeleteDepartmentAsync(dept.Id);

        await _deptRepo.Received(1).DeleteDepartment(dept);
        await _deptRepo.Received(1).SaveChangesAsync();
    }

    [Fact]
    public async Task GetDepartmentByIdAsync_Throws_WhenNotFound()
    {
        _deptRepo.GetDepartmentByIdAsync(Arg.Any<Guid>()).Returns((Department?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _service.GetDepartmentByIdAsync(Guid.NewGuid()));
    }

    [Fact]
    public async Task GetDepartmentByIdAsync_ReturnsDtoWithRooms()
    {
        var deptId = Guid.NewGuid();
        var dept = new Department
        {
            Id = deptId,
            Name = "Surgery",
            Rooms = [new Room { Id = Guid.NewGuid(), Name = "Room A" }]
        };
        _deptRepo.GetDepartmentByIdAsync(deptId).Returns(dept);

        var result = await _service.GetDepartmentByIdAsync(deptId);

        Assert.Equal("Surgery", result.Name);
        Assert.Single(result.Rooms);
        Assert.Equal("Room A", result.Rooms.First().Name);
    }

    [Fact]
    public async Task AddRoomAsync_Throws_WhenDepartmentNotFound()
    {
        _deptRepo.GetDepartmentByIdAsync(Arg.Any<Guid>()).Returns((Department?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _service.AddRoomAsync(new RoomCreateDto(Guid.NewGuid(), "Room 1")));
    }

    [Fact]
    public async Task AddRoomAsync_Throws_WhenRoomNameAlreadyExists()
    {
        var deptId = Guid.NewGuid();
        var dept = new Department
        {
            Id = deptId,
            Name = "Surgery",
            Rooms = [new Room { Name = "Room 1" }]
        };
        _deptRepo.GetDepartmentByIdAsync(deptId).Returns(dept);

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.AddRoomAsync(new RoomCreateDto(deptId, "Room 1")));
    }

    [Fact]
    public async Task DeleteRoomAsync_Throws_WhenKitIsAssigned()
    {
        var roomId = Guid.NewGuid();
        _deptRepo.GetRoomByIdAsync(roomId).Returns(new Room { Id = roomId, Name = "Room 1" });
        _kitRepo.GetKitByRoomIdAsync(roomId).Returns(new FirstAidKit { UniqueNumber = "KIT-001" });

        await Assert.ThrowsAsync<ValidationException>(
            () => _service.DeleteRoomAsync(roomId));
    }

    [Fact]
    public async Task UpdateDepartmentAsync_Throws_WhenNotFound()
    {
        _deptRepo.GetDepartmentByIdAsync(Arg.Any<Guid>()).Returns((Department?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _service.UpdateDepartmentAsync(Guid.NewGuid(), "New Name"));
    }
}
