using Domain.Interfaces;

namespace Domain;

public class Medication : BaseEntity, IMustHaveTenant
{
    public string Name { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public DateTime ExpirationDate { get; set; }
    public int MinimumQuantity { get; set; } = 1;
    public MeasurementUnit Unit { get; set; }
    public ExpirationStatus Status => CalculateExpirationStatus(ExpirationDate);

    public Guid FirstAidKitId { get; set; }
    public FirstAidKit FirstAidKit { get; set; } = null!;

    public Guid OrganizationId { get; set; }
    public Organization Organization { get; set; } = null!;

    private static ExpirationStatus CalculateExpirationStatus(DateTime expirationDate)
    {
        var daysLeft = (expirationDate - DateTime.UtcNow).TotalDays;

        if (daysLeft < 0) return ExpirationStatus.Expired;
        if (daysLeft <= 30) return ExpirationStatus.Critical;
        if (daysLeft <= 90) return ExpirationStatus.Warning; 
        return ExpirationStatus.Good;                         
    }

}
