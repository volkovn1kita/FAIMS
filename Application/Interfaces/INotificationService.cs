
namespace Application.Interfaces;

public interface INotificationService
{
    Task SendNotificationAsync(string token, string title, string body);
}
