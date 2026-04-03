using Domain;
using Xunit;

namespace Tests.Domain;

public class UserRoleEnumTests
{
    [Fact]
    public void HasAtLeastTwoRoles()
    {
        Assert.True(Enum.GetValues<UserRole>().Length >= 2);
    }

    [Fact]
    public void ContainsAdministrator() => Assert.Contains(UserRole.Administrator, Enum.GetValues<UserRole>());

    [Fact]
    public void ContainsUser() => Assert.Contains(UserRole.User, Enum.GetValues<UserRole>());
}
