
namespace Domain.Interfaces
{
    public interface IMustHaveTenant
    {
        Guid OrganizationId { get; set; }
    }
}