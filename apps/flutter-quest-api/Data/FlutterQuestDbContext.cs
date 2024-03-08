// FlutterQuest
// A simple chatroom with certain game elements.
// Copyright (C) 2024 aspdotnut
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

using FlutterQuest.FlutterQuestApi.Models;
using Microsoft.EntityFrameworkCore;

namespace FlutterQuest.FlutterQuestApi.Data;

public class FlutterQuestDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
    
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
