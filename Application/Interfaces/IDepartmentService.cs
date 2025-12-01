using System;
using Application.DTOs;
using Domain;

namespace Application.Interfaces;

public interface IDepartmentService
{
    Task<DepartmentDetailDto> GetDepartmentByIdAsync(Guid id);
    Task<Guid> AddDepartmentAsync(DepartmentCreateDto dto);
    Task UpdateDepartmentAsync(Guid id, string name);
    Task DeleteDepartmentAsync(Guid id);
    Task<IEnumerable<Department>> GetAllDepartmentsAsync();

    Task<Guid> AddRoomAsync(RoomCreateDto dto);
    Task<IEnumerable<RoomListAllDto>> GetAllRoomsAsync();
    Task UpdateRoomAsync(Guid id, string name, Guid departmentId);
    Task DeleteRoomAsync(Guid id);
    Task<IEnumerable<Room>> GetRoomsByDepartmentIdAsync(Guid departmentId);
}
