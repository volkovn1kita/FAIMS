using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class PartialUniqueIndexFix : Migration
    {
        /// <summary>
        /// Replaces the global unique indexes on FirstAidKits.RoomId,
        /// FirstAidKits.ResponsibleUserId, and FirstAidKits.UniqueNumber
        /// with partial (filtered) unique indexes that only apply to non-deleted rows.
        /// This allows soft-deleted kits to free their room/user/number slots.
        /// </summary>
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // --- Drop old global unique indexes ---
            migrationBuilder.DropIndex(
                name: "IX_FirstAidKits_RoomId",
                table: "FirstAidKits");

            migrationBuilder.DropIndex(
                name: "IX_FirstAidKits_ResponsibleUserId",
                table: "FirstAidKits");

            migrationBuilder.DropIndex(
                name: "IX_FirstAidKits_UniqueNumber",
                table: "FirstAidKits");

            // --- Create filtered unique indexes (only for non-deleted rows) ---
            migrationBuilder.Sql(
                "CREATE UNIQUE INDEX \"IX_FirstAidKits_RoomId\" " +
                "ON \"FirstAidKits\"(\"RoomId\") " +
                "WHERE \"IsDeleted\" = false;");

            migrationBuilder.Sql(
                "CREATE UNIQUE INDEX \"IX_FirstAidKits_ResponsibleUserId\" " +
                "ON \"FirstAidKits\"(\"ResponsibleUserId\") " +
                "WHERE \"IsDeleted\" = false;");

            migrationBuilder.Sql(
                "CREATE UNIQUE INDEX \"IX_FirstAidKits_UniqueNumber\" " +
                "ON \"FirstAidKits\"(\"UniqueNumber\") " +
                "WHERE \"IsDeleted\" = false;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_FirstAidKits_RoomId",
                table: "FirstAidKits");

            migrationBuilder.DropIndex(
                name: "IX_FirstAidKits_ResponsibleUserId",
                table: "FirstAidKits");

            migrationBuilder.DropIndex(
                name: "IX_FirstAidKits_UniqueNumber",
                table: "FirstAidKits");

            migrationBuilder.CreateIndex(
                name: "IX_FirstAidKits_RoomId",
                table: "FirstAidKits",
                column: "RoomId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_FirstAidKits_ResponsibleUserId",
                table: "FirstAidKits",
                column: "ResponsibleUserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_FirstAidKits_UniqueNumber",
                table: "FirstAidKits",
                column: "UniqueNumber",
                unique: true);
        }
    }
}
