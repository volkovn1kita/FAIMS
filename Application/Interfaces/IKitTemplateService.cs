using Application.DTOs;

namespace Application.Interfaces;

public interface IKitTemplateService
{
    Task<IEnumerable<KitTemplateDto>> GetAllTemplatesAsync();
    Task<KitTemplateDto> GetTemplateByIdAsync(Guid id);
    Task<Guid> CreateTemplateAsync(CreateKitTemplateDto dto);
    Task UpdateTemplateAsync(Guid id, UpdateKitTemplateDto dto);
    Task DeleteTemplateAsync(Guid id);

    /// <summary>
    /// Застосовує шаблон до аптечки: створює медикаменти з мінімальними кількостями.
    /// Термін придатності встановлюється як placeholder (1 рік), що відповідальна особа оновлює.
    /// </summary>
    Task ApplyTemplateToKitAsync(Guid kitId, Guid templateId);
}
