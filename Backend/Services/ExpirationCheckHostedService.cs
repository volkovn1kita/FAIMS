using Application.Interfaces; // Інтерфейс з Application
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Backend.Services
{
    public class ExpirationCheckHostedService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<ExpirationCheckHostedService> _logger;
        
        // 24 години
        private readonly TimeSpan _checkInterval = TimeSpan.FromHours(24);

        public ExpirationCheckHostedService(IServiceProvider serviceProvider, ILogger<ExpirationCheckHostedService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("💊 Background Service started.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    // Створюємо Scope, бо сервіси Application зазвичай Scoped
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        // 1. Отримуємо наш новий сервіс з Application шару
                        var alertService = scope.ServiceProvider.GetRequiredService<IExpirationAlertService>();
                        
                        // 2. Викликаємо метод (вся логіка тепер там)
                        await alertService.CheckAndNotifyExpiringMedicationsAsync();
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "❌ Error in Background Service.");
                }

                // Чекаємо наступного разу
                await Task.Delay(_checkInterval, stoppingToken);
            }
        }
    }
}