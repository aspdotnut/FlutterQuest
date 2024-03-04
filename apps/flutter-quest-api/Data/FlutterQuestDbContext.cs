using FlutterQuest.FlutterQuestApi.Models;
using Microsoft.EntityFrameworkCore;

namespace FlutterQuest.FlutterQuestApi.Data;

public class FlutterQuestDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
    public DbSet<ActiveUser> ActiveUsers { get; set; }
    
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseMySql(
            "server=localhost;" + // Server name
            "port=3306;" + // Server port
            "user=root;" + // Username
            "password=;" + // Password
            "database=flutter_quest_db;" // Database name
            , ServerVersion.Parse("10.4.27-MariaDB") // Version
        );
    }
}
