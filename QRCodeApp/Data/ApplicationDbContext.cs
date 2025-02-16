using Microsoft.EntityFrameworkCore;
using QRCodeApp.Models;

namespace QRCodeApp.Data
{
	public class ApplicationDbContext : DbContext
	{
		public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

		public DbSet<QRCode> QRCodes { get; set; }
	}
}
