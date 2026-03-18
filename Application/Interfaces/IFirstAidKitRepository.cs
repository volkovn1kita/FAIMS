
using Domain;

namespace Application.Interfaces;

public interface IFirstAidKitRepository
{
    Task<FirstAidKit?> GetKitByIdAsync(Guid id);

    //Task<IEnumerable<FirstAidKit>> GetAllKitsAsync();
    Task<FirstAidKit?> GetKitByResponsibleUserIdAsync(Guid userId);
    Task<IEnumerable<FirstAidKit>> GetFilteredKitsAsync(
        string? searchTerm,
        Guid? responsibleUserId,
        Guid? departmentId
    );
    Task<FirstAidKit?> GetKitByRoomIdAsync (Guid roomId);
    Task AddKitAsync(FirstAidKit kit);
    Task UpdateKitAsync(FirstAidKit kit);
    Task<FirstAidKit?> GetKitByUniqueNumberAsync(string uniqueNumber);
    Task DeleteKitAsync(FirstAidKit kit);

    Task<IEnumerable<Medication>> GetMedicationsByKitIdAsync(Guid kitId);
    Task<Medication?> GetMedicationByBatchAsync(Guid kitId, string medicationName, DateTime expirationDate);
    Task<Medication?> GetMedicationByNameInKitAsync(Guid kitId, string medicationName);
    Task<Medication?> GetMedicationByIdAsync(Guid id);
    Task AddMedicationToKitAsync(Medication medication, Guid kitId);
    Task UpdateMedicationInKit(Medication medication);
    Task RemoveMedicationFromKit(Medication medication, Guid kitId);
    Task<IEnumerable<Medication>> GetAllMedicationsAsync();
    Task<IEnumerable<Medication>> GetMedicationsExpiringOnDateWithUsersAsync(DateTime date);
    Task SaveChangesAsync();
}
