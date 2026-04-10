using Bogus;
using Domain;
using Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Seeders;

public static class DatabaseSeeder
{
    // ====== Configuration ======
    private const int OrganizationCount = 5;
    private const int DepartmentsPerOrgMin = 4;
    private const int DepartmentsPerOrgMax = 7;
    private const int RoomsPerDeptMin = 3;
    private const int RoomsPerDeptMax = 6;
    // ResponsibleUsers per org (each becomes responsible for exactly one kit)
    private const int ResponsibleUsersPerOrgMin = 8;
    private const int ResponsibleUsersPerOrgMax = 14;
    private const int MedicationsPerKitMin = 12;
    private const int MedicationsPerKitMax = 25;
    private const int JournalsPerKitMin = 5;
    private const int JournalsPerKitMax = 15;

    // Static seed so usernames/passwords are reproducible across runs
    private const int RandomizerSeed = 20260410;

    private static readonly string[] OrganizationNames =
    {
        "Клініка \"Добробут\"",
        "Медичний центр \"Оберіг\"",
        "Лікарня \"Святої Катерини\"",
        "Поліклініка №3 м. Києва",
        "Медцентр \"Здоров'я родини\"",
    };

    private static readonly string[] OrganizationAddresses =
    {
        "м. Київ, вул. Хрещатик, 22",
        "м. Львів, пр. Свободи, 8",
        "м. Одеса, вул. Дерибасівська, 14",
        "м. Київ, вул. Антоновича, 102",
        "м. Харків, вул. Сумська, 56",
    };

    private static readonly string[] DepartmentNames =
    {
        "Терапевтичне відділення",
        "Хірургічне відділення",
        "Неврологічне відділення",
        "Кардіологічне відділення",
        "Педіатричне відділення",
        "Травматологічне відділення",
        "Гінекологічне відділення",
        "Реанімаційне відділення",
        "Інфекційне відділення",
        "Офтальмологічне відділення",
    };

    // Catalog of medications with realistic units and quantity ranges per unit
    private record MedTemplate(string Name, MeasurementUnit Unit, int MinQty, int MaxQty);

    private static readonly MedTemplate[] MedicationCatalog =
    {
        // Tablets
        new("Парацетамол 500мг", MeasurementUnit.Tablets, 10, 100),
        new("Ібупрофен 200мг", MeasurementUnit.Tablets, 10, 80),
        new("Аспірин 500мг", MeasurementUnit.Tablets, 10, 60),
        new("Цитрамон", MeasurementUnit.Tablets, 10, 60),
        new("Но-шпа 40мг", MeasurementUnit.Tablets, 10, 50),
        new("Анальгін 500мг", MeasurementUnit.Tablets, 10, 60),
        new("Активоване вугілля", MeasurementUnit.Tablets, 20, 100),
        new("Лоратадин 10мг", MeasurementUnit.Tablets, 10, 30),
        new("Супрастин 25мг", MeasurementUnit.Tablets, 10, 30),
        new("Бісептол 480мг", MeasurementUnit.Tablets, 10, 40),
        new("Амоксицилін 500мг", MeasurementUnit.Tablets, 10, 40),
        new("Валідол", MeasurementUnit.Tablets, 10, 30),
        new("Нітрогліцерин", MeasurementUnit.Tablets, 20, 60),
        new("Кеторолак 10мг", MeasurementUnit.Tablets, 10, 40),
        new("Диклофенак 50мг", MeasurementUnit.Tablets, 10, 40),
        new("Лоперамід", MeasurementUnit.Tablets, 10, 30),

        // Ampoules (injections)
        new("Адреналін 0.1%", MeasurementUnit.Ampoules, 5, 20),
        new("Атропін 0.1%", MeasurementUnit.Ampoules, 5, 20),
        new("Дексаметазон 4мг", MeasurementUnit.Ampoules, 5, 25),
        new("Преднізолон 30мг", MeasurementUnit.Ampoules, 5, 25),
        new("Магнію сульфат 25%", MeasurementUnit.Ampoules, 5, 25),
        new("Папаверин 2%", MeasurementUnit.Ampoules, 5, 25),
        new("Дімедрол 1%", MeasurementUnit.Ampoules, 5, 25),
        new("Анальгін 50% (амп.)", MeasurementUnit.Ampoules, 5, 25),

        // Milliliters (liquids, antiseptics)
        new("Корвалол", MeasurementUnit.Milliliters, 25, 100),
        new("Хлоргексидин 0.05%", MeasurementUnit.Milliliters, 100, 500),
        new("Перекис водню 3%", MeasurementUnit.Milliliters, 100, 500),
        new("Розчин йоду 5%", MeasurementUnit.Milliliters, 25, 100),
        new("Розчин брильянтового зеленого", MeasurementUnit.Milliliters, 25, 100),
        new("Спирт етиловий 70%", MeasurementUnit.Milliliters, 100, 500),
        new("Фізіологічний розчин 0.9%", MeasurementUnit.Milliliters, 200, 1000),

        // Pieces (consumables)
        new("Бинт стерильний 5м×10см", MeasurementUnit.Pieces, 5, 30),
        new("Бинт еластичний", MeasurementUnit.Pieces, 3, 15),
        new("Лейкопластир бактерицидний", MeasurementUnit.Pieces, 10, 50),
        new("Джгут гумовий", MeasurementUnit.Pieces, 2, 10),
        new("Шприц одноразовий 5мл", MeasurementUnit.Pieces, 10, 50),
        new("Шприц одноразовий 10мл", MeasurementUnit.Pieces, 10, 50),
        new("Рукавички медичні", MeasurementUnit.Pieces, 20, 200),
        new("Маска медична", MeasurementUnit.Pieces, 20, 200),

        // Grams
        new("Вата стерильна", MeasurementUnit.Grams, 50, 500),
        new("Марля медична", MeasurementUnit.Grams, 100, 500),

        // Packs
        new("Серветки спиртові", MeasurementUnit.Packs, 1, 10),
        new("Бинт марлевий (упаковка)", MeasurementUnit.Packs, 1, 10),
    };

