using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using QRCodeApp.Data;
using QRCodeApp.Models;
using QRCoder;
using System;
using System.IO;
using System.Threading.Tasks;
using System.Drawing; 
using System.Drawing.Imaging;
using ZXing;
using ZXing.Windows.Compatibility;

namespace QRCodeApp.Controllers
{
	public class QRCodeController : Controller
	{
		private readonly ApplicationDbContext _context;

		public QRCodeController(ApplicationDbContext context)
		{
			_context = context;
		}

        [HttpGet]
        public IActionResult Generate()
		{
			return View();
		}

		[HttpPost]
        public async Task<IActionResult> Generate(string content)
        {
            if (string.IsNullOrEmpty(content))
            {
                ModelState.AddModelError("", "Content cannot be empty.");
                return View();
            }

            using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
            {
                // Generating QR Code.
                QRCodeData qrCodeData = qrGenerator.CreateQrCode(content, QRCodeGenerator.ECCLevel.Q);
                PngByteQRCode qrCode = new PngByteQRCode(qrCodeData);
                byte[] qrCodeImage = qrCode.GetGraphic(20);

                string fileName = $"{Guid.NewGuid()}.png";
                string filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/qrcodes", fileName);

                System.IO.File.WriteAllBytes(filePath, qrCodeImage);

                // Adding QR Code to database.
                var qrCodeEntry = new QRCode
                {
                    Content = content,
                    ImagePath = "/qrcodes/" + fileName,
                    CreatedAt = DateTime.Now
                };

                _context.QRCodes.Add(qrCodeEntry);
                await _context.SaveChangesAsync();

                ViewBag.QRCodePath = qrCodeEntry.ImagePath;
            }

            return View();
        }

        [HttpGet]
        public IActionResult Scan()
        {
            return View();
        }

        [HttpPost]
        public IActionResult DecodeQR(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                ModelState.AddModelError("", "Please upload a valid image file.");
                return View("Scan");
            }

            try
            {
                // Read the uploaded file into a byte array
                using (var stream = file.OpenReadStream())
                {
                    // Convert the stream to a Bitmap
                    using (var bitmap = (Bitmap)Image.FromStream(stream))
                    {
                        // Use ZXing to decode the QR code
                        var reader = new BarcodeReader();
                        var result = reader.Decode(bitmap);

                        // Handling the Scan Result
                        if (result != null)
                        {
                            ViewBag.DecodedContent = result.Text;
                        }
                        else
                        {
                            ModelState.AddModelError("", "No QR code found in the image.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "An error occurred while decoding the QR code: " + ex.Message);
            }

            return View("Scan");
        }

        [HttpGet]
        public IActionResult History()
        {
            var qrCodes = _context.QRCodes
                .OrderByDescending(q => q.CreatedAt)
                .ToList();

            return View(qrCodes);
        }
    }
}
