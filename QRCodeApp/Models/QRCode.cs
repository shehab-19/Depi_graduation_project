namespace QRCodeApp.Models
{
	public class QRCode
	{
		public int Id { get; set; }
		public string Content { get; set; }
		public string ImagePath { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
