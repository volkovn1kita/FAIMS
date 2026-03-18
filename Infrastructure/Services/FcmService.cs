using Application.Interfaces;
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
    public class FcmService : INotificationService
    {
        private readonly FirebaseMessaging _messaging;

        public FcmService(IConfiguration configuration)
        {
            if (FirebaseApp.DefaultInstance == null)
            {
                var pathToKey = Path.Combine(Directory.GetCurrentDirectory(), "faims-baaab-firebase-adminsdk-fbsvc-4a8578170b.json");
                
                // Перевіряємо, чи файл дійсно лежить там, де ми очікуємо
                if (!File.Exists(pathToKey))
                {
                    throw new FileNotFoundException($"❌ УВАГА! Файл ключів Firebase не знайдено за адресою: {pathToKey}");
                }
                
                Console.WriteLine($"✅ Читаємо Firebase ключ з: {pathToKey}");

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
                Console.WriteLine("✅ Пуш-сповіщення УСПІШНО відправлено на Firebase!");
            }
            catch(Exception ex)
            {
                Console.WriteLine($"❌ Error sending FCM: {ex.Message}");
            }
        }
    }
}