    // Health profile for kits — controls expiration distribution
    private enum KitHealthProfile { Pristine, Normal, Neglected }

    private static (int good, int warning, int critical, int expired) ProfileDistribution(KitHealthProfile p) => p switch
    {
        KitHealthProfile.Pristine  => (95,  5,  0,  0),
        KitHealthProfile.Normal    => (60, 18, 12, 10),
        KitHealthProfile.Neglected => (25, 20, 25, 30),
        _ => (60, 18, 12, 10),
    };

    public static async Task SeedAsync(ApplicationDbContext db, IPasswordHasher<User> hasher)
    {
        Randomizer.Seed = new Random(RandomizerSeed);
        var faker = new Faker("uk");

        Console.WriteLine("=== FAIMS Database Seeder ===");
        Console.WriteLine("Очищення існуючих даних...");

        await WipeAsync(db);

        Console.WriteLine("Генерація нових даних...");

        var credentialsLog = new List<string>();

        for (int orgIdx = 0; orgIdx < OrganizationCount; orgIdx++)
        {
            var org = new Organization
            {
                Id = Guid.NewGuid(),
                Name = OrganizationNames[orgIdx % OrganizationNames.Length],
                Address = OrganizationAddresses[orgIdx % OrganizationAddresses.Length],
                CreatedDate = DateTime.UtcNow,
            };
            db.Organizations.Add(org);

            // ---- Admin user ----
            var orgSlug = $"org{orgIdx + 1}";
            var adminEmail = $"admin@{orgSlug}.faims";
            var adminPassword = "Admin123!";
            var admin = new User
            {
                Id = Guid.NewGuid(),
                Email = adminEmail,
                FirstName = "Адміністратор",
                LastName = $"#{orgIdx + 1}",
                Role = UserRole.Administrator,
                OrganizationId = org.Id,
                CreatedDate = DateTime.UtcNow,
            };
            admin.PasswordHash = hasher.HashPassword(admin, adminPassword);
            db.Users.Add(admin);

            credentialsLog.Add($"[{org.Name}]");
            credentialsLog.Add($"  ADMIN: {adminEmail} / {adminPassword}");

            // ---- Departments ----
            var deptCount = faker.Random.Int(DepartmentsPerOrgMin, DepartmentsPerOrgMax);
            var deptNamePool = faker.Random.Shuffle(DepartmentNames).ToList();
            var departments = new List<Department>();
            for (int d = 0; d < deptCount; d++)
            {
                var dept = new Department
                {
                    Id = Guid.NewGuid(),
                    Name = deptNamePool[d % deptNamePool.Count],
                    OrganizationId = org.Id,
                    CreatedDate = DateTime.UtcNow,
                };
                departments.Add(dept);
            }
            db.Departments.AddRange(departments);

            // ---- Rooms ----
            var rooms = new List<Room>();
            int roomNumber = 100;
            foreach (var dept in departments)
            {
                var roomCount = faker.Random.Int(RoomsPerDeptMin, RoomsPerDeptMax);
                for (int r = 0; r < roomCount; r++)
                {
                    rooms.Add(new Room
                    {
                        Id = Guid.NewGuid(),
                        Name = $"Кабінет №{roomNumber++}",
                        DepartmentId = dept.Id,
                        OrganizationId = org.Id,
                        CreatedDate = DateTime.UtcNow,
                    });
                }
            }
            db.Rooms.AddRange(rooms);

            // ---- Responsible users (one per kit) ----
            var responsibleUserCount = Math.Min(rooms.Count, faker.Random.Int(ResponsibleUsersPerOrgMin, ResponsibleUsersPerOrgMax));
            var responsibles = new List<User>();
            for (int u = 0; u < responsibleUserCount; u++)
            {
                var firstName = faker.Name.FirstName();
                var lastName = faker.Name.LastName();
                var email = $"user{u + 1}@{orgSlug}.faims";
                var password = "User123!";
                var user = new User
                {
                    Id = Guid.NewGuid(),
                    Email = email,
                    FirstName = firstName,
                    LastName = lastName,
                    Role = UserRole.User,
                    OrganizationId = org.Id,
                    CreatedDate = DateTime.UtcNow,
                };
                user.PasswordHash = hasher.HashPassword(user, password);
                responsibles.Add(user);

                credentialsLog.Add($"  USER : {email} / {password}  ({lastName} {firstName})");
            }
            db.Users.AddRange(responsibles);

            // ---- First aid kits (one per chosen room, paired with one responsible user) ----
            var roomsForKits = faker.Random.Shuffle(rooms).Take(responsibles.Count).ToList();
            var kits = new List<FirstAidKit>();
            for (int k = 0; k < roomsForKits.Count; k++)
            {
                var kit = new FirstAidKit
                {
                    Id = Guid.NewGuid(),
                    UniqueNumber = $"FAK-{orgIdx + 1:D2}-{k + 1:D4}",
                    Name = $"Аптечка {roomsForKits[k].Name}",
                    RoomId = roomsForKits[k].Id,
                    ResponsibleUserId = responsibles[k].Id,
                    OrganizationId = org.Id,
                    CreatedDate = DateTime.UtcNow,
                };
                kits.Add(kit);
            }
            db.FirstAidKits.AddRange(kits);

            // ---- Assign health profiles to kits: 30% Pristine, 50% Normal, 20% Neglected ----
            var kitProfiles = new Dictionary<Guid, KitHealthProfile>();
            for (int k = 0; k < kits.Count; k++)
            {
                var roll = faker.Random.Int(0, 99);
                kitProfiles[kits[k].Id] = roll < 30 ? KitHealthProfile.Pristine
                                         : roll < 80 ? KitHealthProfile.Normal
                                                     : KitHealthProfile.Neglected;
            }

            // ---- Medications (use catalog: real names with matching units & quantities) ----
            var medications = new List<Medication>();
            foreach (var kit in kits)
            {
                var profile = kitProfiles[kit.Id];
                var dist = ProfileDistribution(profile);

                var medCount = faker.Random.Int(MedicationsPerKitMin, MedicationsPerKitMax);
                // Distinct templates within one kit — keeps the catalog tidy.
                var chosen = faker.Random.Shuffle(MedicationCatalog).Take(medCount).ToList();

                foreach (var template in chosen)
                {
                    var roll = faker.Random.Int(0, 99);
                    DateTime expiration;
                    if (roll < dist.good)
                        expiration = DateTime.UtcNow.AddDays(faker.Random.Int(120, 720));
                    else if (roll < dist.good + dist.warning)
                        expiration = DateTime.UtcNow.AddDays(faker.Random.Int(35, 90));
                    else if (roll < dist.good + dist.warning + dist.critical)
                        expiration = DateTime.UtcNow.AddDays(faker.Random.Int(1, 30));
                    else
                        expiration = DateTime.UtcNow.AddDays(-faker.Random.Int(1, 180));

                    medications.Add(new Medication
                    {
                        Id = Guid.NewGuid(),
                        Name = template.Name,
                        Quantity = faker.Random.Int(template.MinQty, template.MaxQty),
                        MinimumQuantity = Math.Max(1, template.MinQty / 4),
                        ExpirationDate = DateTime.SpecifyKind(expiration, DateTimeKind.Utc),
                        Unit = template.Unit,
                        FirstAidKitId = kit.Id,
                        OrganizationId = org.Id,
                        CreatedDate = DateTime.UtcNow,
                    });
                }
            }
            db.Medications.AddRange(medications);

            // ---- Journal entries (reference real meds from the same kit) ----
            var medsByKit = medications.GroupBy(m => m.FirstAidKitId)
                                       .ToDictionary(g => g.Key, g => g.ToList());
            var journals = new List<Journal>();
            for (int k = 0; k < kits.Count; k++)
            {
                var kit = kits[k];
                var responsible = responsibles[k];
                if (!medsByKit.TryGetValue(kit.Id, out var kitMeds) || kitMeds.Count == 0) continue;

                var jCount = faker.Random.Int(JournalsPerKitMin, JournalsPerKitMax);
                for (int j = 0; j < jCount; j++)
                {
                    var sourceMed = faker.PickRandom(kitMeds);
                    var action = faker.PickRandom<JournalAction>();
                    journals.Add(new Journal
                    {
                        Id = Guid.NewGuid(),
                        ActionType = action,
                        Reason = action switch
                        {
                            JournalAction.Used       => "Використано пацієнтом",
                            JournalAction.WrittenOff => "Списано через закінчення терміну",
                            JournalAction.Expired    => "Виявлено протермінований препарат",
                            JournalAction.Added      => "Поповнення запасів",
                            JournalAction.Removed    => "Передано в інше відділення",
                            _                        => "Коригування кількості",
                        },
                        MedicationName = sourceMed.Name,
                        Quantity = faker.Random.Int(1, Math.Max(2, sourceMed.Quantity / 4)),
                        Unit = sourceMed.Unit,
                        FirstAidKitId = kit.Id,
                        UserId = responsible.Id,
                        OrganizationId = org.Id,
                        CreatedDate = DateTime.UtcNow.AddDays(-faker.Random.Int(0, 90)),
                    });
                }
            }
            db.Journals.AddRange(journals);

            await db.SaveChangesAsync();
            Console.WriteLine($"  ✓ {org.Name}: {departments.Count} відділень, {rooms.Count} кімнат, {kits.Count} аптечок, {medications.Count} ліків, {journals.Count} записів журналу");
        }

        Console.WriteLine();
        Console.WriteLine("=== УЧЕТНІ ДАНІ ===");
        foreach (var line in credentialsLog) Console.WriteLine(line);
        Console.WriteLine();

        // Also write credentials to a file for convenience
        var credPath = Path.Combine(AppContext.BaseDirectory, "seed-credentials.txt");
        await File.WriteAllLinesAsync(credPath, credentialsLog);
        Console.WriteLine($"Облікові записи збережено у файл: {credPath}");
    }

    private static async Task WipeAsync(ApplicationDbContext db)
    {
        // Order matters because of FK constraints. IgnoreQueryFilters() bypasses tenant filtering.
        await db.Journals.IgnoreQueryFilters().ExecuteDeleteAsync();
        await db.Medications.IgnoreQueryFilters().ExecuteDeleteAsync();
        await db.FirstAidKits.IgnoreQueryFilters().ExecuteDeleteAsync();
        await db.Rooms.IgnoreQueryFilters().ExecuteDeleteAsync();
        await db.Departments.IgnoreQueryFilters().ExecuteDeleteAsync();
        await db.RefreshTokens.ExecuteDeleteAsync();
        await db.Users.IgnoreQueryFilters().ExecuteDeleteAsync();
        await db.Organizations.ExecuteDeleteAsync();
    }
}
