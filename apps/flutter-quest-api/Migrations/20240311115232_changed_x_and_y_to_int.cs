using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FlutterQuest.FlutterQuestApi.Migrations
{
    /// <inheritdoc />
    public partial class changed_x_and_y_to_int : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "Y",
                table: "Users",
                type: "int",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "double");

            migrationBuilder.AlterColumn<int>(
                name: "X",
                table: "Users",
                type: "int",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "double");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<double>(
                name: "Y",
                table: "Users",
                type: "double",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<double>(
                name: "X",
                table: "Users",
                type: "double",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");
        }
    }
}
