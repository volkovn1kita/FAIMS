using Application.Interfaces;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Application.Services
{
    public class ExpirationAlertService : IExpirationAlertService
    {
        private readonly IFirstAidKitRepository _repository;
        private readonly INotificationService _notificationService;
        private readonly ILogger<ExpirationAlertService> _logger;

        public ExpirationAlertService(
            IFirstAidKitRepository repository, 
            INotificationService notificationService,
            ILogger<ExpirationAlertService> logger)
        {
            _repository = repository;
            _notificationService = notificationService;
            _logger = logger;
        }

        public async Task CheckAndNotifyExpiringMedicationsAsync()
        {
            var targetDate = DateTime.UtcNow.Date.AddDays(7);
            
            _logger.LogInformation($"Checking expiration for date: {targetDate:yyyy-MM-dd}");

            // Використовуємо твій новий метод з репозиторію
            var expiringMeds = await _repository.GetMedicationsExpiringOnDateWithUsersAsync(targetDate);

            if (!expiringMeds.Any()) return;

            var medsByUser = expiringMeds
                .Where(m => m.FirstAidKit?.ResponsibleUser?.FcmToken != null)
                .GroupBy(m => m.FirstAidKit!.ResponsibleUser!);

            foreach (var group in medsByUser)
            {
                var user = group.Key;
                var count = group.Count();
                var itemName = group.First().Name;

                string body = count == 1 
                    ? $"Термін придатності '{itemName}' спливає через тиждень!" 
                    : $"Увага! {count} препаратів зіпсуються через тиждень.";

                _logger.LogInformation($"Sending alert to {user.Email}");

                await _notificationService.SendNotificationAsync(
                    user.FcmToken!,
                    "⚠️ Перевірка аптечки",
                    body
                );
            }
        }
    }
}