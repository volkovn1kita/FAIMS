
using Domain;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Department> Departments { get; set; } = null!;
    public DbSet<Room> Rooms { get; set; } = null!;
    public DbSet<FirstAidKit> FirstAidKits { get; set; } = null!;
    public DbSet<Medication> Medications { get; set; } = null!;
    public DbSet<Journal> Journals { get; set; } = null!;
    

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
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
    }
}
