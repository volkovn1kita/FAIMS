using Application.DTOs;
using Microsoft.AspNetCore.Http;


namespace Application.Interfaces
{
    public interface IUserService
    {
        Task<IEnumerable<UserDto>> GetAllUsersAsync(UserFilterAndPaginationDto filterDto); // <--- ЗМІНЕНО
        Task<UserDto> GetUserByIdAsync(Guid id);
        Task<UserDto> GetCurrentUserProfileAsync(Guid currentUserId);
        Task<AuthResultDto?> LoginAsync(UserLoginDto dto);
        Task<Guid> AdminCreateUserAsync(AdminCreateUserDto dto);
        Task UpdateUserAsync(Guid userId, UpdateUserDto dto);
        Task UpdateUserProfileAsync(Guid userId, UpdateProfileDto dto);
        Task DeleteUserAsync(Guid userId);
        Task<string> UploadUserAvatarAsync(Guid userId, IFormFile avatarFile); // <--- НОВИЙ МЕТОД
        Task DeleteUserAvatarAsync(Guid userId);

        Task UpdateFcmTokenAsync(Guid userId, string token);
        Task<string?> GetUserFcmTokenAsync(Guid userId);
    }
}