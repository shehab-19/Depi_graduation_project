using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace QRCodeApp.Migrations
{
    /// <inheritdoc />
    public partial class RemoveExpirationAndIsUsed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ExpirationTime",
                table: "QRCodes");

            migrationBuilder.DropColumn(
                name: "IsUsed",
                table: "QRCodes");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ExpirationTime",
                table: "QRCodes",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsUsed",
                table: "QRCodes",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }
    }
}
