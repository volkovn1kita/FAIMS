namespace Domain;

/// <summary>
/// Шаблон аптечки — набір медикаментів із мінімальними кількостями.
/// IsSystem = true → системний (МОЗ), не редагується. OrganizationId = null для системних.
/// IsSystem = false → кастомний адміном конкретної організації.
/// </summary>
public class KitTemplate : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsSystem { get; set; } = false;
    public string? RegulatoryReference { get; set; }

    // null для системних шаблонів (видно всім організаціям)
    public Guid? OrganizationId { get; set; }
    public Organization? Organization { get; set; }

    public ICollection<KitTemplateItem> Items { get; set; } = new List<KitTemplateItem>();
}
