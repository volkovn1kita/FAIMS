using Application.Interfaces; // Додаємо цей using
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Infrastructure.Services
{
    // ВАЖЛИВО: Додаємо ": INotificationService"
    public class FcmService : INotificationService
    {
        private readonly FirebaseMessaging _messaging;

        public FcmService(IConfiguration configuration)
        {
            if (FirebaseApp.DefaultInstance == null)
            {
                var pathToKey = Path.Combine(Directory.GetCurrentDirectory(), "firebase-admin-sdk.json");
                
                FirebaseApp.Create(new AppOptions()
                {
                    Credential = GoogleCredential.FromFile(pathToKey)
                });
            }

            _messaging = FirebaseMessaging.DefaultInstance;
        }

        public async Task SendNotificationAsync(string token, string title, string body)
        {
            // Оскільки інтерфейс вимагає void Task, а SendAsync повертає string,
            // ми просто викликаємо метод і не повертаємо значення.
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
            }
            catch(Exception ex)
            {
                Console.WriteLine($"Error sending FCM: {ex.Message}");
                // Можна логувати, але не зупиняти роботу
            }
        }
    }
}