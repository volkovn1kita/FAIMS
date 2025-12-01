using System;
using Application.DTOs;
using Domain;

namespace Application.Interfaces;

public interface IFirstAidKitService
{
    Task<Guid> AddKitAsync(FirstAidKitCreateDto dto);
    Task<FirstAidKitListDto> GetKitByIdAsync(Guid id);
    Task<FirstAidKitListDto?> GetKitByResponsibleUserIdAsync(Guid userId);

    //Task<IEnumerable<FirstAidKitListDto>> GetAllKitsAsync();
    Task<IEnumerable<FirstAidKitListDto>> GetFilteredFirstAidKitsAsync(
        string? searchTerm,
        string? statusFilter,
        Guid? responsibleUserId,
        Guid? departmentId);
    Task UpdateKitAsync(FirstAidKitUpdateDto dto);
    Task DeleteKitAsync(Guid id);

    Task<MedicationResponseDto> GetMedicationByIdAsync(Guid id);
    Task<IEnumerable<MedicationResponseDto>> GetMedicationsByKitIdAsync(Guid kitId);
    Task<Guid> AddMedicationAsync(MedicationCreateDto dto);
    Task UpdateMedicationAsync(MedicationUpdateDto dto);
    Task RemoveMedicationAsync(Guid medicationId, Guid kitId);
    Task UseMedicationAsync(Guid medicationId, int quantityUsed);
    Task WriteOffMedicationAsync(Guid medicationId, int quantityWrittenOff, string reason);
}
