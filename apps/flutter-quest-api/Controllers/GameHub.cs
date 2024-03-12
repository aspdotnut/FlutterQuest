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

using FlutterQuest.FlutterQuestApi.Data;
using FlutterQuest.FlutterQuestApi.Models;
using FlutterQuest.FlutterQuestApi.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace FlutterQuest.FlutterQuestApi.Controllers;

[Authorize]
public class GameHub : Hub
{
    /// <summary>
    /// postman json:
    /// { "protocol": "json", "version": 1 }
    /// </summary>
    public override async Task OnConnectedAsync()
    {
        var flutterQuestDbContext = new FlutterQuestDbContext();
        
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var user = flutterQuestDbContext.Users.FirstOrDefault(u => u.Id == userId);
        
        if (user == null)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        if (user.IsActive)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User already active" });
            return;
        }
        
        user.IsActive = true;
        await flutterQuestDbContext.SaveChangesAsync();

        foreach (var existingUser in Game.Game.GetInstance().GetUsers())
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 1, new ActiveUserViewModel { Id = existingUser.Id, Name = existingUser.Name, X = existingUser.X, Y = existingUser.Y, LegMovement = existingUser.LegMovement, IsActive = true });
        }

        Game.Game.GetInstance().AddUser(user);
        
        await Clients.All.SendAsync("ReceiveMessage", 3, new ChatMessageViewModel { Name = "System", Message = $"{user.Name} has joined the chat." });
        await Clients.All.SendAsync("ReceiveMessage", 1, new ActiveUserViewModel { Id = user.Id, Name = user.Name, X = user.X, Y = user.Y, LegMovement = user.LegMovement, IsActive = true });
    }
    
    /// <summary>
    /// postman json:
    /// { "arguments": ["Arrow Down"], "target": "Move", "type": 1 }
    /// </summary>
    public async Task Move(string direction)
    {
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var user = Game.Game.GetInstance().GetUser(userId);
        
        if (user == null)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var intent = new MovementIntent(user, direction);

        if (!Game.Game.CheckMovement(intent)) return;
        
        var updatedUser = intent.Commit();
        Game.Game.GetInstance().UpdateUser(updatedUser);

        await Clients.All.SendAsync("ReceiveMessage", 2, new ActiveUserViewModel { Id = updatedUser.Id, Name = updatedUser.Name, X = updatedUser.X, Y = updatedUser.Y, LegMovement = updatedUser.LegMovement, IsActive = true });
    }
    
    /// <summary>
    /// postman json:
    /// { "arguments": ["Hello"], "target": "Chat", "type": 1 }
    /// </summary>
    public async Task Chat(string message)
    {
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var user = Game.Game.GetInstance().GetUser(userId);
        
        if (user == null)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }
        
        await Clients.All.SendAsync("ReceiveMessage", 3, new ChatMessageViewModel { Name = user.Name, Message = message });
    }
    
    [AllowAnonymous]
    public override async Task OnDisconnectedAsync(Exception exception)
    {
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }
    
        var user = Game.Game.GetInstance().GetUser(userId);
        
        if (user == null)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 0, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }
        
        var flutterQuestDbContext = new FlutterQuestDbContext();
        
        var dbUser = flutterQuestDbContext.Users.FirstOrDefault(u => u.Id == userId);
        
        if (dbUser != null)
        {
            dbUser.X = user.X;
            dbUser.Y = user.Y;
            dbUser.LegMovement = user.LegMovement;
            dbUser.IsActive = false;
        
            await flutterQuestDbContext.SaveChangesAsync();
        }
        
        Game.Game.GetInstance().RemoveUser(user.Id);
        
        await Clients.All.SendAsync("ReceiveMessage", 3, new ChatMessageViewModel { Name = "System", Message = $"{user.Name} has left the chat." });
        await Clients.All.SendAsync("ReceiveMessage", 2, new ActiveUserViewModel { Id = user.Id, Name = user.Name, X = user.X, Y = user.Y, LegMovement = user.LegMovement, IsActive = false });
    }
}