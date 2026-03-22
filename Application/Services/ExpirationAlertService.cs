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
            var today = DateTime.SpecifyKind(DateTime.UtcNow.Date, DateTimeKind.Utc);
            var in7Days = DateTime.SpecifyKind(today.AddDays(7), DateTimeKind.Utc);
            var in30Days = DateTime.SpecifyKind(today.AddDays(30), DateTimeKind.Utc);

            await ProcessExpirationAlertsAsync(in30Days, "Термін дії закінчується через 30 днів", "через місяць");
            await Task.Delay(500); 
            
            await ProcessExpirationAlertsAsync(in7Days, "Термін дії закінчується через 7 днів", "через тиждень");
            await Task.Delay(500);
            
            await ProcessExpirationAlertsAsync(today, "Термін дії вичерпано", "сьогодні");
            await Task.Delay(500);
            
            await ProcessLowStockAlertsAsync();
        }

        private async Task ProcessExpirationAlertsAsync(DateTime targetDate, string title, string timeFrame)
        {
            var expiringMeds = await _repository.GetMedicationsExpiringOnDateWithUsersAsync(targetDate);
            if (!expiringMeds.Any()) return;

            var medsByUser = expiringMeds
                .Where(m => m.FirstAidKit?.ResponsibleUser?.FcmToken != null)
                .GroupBy(m => m.FirstAidKit!.ResponsibleUser!);

            foreach (var group in medsByUser)
            {
                var user = group.Key;
                var count = group.Count();
                var firstItem = group.First();
                var kitName = firstItem.FirstAidKit?.Name ?? "Аптечка";

                string body = count == 1 
                    ? $"Термін придатності '{firstItem.Name}' в '{kitName}' спливає {timeFrame}!" 
                    : $"Увага! {count} препаратів у '{kitName}' зіпсуються {timeFrame}.";

                await _notificationService.SendNotificationAsync(user.FcmToken!, $"⚠️ {title}", body);
            }
        }

        private async Task ProcessLowStockAlertsAsync()
        {
            var lowStockMeds = await _repository.GetLowStockMedicationsWithUsersAsync();
            if (!lowStockMeds.Any()) return;

            var medsByUser = lowStockMeds
                .Where(m => m.FirstAidKit?.ResponsibleUser?.FcmToken != null)
                .GroupBy(m => m.FirstAidKit!.ResponsibleUser!);

            foreach (var group in medsByUser)
            {
                var user = group.Key;
                var count = group.Count();
                var firstItem = group.First();
                var kitName = firstItem.FirstAidKit?.Name ?? "Аптечка";

                string body = count == 1 
                    ? $"Дефіцит: '{firstItem.Name}' в '{kitName}' (залишок: {firstItem.Quantity} з {firstItem.MinimumQuantity})." 
                    : $"Увага! {count} препаратів у '{kitName}' в дефіциті. Поповніть запаси.";

                await _notificationService.SendNotificationAsync(user.FcmToken!, "📉 Дефіцит препаратів", body);
            }
        }
    }
}