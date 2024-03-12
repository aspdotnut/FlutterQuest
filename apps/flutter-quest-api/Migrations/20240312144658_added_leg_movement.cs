using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FlutterQuest.FlutterQuestApi.Migrations
{
    /// <inheritdoc />
    public partial class added_leg_movement : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "LegMovement",
                table: "Users",
                type: "tinyint(1)",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LegMovement",
                table: "Users");
        }
    }
}
