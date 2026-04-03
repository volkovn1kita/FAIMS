using Application.Interfaces;
using Application.Services;
using Domain;
using NSubstitute;
using Xunit;

namespace Tests.Services;

public class MonitoringServiceTests
{
    private readonly IFirstAidKitRepository _kitRepo = Substitute.For<IFirstAidKitRepository>();
    private readonly MonitoringService _service;

    public MonitoringServiceTests()
    {
        _service = new MonitoringService(_kitRepo);
    }

    private static Medication Med(DateTime expiration, int qty = 10, int minQty = 5) => new()
    {
        Name = "Test",
        Quantity = qty,
        MinimumQuantity = minQty,
        Unit = MeasurementUnit.Tablets,
        ExpirationDate = expiration,
    };

    [Fact]
    public async Task CheckAllExpirations_ReturnsAllStatusKeys()
    {
        _kitRepo.GetAllMedicationsAsync().Returns([]);

        var result = await _service.CheckAllExpirationsAsync();

        Assert.Equal(4, result.Count);
        Assert.True(result.ContainsKey(ExpirationStatus.Good));
        Assert.True(result.ContainsKey(ExpirationStatus.Warning));
        Assert.True(result.ContainsKey(ExpirationStatus.Critical));
        Assert.True(result.ContainsKey(ExpirationStatus.Expired));
    }

    [Fact]
    public async Task CheckAllExpirations_CountsCorrectly()
    {
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(200)),
            Med(DateTime.UtcNow.AddDays(-1)),
            Med(DateTime.UtcNow.AddDays(-5)),
        ]);

        var result = await _service.CheckAllExpirationsAsync();

        Assert.Equal(1, result[ExpirationStatus.Good]);
        Assert.Equal(2, result[ExpirationStatus.Expired]);
        Assert.Equal(0, result[ExpirationStatus.Critical]);
    }

    [Fact]
    public async Task GetCriticalMedications_ReturnsCriticalWarningExpired()
    {
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(200)),
            Med(DateTime.UtcNow.AddDays(15)),
            Med(DateTime.UtcNow.AddDays(60)),
            Med(DateTime.UtcNow.AddDays(-1)),
        ]);

        var result = (await _service.GetCriticalMedicationsAsync()).ToList();

        Assert.Equal(3, result.Count);
        Assert.DoesNotContain(result, m => m.Status == ExpirationStatus.Good);
    }

    [Fact]
    public async Task GetCriticalMedications_ReturnsEmpty_WhenAllGood()
    {
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(200)),
            Med(DateTime.UtcNow.AddDays(150)),
        ]);

        var result = await _service.GetCriticalMedicationsAsync();

        Assert.Empty(result);
    }

    [Fact]
    public async Task GetLowQuantityMedications_ReturnsOnlyBelowMinimum()
    {
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(200), qty: 2, minQty: 5),
            Med(DateTime.UtcNow.AddDays(200), qty: 10, minQty: 5),
            Med(DateTime.UtcNow.AddDays(200), qty: 0, minQty: 3),
        ]);

        var result = (await _service.GetLowQuantityMedicationsAsync()).ToList();

        Assert.Equal(2, result.Count);
        Assert.All(result, m => Assert.True(m.Quantity < m.MinimumQuantity));
    }

    [Fact]
    public async Task GetLowQuantityMedications_ReturnsEmpty_WhenAllSufficient()
    {
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(200), qty: 10, minQty: 5),
        ]);

        var result = await _service.GetLowQuantityMedicationsAsync();

        Assert.Empty(result);
    }
}
