namespace Application.Interfaces;

public interface IExpirationAlertService
{
    Task CheckAndNotifyExpiringMedicationsAsync();
}
