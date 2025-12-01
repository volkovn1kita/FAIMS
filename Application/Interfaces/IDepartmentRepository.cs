using Domain;

namespace Application.Interfaces;

public interface IDepartmentRepository
{
    Task<IEnumerable<Department>> GetAllDepartmentsAsync();
    Task<Department?> GetDepartmentByIdAsync(Guid id);
    Task<Department?> GetDepartmentByNameAsync(string name);
    Task AddDepartmentAsync(Department department);
    Task UpdateDepartment(Department department);
    Task DeleteDepartment(Department department);

    Task<IEnumerable<Room>> GetRoomsByDepartmentIdAsync(Guid departmentId);
    Task<IEnumerable<Room>> GetRoomsAsync();
    Task<Room?> GetRoomByIdAsync(Guid id);
    Task AddRoomToDepartmentAsync(Room room);
    Task UpdateRoom(Room room);
    Task DeleteRoom(Room room);
    Task SaveChangesAsync();

}
