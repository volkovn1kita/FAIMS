using Application.DTOs;
using Application.Interfaces;
using Domain;
using Domain.Exceptions;
using System.Linq; // Add this for LINQ extensions
using System.Collections.Generic; // Add this for List

namespace Application.Services;

public class FirstAidKitService : IFirstAidKitService
{
    private readonly IFirstAidKitRepository _kitRepository;
    private readonly IUserRepository _userRepository;
    private readonly IDepartmentRepository _departmentRepository;
    private readonly IJournalRepository _journalRepository;
    private readonly ICurrentUserService _currentUserService;

    public FirstAidKitService(IFirstAidKitRepository firstAidKitRepository,
                                  IUserRepository userRepository,
                                  IDepartmentRepository departmentRepository,
                                  IJournalRepository journalRepository,
                                  ICurrentUserService currentUserService)
    {
        _departmentRepository = departmentRepository;
        _kitRepository = firstAidKitRepository;
        _userRepository = userRepository;
        _journalRepository = journalRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> AddKitAsync(FirstAidKitCreateDto dto)
    {
        var existedKit = await _kitRepository.GetKitByUniqueNumberAsync(dto.UniqueNumber);
        if (existedKit != null)
        {
            throw new ValidationException("Aid kit with this unique number is already exist");
        }

        var room = await _departmentRepository.GetRoomByIdAsync(dto.RoomId);
        if (room == null)
        {
            throw new NotFoundException("Room is not found");
        }

        var user = await _userRepository.GetByIdAsync(dto.ResponsibleUserId);
        if (user == null)
        {
            throw new NotFoundException("Responsible user is not found");
        }

        var newKit = new FirstAidKit
        {
            UniqueNumber = dto.UniqueNumber,
            Name = dto.Name,
            RoomId = dto.RoomId,
            ResponsibleUserId = dto.ResponsibleUserId,
        };

        await _kitRepository.AddKitAsync(newKit);
        await _kitRepository.SaveChangesAsync();

        return newKit.Id;
    }

    public async Task<FirstAidKitListDto?> GetKitByResponsibleUserIdAsync(Guid userId)
    {
        var kit = await _kitRepository.GetKitByResponsibleUserIdAsync(userId);
        if (kit == null)
            return null;

        int criticalCount = kit.Medications.Count(m => m.ExpirationDate <= DateTime.UtcNow.AddDays(30) && m.ExpirationDate > DateTime.UtcNow);
        int expiredCount = kit.Medications.Count(m => m.ExpirationDate <= DateTime.UtcNow);
        int lowQuantityCount = kit.Medications.Count(m => m.Quantity < m.MinimumQuantity);

        string currentStatusBadge = "Good";
        if (expiredCount > 0 || criticalCount > 0 || lowQuantityCount > 0)
            currentStatusBadge = "Needs Attention";

        return new FirstAidKitListDto(
            Id: kit.Id,
            DepartmentId: kit.Room?.Department?.Id ?? Guid.Empty,
            ResponsibleUserId: kit.ResponsibleUser?.Id ?? Guid.Empty,
            RoomId: kit.Room?.Id ?? Guid.Empty,
            UniqueNumber: kit.UniqueNumber,
            Name: kit.Name,
            DepartmentName: kit.Room?.Department?.Name ?? "N/A",
            RoomName: kit.Room?.Name ?? "N/A",
            ResponsibleUserFirstName: kit.ResponsibleUser?.FirstName ?? "N/A",
            ResponsibleUserLastName: kit.ResponsibleUser?.LastName ?? "",
            CriticalItemsCount: criticalCount,
            ExpiredItemsCount: expiredCount,
            LowQuantityItemsCount: lowQuantityCount,
            CreatedAt: kit.CreatedDate,
            UpdatedAt: kit.UpdatedDate,
            StatusBadge: currentStatusBadge
        );
    }


    public async Task<IEnumerable<FirstAidKitListDto>> GetFilteredFirstAidKitsAsync(
        string? searchTerm,
        string? statusFilter,
        Guid? responsibleUserId,
        Guid? departmentId)
    {
        var kits = await _kitRepository.GetFilteredKitsAsync(searchTerm, responsibleUserId, departmentId);
        var result = new List<FirstAidKitListDto>();

        foreach (var kit in kits)
        {
            int criticalCount = kit.Medications.Count(m => m.ExpirationDate <= DateTime.UtcNow.AddDays(30));
            int expiredCount = kit.Medications.Count(m => m.ExpirationDate <= DateTime.UtcNow);
            int lowQuantityCount = kit.Medications.Count(m => m.Quantity < m.MinimumQuantity);

            string currentStatusBadge;
            // if (expiredCount > 0 || criticalCount > 0)
            // {
            //     currentStatusBadge = "Needs Attention";
            // }
            // else if (lowQuantityCount > 0)
            // {
            //     currentStatusBadge = "Low Stock";
            // }
            // else
            // {
            //     currentStatusBadge = "Good";
            // }
            
            if (expiredCount > 0 || criticalCount > 0 || lowQuantityCount > 0)
                currentStatusBadge = "Needs Attention";
            else
                currentStatusBadge = "Good";


            if (!string.IsNullOrWhiteSpace(statusFilter))
            {
                if (statusFilter != "All" && !string.Equals(currentStatusBadge, statusFilter, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }
            }

            result.Add(new FirstAidKitListDto(
                Id: kit.Id,
                DepartmentId: kit.Room?.Department?.Id ?? Guid.Empty,
                ResponsibleUserId: kit.ResponsibleUser?.Id ?? Guid.Empty,
                RoomId: kit.Room?.Id ?? Guid.Empty,
                UniqueNumber: kit.UniqueNumber,
                Name: kit.Name,
                DepartmentName: kit.Room?.Department?.Name ?? "N/A",
                RoomName: kit.Room?.Name ?? "N/A",
                ResponsibleUserFirstName: kit.ResponsibleUser?.FirstName ?? "N/A",
                ResponsibleUserLastName: kit.ResponsibleUser?.LastName ?? "",
                CriticalItemsCount: criticalCount,
                ExpiredItemsCount: expiredCount,
                LowQuantityItemsCount: lowQuantityCount,
                CreatedAt: kit.CreatedDate,
                UpdatedAt: kit.UpdatedDate,
                StatusBadge: currentStatusBadge
                ));
        }
        return result;

    }

    public async Task<FirstAidKitListDto> GetKitByIdAsync(Guid id)
    {
        var kit = await _kitRepository.GetKitByIdAsync(id);
        if (kit == null)
        {
            throw new NotFoundException("Aid kit is not found");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRole = _currentUserService.GetUserRole();

        if (currentUserRole != nameof(UserRole.Administrator) && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You are not authorized to view this kit.");
        }

        int criticalCount = kit.Medications.Count(m => m.ExpirationDate <= DateTime.UtcNow.AddDays(30) && m.ExpirationDate > DateTime.UtcNow);
        int expiredCount = kit.Medications.Count(m => m.ExpirationDate <= DateTime.UtcNow);
        int lowQuantityCount = kit.Medications.Count(m => m.Quantity < m.MinimumQuantity);

        string currentStatusBadge = "Good";
        if (expiredCount > 0)
        {
            currentStatusBadge = "Needs Attention";
        }
        else if (criticalCount > 0)
        {
            currentStatusBadge = "Needs Attention";
        }
        else if (lowQuantityCount > 0)
        {
            currentStatusBadge = "Low Stock";
        }

        return new FirstAidKitListDto(
            Id: kit.Id,
            DepartmentId: kit.Room?.Department?.Id ?? Guid.Empty,
            ResponsibleUserId: kit.ResponsibleUser?.Id ?? Guid.Empty,
            RoomId: kit.Room?.Id ?? Guid.Empty,
            UniqueNumber: kit.UniqueNumber,
            Name: kit.Name,
            DepartmentName: kit.Room?.Department?.Name ?? "N/A",
            RoomName: kit.Room?.Name ?? "N/A",
            ResponsibleUserFirstName: kit.ResponsibleUser?.FirstName ?? "N/A",
            ResponsibleUserLastName: kit.ResponsibleUser?.LastName ?? "",
            CriticalItemsCount: criticalCount,
            ExpiredItemsCount: expiredCount,
            LowQuantityItemsCount: lowQuantityCount,
            CreatedAt: kit.CreatedDate,
            UpdatedAt: kit.UpdatedDate,
            StatusBadge: currentStatusBadge
        );
    }

    public async Task UpdateKitAsync(FirstAidKitUpdateDto dto)
    {
        var kitToUpdate = await _kitRepository.GetKitByIdAsync(dto.Id);
        if (kitToUpdate == null)
        {
            throw new NotFoundException("Aid kit is not found");
        }
        var room = await _departmentRepository.GetRoomByIdAsync(dto.RoomId);
        if (room == null)
        {
            throw new NotFoundException("Room is not found");
        }
        var responsibleUser = await _userRepository.GetByIdAsync(dto.ResponsibleUserId);
        if (responsibleUser == null)
        {
            throw new NotFoundException("User is not found");
        }

        kitToUpdate.Name = dto.Name;
        kitToUpdate.RoomId = dto.RoomId;
        kitToUpdate.ResponsibleUserId = dto.ResponsibleUserId;
        kitToUpdate.UpdatedDate = DateTime.UtcNow;

        await _kitRepository.UpdateKitAsync(kitToUpdate);
        await _kitRepository.SaveChangesAsync();
    }

    public async Task DeleteKitAsync(Guid id)
    {
        var kitToDelete = await _kitRepository.GetKitByIdAsync(id);
        if (kitToDelete == null)
        {
            throw new NotFoundException("Aid kit is not found");
        }

        var anyMedication = (await _kitRepository.GetMedicationsByKitIdAsync(id)).Any();
        if (anyMedication)
        {
            throw new ValidationException("In Aid kit left some medications");
        }

        await _kitRepository.DeleteKitAsync(kitToDelete);
        await _kitRepository.SaveChangesAsync();
    }

    // MEDICATIONS - UPDATED IMPLEMENTATION
    public async Task<MedicationResponseDto> GetMedicationByIdAsync(Guid id)
    {
        var medication = await _kitRepository.GetMedicationByIdAsync(id);
        if (medication == null)
        {
            throw new NotFoundException($"The medication with Id: {id} was not found.");
        }

        var kit = await _kitRepository.GetKitByIdAsync(medication.FirstAidKitId); // Needs kit details for auth
        if (kit == null)
        {
            throw new NotFoundException($"The kit of medication was not found.");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRole = _currentUserService.GetUserRole();

        if (currentUserRole != UserRole.Administrator.ToString() && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You cannot get medication to this first aid kit.");
        }

        // Manual mapping to DTO
        return new MedicationResponseDto(
            Id: medication.Id,
            Name: medication.Name,
            Quantity: medication.Quantity,
            ExpirationDate: medication.ExpirationDate,
            MinimumQuantity: medication.MinimumQuantity,
            Unit: medication.Unit,
            Status: medication.Status,
            FirstAidKitId: medication.FirstAidKitId
        );
    }

    public async Task<IEnumerable<MedicationResponseDto>> GetMedicationsByKitIdAsync(Guid kitId)
    {
        var kit = await _kitRepository.GetKitByIdAsync(kitId); // Needs kit details for auth
        if (kit == null)
        {
            throw new NotFoundException($"First aid kit with Id: {kitId} not found.");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRole = _currentUserService.GetUserRole();

        if (currentUserRole != UserRole.Administrator.ToString() && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You do not have access to the contents of this first aid kit.");
        }

        var medications = await _kitRepository.GetMedicationsByKitIdAsync(kitId);

        return medications.Select(medication => new MedicationResponseDto(
            Id: medication.Id,
            Name: medication.Name,
            Quantity: medication.Quantity,
            ExpirationDate: medication.ExpirationDate,
            MinimumQuantity: medication.MinimumQuantity,
            Unit: medication.Unit,
            Status: medication.Status,
            FirstAidKitId: medication.FirstAidKitId
        )).ToList();
    }

    public async Task<Guid> AddMedicationAsync(MedicationCreateDto dto)
    {
        dto = dto with { ExpirationDate = DateTime.SpecifyKind(dto.ExpirationDate, DateTimeKind.Utc) };

        var kit = await _kitRepository.GetKitByIdAsync(dto.FirstAidKitId);
        if (kit == null)
        {
            throw new NotFoundException("Aid kit is not found");
        }
        if (dto.ExpirationDate <= DateTime.UtcNow)
        {
            throw new ValidationException("Could not add expired medication");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRole = _currentUserService.GetUserRole();

        if (currentUserRole != UserRole.Administrator.ToString() && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You cannot add medications to this first aid kit.");
        }

        var existingBatch = await _kitRepository.GetMedicationByBatchAsync
        (
            dto.FirstAidKitId,
            dto.Name,
            dto.ExpirationDate
        );

        if (existingBatch != null)
        {
            var oldQuantity = existingBatch.Quantity;
            existingBatch.Quantity += dto.Quantity;
            existingBatch.UpdatedDate = DateTime.UtcNow;

            await _kitRepository.SaveChangesAsync();

            await _journalRepository.AddEntryAsync(new Journal
            {
                ActionType = JournalAction.QuantityChanged,
                Reason = $"Medication '{existingBatch.Name}' replenished. Quantity changed from {oldQuantity} to {existingBatch.Quantity}.",
                FirstAidKitId = dto.FirstAidKitId,
                MedicationName = dto.Name,
                UserId = _currentUserService.GetUserId(),
                BatchId = existingBatch.Id,
                Quantity = dto.Quantity,
                Unit = existingBatch.Unit
            });

            return existingBatch.Id;
        }

        var newMedication = new Medication
        {
            FirstAidKitId = dto.FirstAidKitId,
            Name = dto.Name,
            Quantity = dto.Quantity,
            MinimumQuantity = dto.MinimumQuantity,
            Unit = dto.Unit,
            ExpirationDate = dto.ExpirationDate
        };

        await _kitRepository.AddMedicationToKitAsync(newMedication, dto.FirstAidKitId);

        await _journalRepository.AddEntryAsync(new Journal
        {
            ActionType = JournalAction.Added,
            Reason = $"New medication '{newMedication.Name}' added with quantity {newMedication.Quantity} {newMedication.Unit}.",
            FirstAidKitId = dto.FirstAidKitId,
            MedicationName = newMedication.Name,
            UserId = _currentUserService.GetUserId(),
            BatchId = newMedication.Id,
            Quantity = dto.Quantity,
            Unit = newMedication.Unit
        });

        await _kitRepository.SaveChangesAsync();

        return newMedication.Id;

    }

    public async Task UpdateMedicationAsync(MedicationUpdateDto dto)
    {
        var medToUpdate = await _kitRepository.GetMedicationByIdAsync(dto.Id);
        if (medToUpdate == null)
        {
            throw new NotFoundException($"The medication with Id: {dto.Id} was not found.");
        }

        // Перевірка, чи належить медикамент до вказаної аптечки (додаткова безпека)
        if (medToUpdate.FirstAidKitId != dto.FirstAidKitId)
        {
            throw new ValidationException("It is impossible to update the medication: the first aid kit is not compliant.");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRoleString = _currentUserService.GetUserRole();
        // Перетворюємо рядок ролі в enum UserRole для зручного порівняння
        if (!Enum.TryParse<UserRole>(currentUserRoleString, out var currentUserRole))
        {
            // Обробка випадку, якщо роль не може бути розпізнана
            throw new ForbiddenException("User role could not be determined.");
        }

        var kit = await _kitRepository.GetKitByIdAsync(dto.FirstAidKitId);

        if (kit == null)
        {
            throw new NotFoundException($"The kit for update medication was not found.");
        }

        // Авторизація:
        // Якщо тільки адмін може робити повне редагування через цей ендпоінт,
        // а звичайний користувач може змінювати лише minimumQuantity та expirationDate.
        // Зауваження: В контролері (як ми домовлялися), ендпоінт PUT /medications має бути
        // авторизований лише для [Authorize(Roles = nameof(UserRole.Administrator))].
        // Це додаткова перевірка, якщо раптом дозволи в контролері зміняться.
        // Або, якщо ми дозволяємо звичайному юзеру цей ендпоінт,
        // тоді логіка розмежування нижче працює.
        if (currentUserRole != UserRole.Administrator && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You cannot update medications in this first aid kit.");
        }

        // Зберігаємо старі значення для перевірок (не для журналювання, згідно з вашою вимогою)
        var oldName = medToUpdate.Name;
        var oldUnit = medToUpdate.Unit;
        var oldMinQuantity = medToUpdate.MinimumQuantity;
        var oldExpirationDate = medToUpdate.ExpirationDate;
        var oldQuantity = medToUpdate.Quantity;

        // Логіка оновлення полів залежно від ролі
        if (currentUserRole == UserRole.Administrator)
        {
            // Адміністратор може змінювати всі поля.
            // Дії адміністратора через цей ендпоінт НЕ ЖУРНАЛУЮТЬСЯ.
            medToUpdate.Name = dto.Name;
            medToUpdate.Quantity = dto.Quantity;
            medToUpdate.MinimumQuantity = dto.MinimumQuantity;
            medToUpdate.Unit = dto.Unit;
            medToUpdate.ExpirationDate = dto.ExpirationDate;
        }
        else // Звичайний користувач (відповідальна особа)
        {
            // Звичайний користувач НЕ може змінювати назву, одиниці виміру або кількість через UpdateMedicationAsync
            if (oldName != dto.Name || oldUnit != dto.Unit || oldQuantity != dto.Quantity)
            {
                throw new ForbiddenException("Only administrators can change medication name, unit, or quantity directly. Use specific actions for quantity changes for regular users.");
            }

            // Звичайний користувач може змінювати лише MinimumQuantity та ExpirationDate
            medToUpdate.MinimumQuantity = dto.MinimumQuantity;
            medToUpdate.ExpirationDate = dto.ExpirationDate;

            // *** Журналювання для дій звичайного користувача через цей ендпоінт
            // Згідно з вашою логікою, звичайний користувач через UpdateMedicationAsync
            // може змінити лише MinimumQuantity та ExpirationDate. Ці зміни МОЖУТЬ бути залоговані.
            // Якщо і ці зміни не потрібно логувати, видаліть блок if (changes.Any()) нижче
            // або зробіть його більш специфічним.
            var changesForUser = new List<string>();
            if (oldMinQuantity != dto.MinimumQuantity)
            {
                changesForUser.Add($"Minimum quantity from {oldMinQuantity} to {dto.MinimumQuantity}");
            }
            if (oldExpirationDate != dto.ExpirationDate)
            {
                changesForUser.Add($"Expiration date from {oldExpirationDate.ToShortDateString()} to {dto.ExpirationDate.ToShortDateString()}");
            }

        }

        medToUpdate.UpdatedDate = DateTime.UtcNow;

        await _kitRepository.UpdateMedicationInKit(medToUpdate);
        await _kitRepository.SaveChangesAsync();

    }

    // НОВИЙ МЕТОД: Використання медикаменту
    public async Task UseMedicationAsync(Guid medicationId, int quantityUsed)
    {
        if (quantityUsed <= 0)
        {
            throw new ValidationException("Quantity used must be greater than zero.");
        }

        var medication = await _kitRepository.GetMedicationByIdAsync(medicationId);
        if (medication == null)
        {
            throw new NotFoundException($"Medication with Id: {medicationId} was not found.");
        }

        var kit = await _kitRepository.GetKitByIdAsync(medication.FirstAidKitId);
        if (kit == null)
        {
            throw new NotFoundException($"The kit for medication was not found.");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRole = _currentUserService.GetUserRole();

        if (currentUserRole != UserRole.Administrator.ToString() && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You cannot use medications from this first aid kit.");
        }

        if (medication.Quantity < quantityUsed)
        {
            throw new ValidationException($"Not enough '{medication.Name}' available. Current quantity: {medication.Quantity}, requested to use: {quantityUsed}.");
        }

        var oldQuantity = medication.Quantity;
        medication.Quantity -= quantityUsed;
        medication.UpdatedDate = DateTime.UtcNow;

        await _kitRepository.UpdateMedicationInKit(medication);

        await _journalRepository.AddEntryAsync(new Journal
        {
            ActionType = JournalAction.Used,
            Reason = $"Medication '{medication.Name}' used. Quantity changed from {oldQuantity} to {medication.Quantity}. Used {quantityUsed} {medication.Unit}.",
            FirstAidKitId = medication.FirstAidKitId,
            MedicationName = medication.Name,
            UserId = currentUserId,
            BatchId = medication.Id,
            Quantity = quantityUsed,
            Unit = medication.Unit
        });

        await _kitRepository.SaveChangesAsync();
    }

    // НОВИЙ МЕТОД: Списання медикаменту
    public async Task WriteOffMedicationAsync(Guid medicationId, int quantityWrittenOff, string reason)
    {
        if (quantityWrittenOff <= 0)
        {
            throw new ValidationException("Quantity to write off must be greater than zero.");
        }
        if (string.IsNullOrWhiteSpace(reason))
        {
            throw new ValidationException("Reason for writing off medication is required.");
        }

        var medication = await _kitRepository.GetMedicationByIdAsync(medicationId);
        if (medication == null)
        {
            throw new NotFoundException($"Medication with Id: {medicationId} was not found.");
        }

        var kit = await _kitRepository.GetKitByIdAsync(medication.FirstAidKitId);
        if (kit == null)
        {
            throw new NotFoundException($"The kit for medication was not found.");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRole = _currentUserService.GetUserRole();

        if (currentUserRole != UserRole.Administrator.ToString() && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You cannot write off medications from this first aid kit.");
        }

        if (medication.Quantity < quantityWrittenOff)
        {
            throw new ValidationException($"Not enough '{medication.Name}' available to write off. Current quantity: {medication.Quantity}, requested to write off: {quantityWrittenOff}.");
        }

        var oldQuantity = medication.Quantity;
        medication.Quantity -= quantityWrittenOff;
        medication.UpdatedDate = DateTime.UtcNow;

        await _kitRepository.UpdateMedicationInKit(medication);

        await _journalRepository.AddEntryAsync(new Journal
        {
            ActionType = JournalAction.WrittenOff, // Використовуємо новий тип дії
            Reason = $"Medication '{medication.Name}' written off. Quantity changed from {oldQuantity} to {medication.Quantity}. Written off {quantityWrittenOff} {medication.Unit}. Reason: {reason}",
            FirstAidKitId = medication.FirstAidKitId,
            MedicationName = medication.Name,
            UserId = currentUserId,
            BatchId = medication.Id,
            Quantity = quantityWrittenOff,
            Unit = medication.Unit
        });

        await _kitRepository.SaveChangesAsync();
    }


    public async Task RemoveMedicationAsync(Guid medicationId, Guid kitId)
    {
        var medToDelete = await _kitRepository.GetMedicationByIdAsync(medicationId);

        if (medToDelete == null) return; // If medication not found, gracefully exit or throw specific error

        if (medToDelete.FirstAidKitId != kitId)
        {
            throw new ValidationException("First aid kit mismatch. The medication does not belong in the specified first aid kit.");
        }

        if (medToDelete.Quantity > 0)
        {
            throw new ValidationException($"Unable to delete the record for ‘{medToDelete.Name}’. Please write off the remaining quantity first: {medToDelete.Quantity}.");
        }

        var kit = await _kitRepository.GetKitByIdAsync(kitId);
        if (kit == null)
        {
            throw new NotFoundException($"The kit for delete medication was not found.");
        }

        var currentUserId = _currentUserService.GetUserId();
        var currentUserRole = _currentUserService.GetUserRole();
        if (currentUserRole != UserRole.Administrator.ToString() && kit.ResponsibleUserId != currentUserId)
        {
            throw new ForbiddenException("You cannot delete medications to this first aid kit.");
        }

        await _kitRepository.RemoveMedicationFromKit(medToDelete, kitId);

        await _journalRepository.AddEntryAsync(new Journal
        {
            ActionType = JournalAction.Removed,
            Reason = $"The record for {medToDelete.Name} (batch {medToDelete.Id}) has been fully deleted from the system (quantity was 0).",
            FirstAidKitId = kitId,
            MedicationName = medToDelete.Name,
            UserId = _currentUserService.GetUserId(),
            BatchId = medToDelete.Id,
            Quantity = 0,
            Unit = medToDelete.Unit
        });

        await _kitRepository.SaveChangesAsync();
    }

}