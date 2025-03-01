using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using ZXing;
using ZXing.Common;
using SkiaSharp;
using System;
using System.IO;
using System.Threading.Tasks;
using QRCodeApp.Data;
using QRCoder;
using QRCodeApp.Models;

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
                using (var memoryStream = new MemoryStream())
                {
                    file.CopyTo(memoryStream);
                    // Important: Reset the position of the stream before reading
                    memoryStream.Position = 0;

                    // Validate file type
                    var fileExtension = Path.GetExtension(file.FileName).ToLower();
                    if (!new[] { ".jpg", ".jpeg", ".png", ".bmp" }.Contains(fileExtension))
                    {
                        ModelState.AddModelError("", "Only JPG, PNG and BMP image files are supported.");
                        return View("Scan");
                    }

                    using (var skBitmap = SKBitmap.Decode(memoryStream))
                    {
                        if (skBitmap == null)
                        {
                            ModelState.AddModelError("", "Invalid image format.");
                            return View("Scan");
                        }

                        // Convert SKBitmap to BGRA byte array
                        var info = new SKImageInfo(skBitmap.Width, skBitmap.Height, SKColorType.Bgra8888);
                        using (var convertedBitmap = new SKBitmap(info))
                        {
                            var samplingOptions = new SKSamplingOptions(SKFilterMode.Linear, SKMipmapMode.Linear);
                            if (!skBitmap.ScalePixels(convertedBitmap, samplingOptions))
                            {
                                ModelState.AddModelError("", "Failed to process the image.");
                                return View("Scan");
                            }

                            // Create BarcodeReader with optimized settings
                            var reader = new BarcodeReaderGeneric
                            {
                                AutoRotate = true,
                                Options = new DecodingOptions
                                {
                                    TryHarder = true,
                                    TryInverted = true,
                                    PossibleFormats = new[] { BarcodeFormat.QR_CODE }
                                }
                            };

                            // Create luminance source and decode
                            var luminanceSource = new RGBLuminanceSource(convertedBitmap.Bytes, convertedBitmap.Width, convertedBitmap.Height, RGBLuminanceSource.BitmapFormat.BGRA32);
                            var result = reader.Decode(luminanceSource);

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
