using System;
using Application.DTOs;
using Application.Interfaces;
using Domain;
using Domain.Exceptions;

namespace Application.Services;

public class DepartmentService : IDepartmentService
{
    private readonly IDepartmentRepository _departmentRepository;
    private readonly IFirstAidKitRepository _kitRepository;
    private readonly ICurrentUserService _currentUserService;

    public DepartmentService(
        IDepartmentRepository departmentRepository,
        IFirstAidKitRepository kitRepository,
        ICurrentUserService currentUserService)
    {
        _departmentRepository = departmentRepository;
        _kitRepository = kitRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IEnumerable<RoomListAllDto>> GetAllRoomsAsync()
    {
        var rooms = await _departmentRepository.GetRoomsAsync();

        return rooms.Select(r => new RoomListAllDto(
            r.Id,
            r.Name,
            r.DepartmentId,
            r.Department.Name
        )).ToList();
    }
    
    public async Task<DepartmentDetailDto> GetDepartmentByIdAsync(Guid id)
    {
        var department = await _departmentRepository.GetDepartmentByIdAsync(id);
        if (department == null)
        {
            throw new NotFoundException($"Department with Id: {id} not found.");
        }
        var roomDtos = department.Rooms.Select(r => new RoomListDto(r.Id, r.Name));
        return new DepartmentDetailDto(
            department.Id,
            department.Name,
            roomDtos.ToList()
        );
    }

    public async Task<Guid> AddDepartmentAsync(DepartmentCreateDto dto)
    {
        var currentOrgId = _currentUserService.GetOrganizationId();
        if (currentOrgId == Guid.Empty)
        {
            throw new ValidationException("Organization ID not found in token.");
        }

        var existingDepartments = await _departmentRepository.GetAllDepartmentsAsync();
        if (existingDepartments.Any(d => d.Name.Equals(dto.Name, StringComparison.OrdinalIgnoreCase)))
        {
            throw new ValidationException($"A department named ‘{dto.Name}’ already exists.");
        }

        var newDepartment = new Department 
        { 
            Name = dto.Name,
            OrganizationId = currentOrgId 
        };
        
        await _departmentRepository.AddDepartmentAsync(newDepartment);
        await _departmentRepository.SaveChangesAsync();
        
        return newDepartment.Id;
    }

    public async Task<Guid> AddRoomAsync(RoomCreateDto dto)
    {
        var currentOrgId = _currentUserService.GetOrganizationId();
        if (currentOrgId == Guid.Empty)
        {
            throw new ValidationException("Organization ID not found in token.");
        }

        var department = await _departmentRepository.GetDepartmentByIdAsync(dto.DepartmentId);
        if (department == null)
        {
            throw new NotFoundException($"Department with Id: {dto.DepartmentId} not found.");
        }

        var existingRoom = department.Rooms?
            .Any(r => r.Name.Equals(dto.Name, StringComparison.OrdinalIgnoreCase));

        if (existingRoom == true)
        {
            throw new ValidationException($"A room named ‘{dto.Name}’ already exists in the ‘{department.Name}’ department.");
        }

        var newRoom = new Room
        {
            DepartmentId = dto.DepartmentId,
            Name = dto.Name,
            OrganizationId = currentOrgId
        };

        await _departmentRepository.AddRoomToDepartmentAsync(newRoom);
        await _departmentRepository.SaveChangesAsync();
        
        return newRoom.Id;
    }

    public async Task DeleteDepartmentAsync(Guid id)
    {
        var departmentToDelete = await _departmentRepository.GetDepartmentByIdAsync(id);
        if (departmentToDelete == null) return;
        
        if (departmentToDelete.Rooms != null && departmentToDelete.Rooms.Any())
        {
            throw new ValidationException("It is not possible to delete a department. First, delete all rooms associated with that department.");
        }

        await _departmentRepository.DeleteDepartment(departmentToDelete);
        await _departmentRepository.SaveChangesAsync();
    }

    public async Task DeleteRoomAsync(Guid id)
    {
        var roomToDelete = await _departmentRepository.GetRoomByIdAsync(id);
    
        if (roomToDelete == null) return;
        
        var existingKit = await _kitRepository.GetKitByRoomIdAsync(id);
        
        if (existingKit != null)
        {
            throw new ValidationException($"The room ‘{roomToDelete.Name}’ cannot be deleted because it has a first aid kit ‘{existingKit.UniqueNumber}’ assigned to it. Please move or delete the first aid kit first.");
        }
        
        await _departmentRepository.DeleteRoom(roomToDelete);
        await _departmentRepository.SaveChangesAsync();
    }

    public async Task<IEnumerable<Department>> GetAllDepartmentsAsync()
    {
        return await _departmentRepository.GetAllDepartmentsAsync();
    }

    public async Task<IEnumerable<Room>> GetRoomsByDepartmentIdAsync(Guid departmentId)
    {
        return await _departmentRepository.GetRoomsByDepartmentIdAsync(departmentId);
    }

    public async Task UpdateDepartmentAsync(Guid id, string name)
    {
        var departmentToUpdate = await _departmentRepository.GetDepartmentByIdAsync(id);
        if (departmentToUpdate == null)
        {
            throw new NotFoundException($"Department with Id: {id} not found.");
        }
        
        var existingDepartments = await _departmentRepository.GetAllDepartmentsAsync();
        if (existingDepartments.Any(d => d.Name.Equals(name, StringComparison.OrdinalIgnoreCase) && d.Id != id))
        {
            throw new ValidationException($"A department named ‘{name}’ already exists.");
        }
        
        departmentToUpdate.Name = name;
        departmentToUpdate.UpdatedDate = DateTime.UtcNow;
        
        await _departmentRepository.UpdateDepartment(departmentToUpdate);
        await _departmentRepository.SaveChangesAsync();
    }

    public async Task UpdateRoomAsync(Guid id, string name, Guid departmentId)
    {
        var roomToUpdate = await _departmentRepository.GetRoomByIdAsync(id);
        if (roomToUpdate == null)
        {
            throw new NotFoundException($"Room with Id: {id} not found.");
        }

        var department = await _departmentRepository.GetDepartmentByIdAsync(departmentId);
        if (department == null)
        {
            throw new NotFoundException($"Department with Id: {departmentId} not found.");
        }
        
        var existingRoomInNewDept = department.Rooms?
            .Any(r => r.Name.Equals(name, StringComparison.OrdinalIgnoreCase) && r.Id != id);

        if (existingRoomInNewDept == true)
        {
            throw new ValidationException($"A room named ‘{name}’ already exists in the target department ‘{department.Name}’.");
        }

        roomToUpdate.Name = name;
        roomToUpdate.DepartmentId = departmentId;
        roomToUpdate.UpdatedDate = DateTime.UtcNow;

        await _departmentRepository.UpdateRoom(roomToUpdate);
        await _departmentRepository.SaveChangesAsync();
    }
}