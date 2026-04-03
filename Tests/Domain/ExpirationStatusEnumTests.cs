using Domain;
using Xunit;

namespace Tests.Domain;

public class ExpirationStatusEnumTests
{
    [Fact]
    public void HasExactlyFourValues()
    {
        Assert.Equal(4, Enum.GetValues<ExpirationStatus>().Length);
    }

    [Fact]
    public void ContainsGood() => Assert.Contains(ExpirationStatus.Good, Enum.GetValues<ExpirationStatus>());

    [Fact]
    public void ContainsWarning() => Assert.Contains(ExpirationStatus.Warning, Enum.GetValues<ExpirationStatus>());

    [Fact]
    public void ContainsCritical() => Assert.Contains(ExpirationStatus.Critical, Enum.GetValues<ExpirationStatus>());

    [Fact]
    public void ContainsExpired() => Assert.Contains(ExpirationStatus.Expired, Enum.GetValues<ExpirationStatus>());
}
