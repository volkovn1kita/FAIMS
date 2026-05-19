using Application.Interfaces;
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
        
        private readonly TimeSpan _checkInterval = TimeSpan.FromHours(24);

        public ExpirationCheckHostedService(IServiceProvider serviceProvider, ILogger<ExpirationCheckHostedService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("💊 Background Service started.");

            // Wait until the next 12:00 Kyiv time so notifications fire predictably,
            // not on every container restart / redeploy.
            var kyivZone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Kiev");
            var nowKyiv = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, kyivZone);
            var nextRunKyiv = nowKyiv.Date.AddHours(12);
            if (nextRunKyiv <= nowKyiv) nextRunKyiv = nextRunKyiv.AddDays(1);
            var nextRunUtc = TimeZoneInfo.ConvertTimeToUtc(nextRunKyiv, kyivZone);
            var initialDelay = nextRunUtc - DateTime.UtcNow;
            _logger.LogInformation("⏰ First check at {NextRun} Kyiv time (UTC: {Utc})", nextRunKyiv, nextRunUtc);
            await Task.Delay(initialDelay, stoppingToken);

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var alertService = scope.ServiceProvider.GetRequiredService<IExpirationAlertService>();
                        
                        await alertService.CheckAndNotifyExpiringMedicationsAsync();
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "❌ Error in Background Service.");
                }
                await Task.Delay(_checkInterval, stoppingToken);
            }
        }
    }
}