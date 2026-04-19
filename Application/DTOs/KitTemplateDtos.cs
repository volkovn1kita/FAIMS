using System.ComponentModel.DataAnnotations;
using Domain;

namespace Application.DTOs;

// ─── Response ───────────────────────────────────────────────────────────────

public record KitTemplateItemDto(
    Guid Id,
    string Name,
    int MinimumQuantity,
    MeasurementUnit Unit
);

public record KitTemplateDto(
    Guid Id,
    string Name,
    string? Description,
    bool IsSystem,
    string? RegulatoryReference,
    List<KitTemplateItemDto> Items
);

// ─── Requests ───────────────────────────────────────────────────────────────

public record CreateKitTemplateItemDto(
    [Required][MaxLength(200)] string Name,
    [Range(1, 10000)] int MinimumQuantity,
    MeasurementUnit Unit
);

public record CreateKitTemplateDto(
    [Required][MaxLength(200)] string Name,
    [MaxLength(500)] string? Description,
    [Required][MinLength(1)] List<CreateKitTemplateItemDto> Items
);

public record UpdateKitTemplateDto(
    [Required][MaxLength(200)] string Name,
    [MaxLength(500)] string? Description,
    [Required][MinLength(1)] List<CreateKitTemplateItemDto> Items
);
