using Microsoft.AspNetCore.Mvc;
using QRCodeApp.Models;
using System.Diagnostics;

namespace QRCodeApp.Controllers
{
	public class HomeController : Controller
	{
        public IActionResult Index()
        {
            return View();
        }
    }
}
