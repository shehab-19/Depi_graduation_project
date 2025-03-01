using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;
using QRCodeApp.Models;

namespace QRCodeApp.Data
{
	public class ApplicationDbContext : DbContext
	{
		public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) {
            try
            {
                var databaseCreator = Database.GetService<IDatabaseCreator>() as RelationalDatabaseCreator;
                if (databaseCreator != null)
                {
                    if (!databaseCreator.CanConnect()) databaseCreator.Create();
                    if (!databaseCreator.HasTables())databaseCreator.CreateTables();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Database creation error: {ex.Message}");
            }
        }

		public DbSet<QRCode> QRCodes { get; set; }
	}
}
