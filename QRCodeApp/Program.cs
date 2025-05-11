using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using QRCodeApp.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Load .env file
DotNetEnv.Env.Load();

// Get the connection string and replace environment variables
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// Replace placeholders with actual environment variable values
connectionString = connectionString.Replace("${DB_HOST}", Environment.GetEnvironmentVariable("DB_HOST"))
                                     .Replace("${DB_NAME}", Environment.GetEnvironmentVariable("DB_NAME"))
                                     .Replace("${DB_USER}", Environment.GetEnvironmentVariable("DB_USER"))
                                     .Replace("${DB_PASSWORD}", Environment.GetEnvironmentVariable("DB_PASSWORD"));

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();

app.MapControllerRoute(
                name: "default",
                pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
