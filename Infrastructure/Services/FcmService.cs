using Application.Interfaces;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Infrastructure.Services
{
    public class FcmService : INotificationService
    {
        private readonly FirebaseMessaging _messaging;
        private readonly ILogger<FcmService> _logger;

        public FcmService(IConfiguration configuration, ILogger<FcmService> logger)
        {
            _logger = logger;

            if (FirebaseApp.DefaultInstance == null)
            {
                var keyFileName = configuration["Firebase:AdminSdkKeyPath"]
                    ?? "faims-baaab-firebase-adminsdk-fbsvc-4a8578170b.json";
                var pathToKey = Path.IsPathRooted(keyFileName)
                    ? keyFileName
                    : Path.Combine(Directory.GetCurrentDirectory(), keyFileName);

                if (!File.Exists(pathToKey))
                {
                    throw new FileNotFoundException($"Firebase key file not found at: {pathToKey}");
                }

                _logger.LogInformation("Loading Firebase credentials from: {Path}", pathToKey);

                FirebaseApp.Create(new AppOptions()
                {
                    Credential = GoogleCredential.FromFile(pathToKey)
                });
            }

            _messaging = FirebaseMessaging.DefaultInstance;
        }

        public async Task SendNotificationAsync(string token, string title, string body)
        {
            try
            {
                var message = new Message()
                {
                    Token = token,
                    Notification = new Notification()
                    {
                        Title = title,
                        Body = body
                    },
                    Data = new Dictionary<string, string>()
                    {
                        { "click_action", "FLUTTER_NOTIFICATION_CLICK" },
                        { "type", "expiration_warning" }
                    }
                };

                await _messaging.SendAsync(message);
                _logger.LogInformation("Push notification sent successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending FCM notification.");
            }
        }
    }
}