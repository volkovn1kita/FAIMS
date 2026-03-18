// Application/Services/UserService.cs - ОНОВЛЕНА ВЕРСІЯ
using Application.DTOs;
using Application.Interfaces;
using Domain;
using Domain.Exceptions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions; // Для PredicateBuilder
using System.Threading.Tasks;

namespace Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IPasswordHasher<User> _passwordHasher;
        private readonly ITokenService _tokenService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IFirstAidKitRepository _kitRepository;
        private readonly IHostEnvironment _hostEnvironment;

        public UserService(
            IUserRepository userRepository,
            IPasswordHasher<User> passwordHasher,
            ITokenService tokenService,
            ICurrentUserService currentUserService,
            IFirstAidKitRepository kitRepository,
            IHostEnvironment hostEnvironment)
        {
            _tokenService = tokenService;
            _userRepository = userRepository;
            _passwordHasher = passwordHasher;
            _currentUserService = currentUserService;
            _kitRepository = kitRepository;
            _hostEnvironment = hostEnvironment;
        }

        public async Task<IEnumerable<UserDto>> GetAllUsersAsync(UserFilterAndPaginationDto filterDto) // <--- ЗМІНЕНО
        {
            // Передаємо фільтри в репозиторій
            var users = await _userRepository.GetAllFilteredAndSortedAsync(filterDto);

            // Перетворюємо Domain.User на Application.DTOs.UserDto
            return users.Select(u => new UserDto
            {
                Id = u.Id,
                Email = u.Email,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Role = u.Role.ToString(),
                CreatedDate = u.CreatedDate,
                UpdatedDate = u.UpdatedDate,
                AvatarUrl = u.AvatarUrl
            }).ToList();
        }

        // ... (інші методи залишились без змін)

        public async Task<UserDto> GetUserByIdAsync(Guid id)
        {
            var user = await _userRepository.GetByIdAsync(id);
            if (user == null)
            {
                throw new NotFoundException($"User with Id: {id} not found.");
            }
            return new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role.ToString(),
                CreatedDate = user.CreatedDate,
                UpdatedDate = user.UpdatedDate,
                AvatarUrl = user.AvatarUrl
            };
        }

        public async Task<UserDto> GetCurrentUserProfileAsync(Guid currentUserId)
        {
            var user = await _userRepository.GetByIdAsync(currentUserId);
            if (user == null)
            {
                throw new NotFoundException($"User with Id: {currentUserId} not found.");
            }
            return new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role.ToString(),
                CreatedDate = user.CreatedDate,
                UpdatedDate = user.UpdatedDate,
                AvatarUrl = user.AvatarUrl
            };
        }

        public async Task<string> UploadUserAvatarAsync(Guid userId, IFormFile avatarFile)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
            {
                throw new NotFoundException($"User with Id: {userId} not found.");
            }

            // Перевірка файлу
            if (avatarFile == null || avatarFile.Length == 0)
            {
                throw new ValidationException("No file uploaded or file is empty.");
            }

            // Перевірка типу файлу (наприклад, дозволяємо лише зображення)
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
            var fileExtension = Path.GetExtension(avatarFile.FileName).ToLower();
            if (!allowedExtensions.Contains(fileExtension))
            {
                throw new ValidationException("Only .jpg, .jpeg, .png, .gif files are allowed.");
            }

            // Перевірка розміру файлу (наприклад, до 5 MB)
            const long maxFileSize = 5 * 1024 * 1024; // 5 MB
            if (avatarFile.Length > maxFileSize)
            {
                throw new ValidationException("File size exceeds 5 MB limit.");
            }

            // Визначаємо шлях до папки wwwroot/avatars
            string uploadsFolder = Path.Combine(_hostEnvironment.ContentRootPath, "wwwroot", "avatars");

            // Створюємо папку, якщо вона не існує
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            // Генеруємо унікальне ім'я файлу на основі UserId, щоб уникнути конфліктів
            // і легко замінювати старий аватар на новий
            string uniqueFileName = $"{userId}{fileExtension}";
            string filePath = Path.Combine(uploadsFolder, uniqueFileName);

            // Видаляємо старий аватар, якщо він існує
            if (!string.IsNullOrEmpty(user.AvatarUrl))
            {
                string oldFilePath = Path.Combine(_hostEnvironment.ContentRootPath, user.AvatarUrl.TrimStart('/'));
                if (File.Exists(oldFilePath))
                {
                    File.Delete(oldFilePath);
                }
            }

            // Зберігаємо новий файл
            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await avatarFile.CopyToAsync(fileStream);
            }

            // Оновлюємо AvatarUrl в моделі User
            // Ми зберігаємо відносний шлях, який буде доступний через Static Files Middleware
            user.AvatarUrl = $"/avatars/{uniqueFileName}";
            user.UpdatedDate = DateTime.UtcNow;

            await _userRepository.SaveChangesAsync();

            return user.AvatarUrl; // Повертаємо URL аватара
        }

        public async Task DeleteUserAvatarAsync(Guid userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
            {
                throw new NotFoundException($"User with Id: {userId} not found.");
            }

            if (string.IsNullOrEmpty(user.AvatarUrl))
            {
                throw new ValidationException("User does not have an avatar to delete.");
            }

            // Визначаємо шлях до файлу аватара
            string filePath = Path.Combine(_hostEnvironment.ContentRootPath, user.AvatarUrl.TrimStart('/'));

            // Видаляємо файл, якщо він існує
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }

            // Оновлюємо AvatarUrl в моделі User
            user.AvatarUrl = null;
            user.UpdatedDate = DateTime.UtcNow;

            await _userRepository.SaveChangesAsync();
        }

        public async Task<AuthResultDto?> LoginAsync(UserLoginDto dto)
        {
            var user = await _userRepository.GetByEmailAsync(dto.Email);
            if (user == null)
            {
                return null;
            }
            var result = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, dto.Password);
            if (result == PasswordVerificationResult.Failed)
            {
                return null;
            }
            var token = await _tokenService.GenerateTokenAsync(user.Id, user.Email, user.Role);

            return new AuthResultDto(
                Token: token,
                Email: user.Email,
                Role: user.Role.ToString(),
                Name: user.FirstName ?? user.Email.Split('@')[0]
            );
        }

        public async Task<Guid> AdminCreateUserAsync(AdminCreateUserDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email) || string.IsNullOrWhiteSpace(dto.Password))
            {
                throw new ValidationException("Email and password cannot be empty.");
            }

            var existingUser = await _userRepository.GetByEmailAsync(dto.Email);
            if (existingUser != null)
            {
                throw new ValidationException($"User with email '{dto.Email}' already exists.");
            }

            var newUser = new User
            {
                Email = dto.Email,
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Role = dto.Role,
                // CreatedDate та UpdatedDate встановлюються в BaseEntity або через механізми EF Core
            };

            var hashedPassword = _passwordHasher.HashPassword(newUser, dto.Password);
            newUser.PasswordHash = hashedPassword;

            await _userRepository.AddAsync(newUser);
            await _userRepository.SaveChangesAsync();

            return newUser.Id;
        }

        public async Task UpdateUserAsync(Guid userId, UpdateUserDto dto)
        {
            var currentUserId = _currentUserService.GetUserId();

            if (currentUserId == userId)
            {
                throw new ValidationException("It is not possible to update the current active user's role or email via this endpoint.");
            }

            var userToUpdate = await _userRepository.GetByIdAsync(userId);
            if (userToUpdate == null)
            {
                throw new NotFoundException($"User with Id: {userId} not found.");
            }

            if (userToUpdate.Email != dto.Email)
            {
                var existingUserWithNewEmail = await _userRepository.GetByEmailAsync(dto.Email);
                if (existingUserWithNewEmail != null && existingUserWithNewEmail.Id != userId)
                {
                    throw new ValidationException($"User with email '{dto.Email}' already exists.");
                }
            }

            userToUpdate.FirstName = dto.FirstName;
            userToUpdate.LastName = dto.LastName;
            userToUpdate.Email = dto.Email;
            userToUpdate.Role = dto.Role;
            userToUpdate.UpdatedDate = DateTime.UtcNow;

            if (!string.IsNullOrWhiteSpace(dto.Password))
            {
                userToUpdate.PasswordHash = _passwordHasher.HashPassword(userToUpdate, dto.Password);
            }

            await _userRepository.SaveChangesAsync();
        }

        public async Task UpdateUserProfileAsync(Guid userId, UpdateProfileDto dto)
        {
            var userToUpdate = await _userRepository.GetByIdAsync(userId);
            if (userToUpdate == null)
            {
                throw new NotFoundException($"User with Id: {userId} not found.");
            }

            if (!string.IsNullOrWhiteSpace(dto.NewPassword))
            {
                if (string.IsNullOrWhiteSpace(dto.OldPassword))
                {
                    throw new ValidationException("Old password is required to change password.");
                }

                var verifyResult = _passwordHasher.VerifyHashedPassword(userToUpdate, userToUpdate.PasswordHash, dto.OldPassword);
                if (verifyResult == PasswordVerificationResult.Failed)
                {
                    throw new ValidationException("Incorrect old password.");
                }
                userToUpdate.PasswordHash = _passwordHasher.HashPassword(userToUpdate, dto.NewPassword);
            }

            if (userToUpdate.Email != dto.Email)
            {
                var existingUserWithNewEmail = await _userRepository.GetByEmailAsync(dto.Email);
                if (existingUserWithNewEmail != null && existingUserWithNewEmail.Id != userId)
                {
                    throw new ValidationException($"User with email '{dto.Email}' already exists.");
                }
            }

            userToUpdate.FirstName = dto.FirstName;
            userToUpdate.LastName = dto.LastName;
            userToUpdate.Email = dto.Email;
            userToUpdate.UpdatedDate = DateTime.UtcNow;

            await _userRepository.SaveChangesAsync();
        }

        public async Task DeleteUserAsync(Guid userId)
        {
            var currentUserId = _currentUserService.GetUserId();

            if (currentUserId == userId)
            {
                throw new ValidationException("It is not possible to delete the current active user.");
            }

            var userToDelete = await _userRepository.GetByIdAsync(userId);
            if (userToDelete == null)
            {
                throw new NotFoundException($"User with Id: {userId} not found.");
            }

            await _userRepository.RemoveAsync(userToDelete);
            await _userRepository.SaveChangesAsync();
        }

        public async Task UpdateFcmTokenAsync(Guid userId, string token)
        {
            // Знаходимо користувача
            var user = await _userRepository.GetByIdAsync(userId);

            if (user == null)
            {
                throw new NotFoundException($"User with ID {userId} not found.");
            }

            // Оновлюємо токен
            user.FcmToken = token;

            // Зберігаємо
            await _userRepository.SaveChangesAsync(); // або _unitOfWork.SaveAsync()
        }
        
        public async Task<string?> GetUserFcmTokenAsync(Guid userId)
        {
            var user = await _userRepository.GetByIdAsync(userId); 
            
            if (user == null) return null;
            
            return user.FcmToken;
        }

    }
}