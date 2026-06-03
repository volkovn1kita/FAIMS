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

    private static Medication Med(DateTime expiration, int qty = 10, int minQty = 5, string name = "Test", Guid? kitId = null) => new()
    {
        Name = name,
        Quantity = qty,
        MinimumQuantity = minQty,
        Unit = MeasurementUnit.Tablets,
        ExpirationDate = expiration,
        FirstAidKitId = kitId ?? Guid.NewGuid(),
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
            Med(DateTime.UtcNow.AddDays(200), qty: 2, minQty: 5, name: "A"),
            Med(DateTime.UtcNow.AddDays(200), qty: 10, minQty: 5, name: "B"),
            Med(DateTime.UtcNow.AddDays(200), qty: 0, minQty: 3, name: "C"),
        ]);

        var result = (await _service.GetLowQuantityMedicationsAsync()).ToList();

        Assert.Equal(2, result.Count);
        Assert.DoesNotContain(result, m => m.Name == "B");
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

    [Fact]
    public async Task GetLowQuantityMedications_AggregatesBatchesOfSameMedicationInOneKit()
    {
        // Two batches of the same medication in the same kit, summed = 12 which is
        // above the minimum of 6. The empty (Quantity=0) phantom batch must NOT cause
        // a false low-stock flag — this is the production bug scenario.
        var kitId = Guid.NewGuid();
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(100), qty: 0,  minQty: 6, name: "Bandage", kitId: kitId),
            Med(DateTime.UtcNow.AddDays(200), qty: 12, minQty: 6, name: "Bandage", kitId: kitId),
        ]);

        var result = await _service.GetLowQuantityMedicationsAsync();

        Assert.Empty(result);
    }

    [Fact]
    public async Task GetLowQuantityMedications_FlagsGroup_WhenSumBelowMinimum()
    {
        var kitId = Guid.NewGuid();
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(100), qty: 1, minQty: 6, name: "Bandage", kitId: kitId),
            Med(DateTime.UtcNow.AddDays(200), qty: 2, minQty: 6, name: "Bandage", kitId: kitId),
        ]);

        var result = (await _service.GetLowQuantityMedicationsAsync()).ToList();

        Assert.Equal(2, result.Count);
        Assert.All(result, m => Assert.Equal("Bandage", m.Name));
    }

    [Fact]
    public async Task GetCriticalMedications_IgnoresEmptyBatches()
    {
        _kitRepo.GetAllMedicationsAsync().Returns([
            Med(DateTime.UtcNow.AddDays(-1), qty: 0, minQty: 5, name: "Empty"),
            Med(DateTime.UtcNow.AddDays(-1), qty: 4, minQty: 5, name: "Real"),
        ]);

        var result = (await _service.GetCriticalMedicationsAsync()).ToList();

        Assert.Single(result);
        Assert.Equal("Real", result[0].Name);
    }
}
