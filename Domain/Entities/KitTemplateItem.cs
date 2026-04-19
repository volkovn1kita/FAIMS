namespace Domain;

/// <summary>
/// Позиція в шаблоні — назва медикаменту + мінімальна кількість + одиниця виміру.
/// Термін придатності не зберігається — він вводиться при реальному поповненні аптечки.
/// </summary>
public class KitTemplateItem : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public int MinimumQuantity { get; set; } = 1;
    public MeasurementUnit Unit { get; set; } = MeasurementUnit.Pieces;

    public Guid KitTemplateId { get; set; }
    public KitTemplate KitTemplate { get; set; } = null!;
}
