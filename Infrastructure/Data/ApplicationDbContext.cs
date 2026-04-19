using Domain;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    private readonly ICurrentUserService? _currentUserService;

    public ApplicationDbContext(
        DbContextOptions<ApplicationDbContext> options,
        ICurrentUserService? currentUserService = null) : base(options)
    {
        _currentUserService = currentUserService;
    }
    
    public Guid CurrentOrganizationId => _currentUserService?.GetOrganizationId() ?? Guid.Empty;

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Department> Departments { get; set; } = null!;
    public DbSet<Room> Rooms { get; set; } = null!;
    public DbSet<FirstAidKit> FirstAidKits { get; set; } = null!;
    public DbSet<Medication> Medications { get; set; } = null!;
    public DbSet<Journal> Journals { get; set; } = null!;
    public DbSet<Organization> Organizations { get; set; } = null!;
    public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
    public DbSet<KitTemplate> KitTemplates { get; set; } = null!;
    public DbSet<KitTemplateItem> KitTemplateItems { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<FirstAidKit>()
            .HasOne(k => k.Room)
            .WithOne(r => r.FirstAidKit)
            .HasForeignKey<FirstAidKit>(k => k.RoomId);

        modelBuilder.Entity<FirstAidKit>()
            .HasOne(k => k.ResponsibleUser)
            .WithOne(u => u.ResponsibleKit)
            .HasForeignKey<FirstAidKit>(k => k.ResponsibleUserId);

        modelBuilder.Entity<FirstAidKit>()
            .HasIndex(k => k.UniqueNumber)
            .IsUnique();

        modelBuilder.Entity<User>().HasQueryFilter(e =>
            e.OrganizationId == CurrentOrganizationId && !e.IsDeleted);
        modelBuilder.Entity<Department>().HasQueryFilter(e =>
            e.OrganizationId == CurrentOrganizationId && !e.IsDeleted);
        modelBuilder.Entity<Room>().HasQueryFilter(e =>
            e.OrganizationId == CurrentOrganizationId && !e.IsDeleted);
        modelBuilder.Entity<FirstAidKit>().HasQueryFilter(e =>
            e.OrganizationId == CurrentOrganizationId && !e.IsDeleted);
        modelBuilder.Entity<Medication>().HasQueryFilter(e =>
            e.OrganizationId == CurrentOrganizationId && !e.IsDeleted);
        modelBuilder.Entity<Journal>().HasQueryFilter(e =>
            e.OrganizationId == CurrentOrganizationId && !e.IsDeleted);
        modelBuilder.Entity<RefreshToken>()
            .HasOne(rt => rt.User)
            .WithMany(u => u.RefreshTokens)
            .HasForeignKey(rt => rt.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // Системні шаблони (IsSystem=true, OrganizationId=null) видно всім організаціям.
        // Кастомні — тільки своїй організації.
        modelBuilder.Entity<KitTemplate>().HasQueryFilter(t =>
            !t.IsDeleted && (t.IsSystem || t.OrganizationId == CurrentOrganizationId));

        modelBuilder.Entity<KitTemplate>()
            .HasMany(t => t.Items)
            .WithOne(i => i.KitTemplate)
            .HasForeignKey(i => i.KitTemplateId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<KitTemplateItem>().HasQueryFilter(i => !i.IsDeleted);
    }
}