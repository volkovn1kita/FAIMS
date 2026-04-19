using Application.DTOs;
using Application.Interfaces;
using Domain;

namespace Application.Services;

public class KitTemplateService : IKitTemplateService
{
    private readonly IKitTemplateRepository _templateRepository;
    private readonly IFirstAidKitRepository _kitRepository;
    private readonly ICurrentUserService _currentUserService;

    public KitTemplateService(
        IKitTemplateRepository templateRepository,
        IFirstAidKitRepository kitRepository,
        ICurrentUserService currentUserService)
    {
        _templateRepository = templateRepository;
        _kitRepository = kitRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IEnumerable<KitTemplateDto>> GetAllTemplatesAsync()
    {
        var templates = await _templateRepository.GetAllAsync();
        return templates.Select(MapToDto);
    }

    public async Task<KitTemplateDto> GetTemplateByIdAsync(Guid id)
    {
        var template = await _templateRepository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Template {id} not found.");
        return MapToDto(template);
    }

    public async Task<Guid> CreateTemplateAsync(CreateKitTemplateDto dto)
    {
        var orgId = _currentUserService.GetOrganizationId();

        var template = new KitTemplate
        {
            Name = dto.Name,
            Description = dto.Description,
            IsSystem = false,
            OrganizationId = orgId,
            Items = dto.Items.Select(i => new KitTemplateItem
            {
                Name = i.Name,
                MinimumQuantity = i.MinimumQuantity,
                Unit = i.Unit
            }).ToList()
        };

        await _templateRepository.AddAsync(template);
        await _templateRepository.SaveChangesAsync();

        return template.Id;
    }

    public async Task UpdateTemplateAsync(Guid id, UpdateKitTemplateDto dto)
    {
        var template = await _templateRepository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Template {id} not found.");

        if (template.IsSystem)
            throw new InvalidOperationException("System templates cannot be modified.");

        template.Name = dto.Name;
        template.Description = dto.Description;

        // Soft-delete старих позицій і додаємо нові
        foreach (var item in template.Items)
        {
            item.IsDeleted = true;
            item.DeletedAt = DateTime.UtcNow;
        }

        foreach (var i in dto.Items)
        {
            template.Items.Add(new KitTemplateItem
            {
                Name = i.Name,
                MinimumQuantity = i.MinimumQuantity,
                Unit = i.Unit,
                KitTemplateId = template.Id
            });
        }

        await _templateRepository.UpdateAsync(template);
        await _templateRepository.SaveChangesAsync();
    }

    public async Task DeleteTemplateAsync(Guid id)
    {
        var template = await _templateRepository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException($"Template {id} not found.");

        if (template.IsSystem)
            throw new InvalidOperationException("System templates cannot be deleted.");

        await _templateRepository.DeleteAsync(template);
        await _templateRepository.SaveChangesAsync();
    }

    /// <summary>
    /// Застосовує шаблон до аптечки.
    /// Пропускає медикаменти з такою ж назвою, що вже є в аптечці (уникає дублів).
    /// Встановлює ExpirationDate = +1 рік як placeholder — відповідальна особа оновлює реальні дати.
    /// </summary>
    public async Task ApplyTemplateToKitAsync(Guid kitId, Guid templateId)
    {
        var template = await _templateRepository.GetByIdAsync(templateId)
            ?? throw new KeyNotFoundException($"Template {templateId} not found.");

        var kit = await _kitRepository.GetKitByIdAsync(kitId)
            ?? throw new KeyNotFoundException($"Kit {kitId} not found.");

        var orgId = _currentUserService.GetOrganizationId();
        var existingMeds = await _kitRepository.GetMedicationsByKitIdAsync(kitId);
        var existingNames = existingMeds
            .Select(m => m.Name.Trim().ToLowerInvariant())
            .ToHashSet();

        var placeholderDate = DateTime.UtcNow.AddYears(1);

        foreach (var item in template.Items.Where(i => !i.IsDeleted))
        {
            // Не дублюємо якщо вже є медикамент з такою назвою
            if (existingNames.Contains(item.Name.Trim().ToLowerInvariant()))
                continue;

            var medication = new Medication
            {
                Name = item.Name,
                Quantity = 0,
                MinimumQuantity = item.MinimumQuantity,
                Unit = item.Unit,
                ExpirationDate = placeholderDate,
                OrganizationId = orgId
            };

            await _kitRepository.AddMedicationToKitAsync(medication, kitId);
        }

        await _kitRepository.SaveChangesAsync();
    }

    private static KitTemplateDto MapToDto(KitTemplate t) => new(
        t.Id,
        t.Name,
        t.Description,
        t.IsSystem,
        t.RegulatoryReference,
        t.Items
            .Where(i => !i.IsDeleted)
            .Select(i => new KitTemplateItemDto(i.Id, i.Name, i.MinimumQuantity, i.Unit))
            .ToList()
    );
}
