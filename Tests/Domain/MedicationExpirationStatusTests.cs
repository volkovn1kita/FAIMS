using Domain;
using Xunit;

namespace Tests.Domain;

public class MedicationExpirationStatusTests
{
    private static Medication CreateMedication(DateTime expirationDate) => new()
    {
        Name = "Test",
        Quantity = 10,
        MinimumQuantity = 1,
        Unit = MeasurementUnit.Tablets,
        ExpirationDate = expirationDate,
    };

    [Fact]
    public void Status_IsGood_WhenMoreThan90DaysLeft()
    {
        var med = CreateMedication(DateTime.UtcNow.AddDays(120));
        Assert.Equal(ExpirationStatus.Good, med.Status);
    }

    [Fact]
    public void Status_IsWarning_WhenBetween31And90DaysLeft()
    {
        var med = CreateMedication(DateTime.UtcNow.AddDays(60));
        Assert.Equal(ExpirationStatus.Warning, med.Status);
    }

    [Fact]
    public void Status_IsCritical_WhenBetween1And30DaysLeft()
    {
        var med = CreateMedication(DateTime.UtcNow.AddDays(15));
        Assert.Equal(ExpirationStatus.Critical, med.Status);
    }

    [Fact]
    public void Status_IsExpired_WhenDateIsInPast()
    {
        var med = CreateMedication(DateTime.UtcNow.AddDays(-1));
        Assert.Equal(ExpirationStatus.Expired, med.Status);
    }

    [Fact]
    public void Status_IsCritical_WhenExpiresExactlyIn30Days()
    {
        var med = CreateMedication(DateTime.UtcNow.AddDays(30));
        Assert.Equal(ExpirationStatus.Critical, med.Status);
    }

    [Fact]
    public void Status_IsWarning_WhenExpiresExactlyIn90Days()
    {
        var med = CreateMedication(DateTime.UtcNow.AddDays(90));
        Assert.Equal(ExpirationStatus.Warning, med.Status);
    }

    [Fact]
    public void Status_IsGood_WhenExpiresIn91Days()
    {
        var med = CreateMedication(DateTime.UtcNow.AddDays(91));
        Assert.Equal(ExpirationStatus.Good, med.Status);
    }
}
