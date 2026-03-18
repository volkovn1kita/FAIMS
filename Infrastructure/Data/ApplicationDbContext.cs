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

        modelBuilder.Entity<User>().HasQueryFilter(e => e.OrganizationId == CurrentOrganizationId);
        modelBuilder.Entity<Department>().HasQueryFilter(e => e.OrganizationId == CurrentOrganizationId);
        modelBuilder.Entity<Room>().HasQueryFilter(e => e.OrganizationId == CurrentOrganizationId);
        modelBuilder.Entity<FirstAidKit>().HasQueryFilter(e => e.OrganizationId == CurrentOrganizationId);
        modelBuilder.Entity<Medication>().HasQueryFilter(e => e.OrganizationId == CurrentOrganizationId);
        modelBuilder.Entity<Journal>().HasQueryFilter(e => e.OrganizationId == CurrentOrganizationId);
    }
}